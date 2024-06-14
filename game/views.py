from django.shortcuts import render, redirect
from django.views import View

from .auth import login_human, HumanRequiredMixin, logout_human
from .forms import HumanRegisterForm, HumanLoginForm
from .models import Human


class HumanRegisterView(View):
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


class HumanLoginView(View):
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

            # TODO: Send email to human with login link

            return redirect('game:story_list')

        return render(request, self.template_name, {'form': form})


class HumanLogoutView(View):
    def get(self, request):
        logout_human(request)
        return redirect('game:login')


class StoryListView(HumanRequiredMixin, View):
    template_name = 'story_list.html'

    def get(self, request):
        return render(request, self.template_name)
