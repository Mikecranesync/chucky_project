# Plan: Running n8n Locally with Docker

This plan outlines the steps to set up and run n8n locally using Docker. This will allow you to run and test your n8n workflows in a local environment.

## 1. Prerequisites

*   **Docker:** You must have Docker installed and running on your local machine. You can download it from the [Docker website](https://www.docker.com/products/docker-desktop).

## 2. Pull the n8n Docker Image

Open your terminal or command prompt and run the following command to pull the latest n8n image from Docker Hub:

```bash
docker pull n8nio/n8n
```

## 3. Create a Docker Volume for Data Persistence

To ensure that your workflow data is not lost when you stop or restart the n8n container, you should create a Docker volume:

```bash
docker volume create n8n_data
```

## 4. Run the n8n Container

Now, run the n8n container with the volume you just created. This command will start n8n and make it accessible on `http://localhost:5678`.

```bash
docker run -it --rm --name n8n -p 5678:5678 -v n8n_data:/home/node/.n8n n8nio/n8n
```

**Explanation of the command:**

*   `docker run`:  The command to start a new container.
*   `-it`:  Runs the container in interactive mode and allocates a pseudo-TTY.
*   `--rm`:  Automatically removes the container when it exits.
*   `--name n8n`:  Assigns a name to the container for easy reference.
*   `-p 5678:5678`:  Maps port 5678 on your local machine to port 5678 in the container.
*   `-v n8n_data:/home/node/.n8n`:  Mounts the `n8n_data` volume to the `/home/node/.n8n` directory in the container, where n8n stores its data.
*   `n8nio/n8n`:  The name of the Docker image to use.

## 5. Access the n8n UI

Once the container is running, open your web browser and navigate to:

[http://localhost:5678](http://localhost:5678)

You will be prompted to set up an owner account.

## 6. Import Your Workflow

1.  In the n8n UI, go to the "Workflows" section.
2.  Click on the "Import from File" button.
3.  Select the `Chucky (30).json` file from your local file system.
4.  Your workflow will be imported, and you can now run and edit it locally.

## 7. (Optional) Running n8n with Docker Compose

For a more manageable setup, you can use a `docker-compose.yml` file. Create a file named `docker-compose.yml` with the following content:

```yaml
version: '3.7'

services:
  n8n:
    image: n8nio/n8n
    restart: always
    ports:
      - "5678:5678"
    volumes:
      - n8n_data:/home/node/.n8n
    environment:
      - N8N_HOST=localhost
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - NODE_ENV=production
      - WEBHOOK_URL=http://localhost:5678/webhook

volumes:
  n8n_data:
```

Then, you can start n8n by running:

```bash
docker-compose up -d
```

And stop it with:

```bash
docker-compose down
```
This provides a more structured way to manage your n8n environment.
