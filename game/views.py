from django.shortcuts import render
from django.views import View


class HumanRegisterView(View):
    form_class = None
    template_name = 'game/human_register.html'

    def get(self, request):
        form = self.form_class()
        return render(request, self.template_name, {'form': form})

    def post(self, request):
        form = self.form_class(request.POST)

        if form.is_valid():
            form.save()
            return render(request, 'game/home.html')

        return render(request, self.template_name, {'form': form})
