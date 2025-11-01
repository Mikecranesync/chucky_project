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

## 9. Hosting n8n on a Hostinger VPS (Beginner-Friendly Guide)

This section provides a detailed, beginner-friendly guide to deploying n8n on your Hostinger VPS and making it accessible via a custom domain with a secure HTTPS connection.

### What is Caddy and why are we using it?

Caddy is a free, open-source web server that will act as a "gatekeeper" for your n8n instance. It does two important things for us:

1.  **Reverse Proxy:** It forwards the traffic from your domain (`n8n.maintpc.com`) to the n8n application running in a Docker container.
2.  **Automatic HTTPS:** Caddy will automatically obtain and renew a free SSL certificate for your domain. This means your n8n instance will be secure and accessible via `https://`.

You **do not** need to sign up for Caddy or pay for it. It's a free tool that we will run in a Docker container alongside n8n.

### Prerequisites

*   A Hostinger VPS with Ubuntu 24.04.
*   You are logged in to your VPS as the `root` user.
*   You have a domain name (`maintpc.com`).

### Step 1: Connect to Your VPS

Connect to your VPS using SSH.

```bash
ssh root@72.60.175.144
```

### Step 2: Update Your Server

Update your server's packages.

```bash
apt update && apt upgrade -y
```

### Step 3: Verify Docker and Install Docker Compose

Your Hostinger VPS likely has Docker pre-installed. Verify this by running:

```bash
docker --version
```

If you see a version number, you are good to go. If not, please refer to the previous instructions to install Docker.

Next, install the Docker Compose plugin:

```bash
apt-get install docker-compose-plugin -y
```

### Step 4: Create a Directory and Configuration Files for n8n

We will create a directory and two configuration files: `docker-compose.yml` and `Caddyfile`.

First, create the directory:

```bash
mkdir ~/n8n
cd ~/n8n
```

Now, create the `docker-compose.yml` file. You can use the `nano` text editor to create and edit the file.

```bash
nano docker-compose.yml
```

Copy and paste the following content into the `nano` editor:

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

Press `Ctrl+X` to exit, then `Y` to save, and `Enter` to confirm the file name.

Next, create the `Caddyfile`:

```bash
nano Caddyfile
```

Copy and paste the following content into the `nano` editor. **Make sure to replace `n8n.maintpc.com` with the subdomain you want to use.**

```
n8n.maintpc.com {
    reverse_proxy n8n:5678
}
```

Press `Ctrl+X` to exit, then `Y` to save, and `Enter` to confirm the file name.

### Step 5: Configure Your DNS

In your Hostinger dashboard, go to the DNS settings for `maintpc.com` and create a new **A record**.

*   **Type:** `A`
*   **Name:** `n8n` (or whatever subdomain you chose)
*   **Points to:** `72.60.175.144` (your VPS IP address)
*   **TTL:** Leave as default

**Note:** It is recommended to use a subdomain for n8n (like `n8n.maintpc.com`) to avoid conflicts with your existing website at `maintpc.com`.

### Step 6: Start n8n

Now you are ready to start n8n and Caddy. From your `~/n8n` directory on your VPS, run:

```bash
docker-compose up -d
```

This command will download the necessary Docker images and start the containers in the background.

### Step 7: Access Your n8n Instance

Wait a few minutes for the DNS changes to propagate and for Caddy to set up the SSL certificate. Then, open your web browser and go to:

`https://n8n.maintpc.com`

You should see the n8n setup screen, where you can create your owner account.

Congratulations! You have successfully deployed n8n on your Hostinger VPS.
