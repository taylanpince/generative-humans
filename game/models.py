from secrets import token_urlsafe
from django.db import models


class Story(models.Model):
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    illustration = models.ImageField(upload_to='illustrations/', blank=True, null=True)
    created = models.DateTimeField(auto_now_add=True)
    updated = models.DateTimeField(auto_now=True)

    @property
    def total_chapters(self):
        return self.chapters.count()

    @property
    def next_chapter(self):
        return self.chapters.filter(is_completed=False).first()
    
    @property
    def last_chapter(self):
        return self.chapters.last()

    @property
    def next_human(self):
        next_chapter = self.next_chapter
        if not next_chapter:
            return None
        return next_chapter.human

    @property
    def is_completed(self):
        return self.chapters.filter(is_completed=False).exists()

    def completed_chapters(self):
        return self.chapters.filter(is_completed=True)

    class Meta:
        ordering = ('-created',)
        verbose_name = 'story'
        verbose_name_plural = 'stories'

    def __str__(self):
        return self.title


class Human(models.Model):
    name = models.CharField(max_length=255)
    email = models.EmailField(unique=True)
    access_token = models.CharField(unique=True, default=token_urlsafe, max_length=128)
    created = models.DateTimeField(auto_now_add=True)
    updated = models.DateTimeField(auto_now=True)

    @property
    def assigned_chapters(self):
        return self.chapters.count()

    class Meta:
        ordering = ('-created',)
        verbose_name = 'human'
        verbose_name_plural = 'humans'

    def __str__(self):
        return self.name


class Chapter(models.Model):
    index = models.PositiveIntegerField(default=1)
    body = models.TextField(blank=True)
    story = models.ForeignKey(Story, on_delete=models.CASCADE, related_name='chapters')
    human = models.ForeignKey(Human, on_delete=models.CASCADE, related_name='chapters')
    is_completed = models.BooleanField(default=False)
    created = models.DateTimeField(auto_now_add=True)
    updated = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = (('index', 'story'), ('story', 'human'))
        ordering = ('index',)
        verbose_name = 'chapter'
        verbose_name_plural = 'chapters'

    def __str__(self):
        return f'{self.story.title} - Chapter {self.index} by {self.human.name}'
