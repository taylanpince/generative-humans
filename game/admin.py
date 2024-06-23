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
    list_display = ('name', 'email', 'assigned_chapters_count', 'created')
    search_fields = ('name', 'email')
    ordering = ('-created',)
    inlines = (ChapterInline,)

