from django import forms

from .models import Story


class StoryHumanForm(forms.Form):
    story = forms.ModelChoiceField(queryset=Story.objects.all())
