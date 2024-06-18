from django.contrib import admin
from django.core.mail import send_mail
from django.db import IntegrityError, transaction
from django.shortcuts import redirect, render
from django.urls import reverse
from django.template.loader import render_to_string

from .forms import StoryHumanForm
from .models import Story, Human, Chapter


class ChapterInline(admin.TabularInline):
    model = Chapter
    extra = 0
    fields = ('index', 'story', 'human', 'is_completed')
    readonly_fields = ('index',)
    ordering = ('index',)
    show_change_link = True


@admin.register(Story)
class StoryAdmin(admin.ModelAdmin):
    list_display = ('title', 'created', 'next_human', 'is_completed')
    search_fields = ('title', 'description')
    ordering = ('-created',)
    actions = ('send_reminders',)
    inlines = (ChapterInline,)

    @admin.action(description='Send reminders to humans')
    def send_reminders(self, request, queryset):
        count = 0

        for story in queryset:
            if story.is_completed:
                continue

            human = story.next_human

            if not human:
                continue

            subject = f'Generative Humans: Reminder for Your Story {story.title}'
            login_url = request.build_absolute_uri(reverse('game:authenticate', args=[human.access_token]))
            text_mail = render_to_string('reminder_email.txt', {'login_url': login_url, 'human': human})
            html_mail = render_to_string('reminder_email.html', {'login_url': login_url, 'human': human})

            send_mail(
                subject,
                text_mail,
                'storybot@generativehumans.org',
                [human.email],
                fail_silently=False,
                html_message=html_mail
            )

            count += 1
        
        self.message_user(request, f'Sent {count} reminders for selected stories.')

        return redirect('admin:game_story_changelist')


@admin.register(Chapter)
class ChapterAdmin(admin.ModelAdmin):
    list_display = ('story', 'index', 'human', 'is_completed', 'created')
    list_filter = ('story', 'is_completed')
    search_fields = ('story__title', 'human__name')


@admin.register(Human)
class HumanAdmin(admin.ModelAdmin):
    list_display = ('name', 'email', 'assigned_chapters_count', 'created')
    search_fields = ('name', 'email')
    ordering = ('-created',)
    actions = ('assign_story',)
    inlines = (ChapterInline,)

    @transaction.atomic
    @admin.action(description='Assign story to humans')
    def assign_story(self, request, queryset):
        form = StoryHumanForm(request.POST or None)

        if request.method == 'POST' and form.is_valid():
            story = form.cleaned_data['story']
            total_chapters = story.chapters.count() + 1

            for human in queryset:
                try:
                    Chapter.objects.create(story=story, human=human, index=total_chapters)
                except IntegrityError:
                    self.message_user(request, 'You cannot assign multiple chapters to the same human in a single story.', level='ERROR')
                    return
                total_chapters += 1
            
            self.message_user(request, f'Assigned {total_chapters} chapters to selected humans.')

            return redirect('admin:game_human_changelist')

        return render(request, 'admin/assign_story.html', {
            'form': form, 
            'queryset': queryset
        })

