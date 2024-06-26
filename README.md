# Generative Humans: A Conference Game
Built for This Next Thing 2024, Generative Humans is a storytelling game that allows a group of strangers to "generate" a story by taking turns. It's meant to inspire creativity and shared storytelling while also riffing on the idea of how LLMs generate stories and writing.

Play the game here: [generativehumans.org](https://generativehumans.org/)

## Installation
This is a Django project and it's completely Dockerized. You can get a local version running using `docker-compose`:

```
docker-compose up -d
```

And you can access the running shell as so:

```
docker-compose exec web bash
```

## Deployment
Project also contains a complete Terraform configuration for AWS deployment. To apply it:

```
cd terraform
terraform apply
```

Terraform will ask for a database password, which you can set during the first run.

Full deployment script can be run under `tools`:

```
./tools/deploy.sh
```

This will create a new Docker image with the updated application, register it, run migrations and `collectstatic` on AWS and refresh the ECS tasks.
