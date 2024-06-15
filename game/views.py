from django.core.mail import send_mail
from django.shortcuts import get_object_or_404, render, redirect
from django.views import View
from django.urls import reverse
from django.template.loader import render_to_string

from .auth import login_human, HumanRequiredMixin, HumanAuthenticatedCheckMixin, logout_human
from .forms import HumanRegisterForm, HumanLoginForm, ChapterWriteForm
from .models import Human, Story


class HumanRegisterView(HumanAuthenticatedCheckMixin, View):
    form_class = HumanRegisterForm
    template_name = 'register.html'

    def get(self, request):
        form = self.form_class()
        return render(request, self.template_name, {'form': form})

    def post(self, request):
        form = self.form_class(request.POST)

        if form.is_valid():
            human = form.save()
            login_human(request, human)

            return redirect('game:story_list')

        return render(request, self.template_name, {'form': form})


class HumanLoginView(HumanAuthenticatedCheckMixin, View):
    form_class = HumanLoginForm
    template_name = 'login.html'

    def get(self, request):
        form = self.form_class()
        return render(request, self.template_name, {'form': form})
    
    def post(self, request):
        form = self.form_class(request.POST)

        if form.is_valid():
            email = form.cleaned_data['email']
            human = Human.objects.get(email=email)
            login_url = request.build_absolute_uri(reverse('game:authenticate', args=[human.access_token]))
            text_mail = render_to_string('login_email.txt', {'login_url': login_url, 'human': human})
            html_mail = render_to_string('login_email.html', {'login_url': login_url, 'human': human})

            send_mail(
                'Generative Humans: Login to your account',
                text_mail,
                'storybot@generativehumans.org',
                [human.email],
                fail_silently=False,
                html_message=html_mail
            )

            return redirect('game:login_success')

        return render(request, self.template_name, {'form': form})


class HumanAuthenticateView(HumanAuthenticatedCheckMixin, View):
    def get(self, request, access_token):
        try:
            human = Human.objects.get(access_token=access_token)
        except Human.DoesNotExist:
            return redirect('game:login')

        login_human(request, human)
        return redirect('game:story_list')


class HumanLoginSuccessView(HumanAuthenticatedCheckMixin, View):
    template_name = 'login_success.html'

    def get(self, request):
        return render(request, self.template_name)


class HumanLogoutView(HumanAuthenticatedCheckMixin, View):
    def get(self, request):
        logout_human(request)
        return redirect('game:login')


class StoryListView(HumanRequiredMixin, View):
    template_name = 'story_list.html'

    def get(self, request):
        chapters = request.human.chapters.all()

        return render(request, self.template_name , {'chapters': chapters})


class StoryDetailView(HumanRequiredMixin, View):
    template_name = 'story_detail.html'

    def get(self, request, story_id):
        story = get_object_or_404(Story, pk=story_id)

        return render(request, self.template_name , {'story': story})


class ChapterWriteView(HumanRequiredMixin, View):
    form_class = ChapterWriteForm
    template_name = 'story_write.html'

    def get(self, request, story_id):
        story = get_object_or_404(Story, pk=story_id)
        chapter = story.next_chapter

        if not chapter:
            return redirect('game:story_list')

        if chapter.human != request.human:
            return redirect('game:story_list')

        form = self.form_class()
        return render(request, self.template_name, {
            'form': form,
            'story': story,
            'chapter': chapter,
        })

    def post(self, request, story_id):
        story = get_object_or_404(Story, pk=story_id)
        chapter = story.next_chapter

        if not chapter:
            return redirect('game:story_list')

        if chapter.human != request.human:
            return redirect('game:story_list')

        form = self.form_class(request.POST)

        if form.is_valid():
            content = form.cleaned_data['content']
            chapter.body = content
            chapter.is_completed = True
            chapter.save()

            # TODO: Send email to next human

            return redirect('game:story_detail', story_id=story_id)

        return render(request, self.template_name, {
            'form': form,
            'story': story,
            'chapter': chapter,
        })
