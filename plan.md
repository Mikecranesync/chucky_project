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

## 8. Version Control

This plan is under version control using Git. All changes to this plan are tracked.

*   **Initial Version:** The initial version of this plan is stored in `plan.v1.md`.
*   **Current Version:** This file, `plan.md`, will always contain the latest version of the plan.
*   **Tracking Changes:** To see the history of changes to the plan, you can use the `git log` command:

    ```bash
    git log --oneline plan.md
    ```
*   **Creating New Versions:** When significant changes are made to the plan, a new versioned file will be created (e.g., `plan.v2.md`).

## 9. Hosting n8n on a Hostinger VPS

This section provides a step-by-step guide to deploying n8n on your Hostinger VPS and making it accessible via a custom domain.

### Prerequisites

*   A Hostinger VPS with Ubuntu 24.04 or another modern Linux distribution.
*   Root access to your VPS (or a user with `sudo` privileges).
*   A domain name (e.g., `maintpc.com`) pointed to your VPS's IP address.

### Step 1: Connect to Your VPS

Connect to your VPS using SSH.

```bash
ssh root@72.60.175.144
```

### Step 2: Update Your Server

It's always a good practice to update your server's package list and upgrade the installed packages to their latest versions.

```bash
sudo apt update && sudo apt upgrade -y
```

### Step 3: Install Docker and Docker Compose

n8n runs in a Docker container, so you need to install Docker and Docker Compose.

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo apt-get install docker-compose-plugin -y
```

### Step 4: Create a Directory for n8n

Create a directory to store your n8n data and `docker-compose.yml` file.

```bash
mkdir ~/n8n
cd ~/n8n
```

### Step 5: Create a `docker-compose.yml` File

Create a `docker-compose.yml` file with the following content. This setup uses Caddy as a reverse proxy to automatically handle HTTPS for your n8n instance.

```yaml
version: '3.7'

services:
  n8n:
    image: n8nio/n8n
    restart: always
    ports:
      - "127.0.0.1:5678:5678"
    environment:
      - N8N_HOST=n8n.maintpc.com
      - N8N_PORT=5678
      - N8N_PROTOCOL=https
      - NODE_ENV=production
      - WEBHOOK_URL=https://n8n.maintpc.com/webhook
    volumes:
      - n8n_data:/home/node/.n8n

  caddy:
    image: caddy:2
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
    command: caddy run --config /etc/caddy/Caddyfile

volumes:
  n8n_data:
  caddy_data:
```

### Step 6: Create a `Caddyfile`

Create a file named `Caddyfile` in the same directory (`~/n8n`) with the following content. This file configures Caddy to act as a reverse proxy for n8n.

**Important:** Replace `n8n.maintpc.com` with the subdomain you want to use for n8n.

```
n8n.maintpc.com {
    reverse_proxy n8n:5678
}
```

### Step 7: Configure Your DNS

In your Hostinger DNS settings for `maintpc.com`, create an **A record** that points your chosen subdomain (e.g., `n8n`) to your VPS's IP address (`72.60.175.144`).

**Note:** It is recommended to use a subdomain for n8n (like `n8n.maintpc.com`) to avoid conflicts with your existing website at `maintpc.com`.

*   **Type:** A
*   **Name:** n8n
*   **Points to:** 72.60.175.144
*   **TTL:** Default

### Step 8: Start n8n

Now, from your `~/n8n` directory on your VPS, start the n8n and Caddy containers using Docker Compose.

```bash
docker-compose up -d
```

### Step 9: Access Your n8n Instance

After a few moments for the DNS to propagate and for Caddy to issue an SSL certificate, you should be able to access your n8n instance in your web browser at:

`https://n8n.maintpc.com`

You will be prompted to set up an owner account for your new n8n instance.
