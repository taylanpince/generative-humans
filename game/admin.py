from django.contrib import admin
from django.db import transaction
from django.shortcuts import redirect, render

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
    list_display = ('title', 'created')
    search_fields = ('title', 'description')
    ordering = ('-created',)
    inlines = (ChapterInline,)


@admin.register(Chapter)
class ChapterAdmin(admin.ModelAdmin):
    list_display = ('story', 'index', 'human', 'is_completed', 'created')
    list_filter = ('story', 'is_completed')
    search_fields = ('story__title', 'human__name')


@admin.register(Human)
class HumanAdmin(admin.ModelAdmin):
    list_display = ('name', 'email', 'created')
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
                Chapter.objects.create(story=story, human=human, index=total_chapters)
                total_chapters += 1
            
            self.message_user(request, 'Assigned chapters to selected humans.')

            return redirect('admin:game_human_changelist')

        return render(request, 'admin/assign_story.html', {
            'form': form, 
            'queryset': queryset
        })
