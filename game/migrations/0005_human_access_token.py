# Generated by Django 5.0.6 on 2024-06-14 20:04

import secrets
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('game', '0004_alter_chapter_unique_together'),
    ]

    operations = [
        migrations.AddField(
            model_name='human',
            name='access_token',
            field=models.CharField(default=secrets.token_urlsafe, max_length=128),
        ),
    ]
