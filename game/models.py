from django.db import models


class Story(models.Model):
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    illustration = models.ImageField(upload_to='illustrations/', blank=True, null=True)
    created = models.DateTimeField(auto_now_add=True)
    updated = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.title
