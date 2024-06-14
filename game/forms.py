from django import forms

from .models import Story, Human


class StoryHumanForm(forms.Form):
    story = forms.ModelChoiceField(queryset=Story.objects.all())


class HumanRegisterForm(forms.ModelForm):
    class Meta:
        model = Human
        fields = ['name', 'email']


class HumanLoginForm(forms.Form):
    email = forms.EmailField(required=True)

    def clean_email(self):
        email = self.cleaned_data['email']

        if not Human.objects.filter(email=email).exists():
            raise forms.ValidationError('No human with this email found.')

        return email
