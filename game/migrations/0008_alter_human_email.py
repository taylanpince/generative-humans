# Generated by Django 5.0.6 on 2024-06-14 20:58

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('game', '0007_alter_human_access_token'),
    ]

    operations = [
        migrations.AlterField(
            model_name='human',
            name='email',
            field=models.EmailField(max_length=254, unique=True),
        ),
    ]