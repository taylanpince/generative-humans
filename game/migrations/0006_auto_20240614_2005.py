# Generated by Django 5.0.6 on 2024-06-14 20:05
from secrets import token_urlsafe
from django.db import migrations


def generate_access_tokens(apps, schema_editor):
    Human = apps.get_model('game', 'Human')

    for human in Human.objects.all():
        human.access_token = token_urlsafe()
        human.save()


class Migration(migrations.Migration):

    dependencies = [
        ('game', '0005_human_access_token'),
    ]

    operations = [
        migrations.RunPython(generate_access_tokens, reverse_code=migrations.RunPython.noop),
    ]
