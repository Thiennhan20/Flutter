# Generated by Django 5.1.4 on 2025-01-08 19:54

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('dating_app', '0016_alter_chatroom_id'),
    ]

    operations = [
        migrations.AlterField(
            model_name='chatroom',
            name='id',
            field=models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID'),
        ),
    ]
