# Generated by Django 5.0.6 on 2024-06-16 20:53

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('game', '0008_alter_human_email'),
    ]

    operations = [
        migrations.AddField(
            model_name='story',
            name='is_full',
            field=models.BooleanField(default=False),
        ),
    ]
