# n8n Implementation Plan

This plan outlines the steps to deploy and manage your n8n instance, both on a production server and for local development.

---

## Part 1: Deploying n8n on a Hostinger VPS (Beginner-Friendly Guide)

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

---

## Part 2: Programmatic Workflow Automation (Scripted Method)

This section outlines the steps to start implementing the "Scripted" method for programmatic n8n workflow automation, as described in the `gemini.md` file. This method uses the Gemini CLI and `curl` to interact with the n8n API.

### Step 1: Set up your n8n API Credentials

Before you can interact with the n8n API, you need to get your API key from your n8n instance and set it as an environment variable on your VPS.

1.  **Get your n8n API Key:**
    *   Log in to your n8n instance at `https://n8n.maintpc.com`.
    *   Go to **Settings > n8n API**.
    *   Click **Create an API key**.
    *   Give your key a name (e.g., `gemini-cli`) and copy the key.

2.  **Set Environment Variables on your VPS:**
    *   Connect to your VPS via SSH: `ssh root@72.60.175.144`
    *   Open the `~/.bashrc` file in a text editor: `nano ~/.bashrc`
    *   Add the following lines to the end of the file, replacing the placeholder values with your actual n8n URL and API key:

        ```bash
        export N8N_URL="https://n8n.maintpc.com"
        export N8N_API_KEY="your-n8n-api-key-goes-here"
        ```
    *   Save the file (`Ctrl+X`, `Y`, `Enter`).
    *   Load the new environment variables: `source ~/.bashrc`

### Step 2: Create a New Workflow from a Natural Language Prompt

This script uses Gemini to generate a workflow from scratch and immediately uploads it to n8n.

1.  **Create the script file:**
    *   On your VPS, create a new file named `create_workflow.sh`:
        ```bash
        nano create_workflow.sh
        ```
    *   Copy and paste the following script into the file:

        ```bash
        #!/bin/bash
        # create_workflow.sh

        # 1. DEFINE THE PROMPT
        # The prompt is highly specific to ensure we get ONLY raw JSON back.
        PROMPT="Generate a complete n8n workflow JSON. The workflow must:
        1. Trigger with a Webhook node named 'Start'.
        2. Connect to a Set node named 'Set Message' that sets a variable 'message' to 'Hello from Gemini'.
        3. Connect 'Set Message' to a 'Respond to Webhook' node.
        4. Respond ONLY with the raw, valid JSON. Do not include markdown or any other text."

        echo "Generating workflow JSON from Gemini..."

        # 2. GENERATE
        # We use 'gemini -p' for non-interactive mode.
        # We redirect output to a file for inspection and for the 'curl -d @' command.
        gemini -p "$PROMPT" > new_workflow.json

        if [ ! -s new_workflow.json ]; then
            echo "Error: Gemini did not produce an output file. Check Gemini auth and prompt."
            exit 1
        fi

        echo "Uploading new workflow to n8n..."

        # 3. WRITE
        # -s for silent, -w "\n%{http_code}" to print the HTTP code on a new line.
        RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
        "$N8N_URL/api/v1/workflows" \
        -H "accept: application/json" \
        -H "X-N8N-API-KEY: $N8N_API_KEY" \
        -H "Content-Type: application/json" \
        -d @new_workflow.json)

        # 4. PARSE RESPONSE
        HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
        BODY=$(echo "$RESPONSE" | sed '$d')

        if [ $HTTP_CODE -eq 201 ]; then
            echo "Successfully created workflow."
            echo "$BODY"
        else
            echo "Failed to create workflow. HTTP Code: $HTTP_CODE"
            echo "Response: $BODY"
        fi
        ```
    *   Save the file (`Ctrl+X`, `Y`, `Enter`).
    *   Make the script executable: `chmod +x create_workflow.sh`

2.  **Run the script:**
    ```bash
    ./create_workflow.sh
    ```

This will create a new workflow in your n8n instance.

### Step 3: Update an Existing Workflow (Read-Modify-Write)

This script performs the complete cycle: fetching an existing workflow, using Gemini to modify it, and uploading the new version.

1.  **Create the script file:**
    *   On your VPS, create a new file named `update_workflow.sh`:
        ```bash
        nano update_workflow.sh
        ```
    *   Copy and paste the following script into the file:

        ```bash
        #!/bin/bash
        # update_workflow.sh

        if [ -z "$1" ]; then
            echo "Usage: $0 <WORKFLOW_ID>"
            exit 1
        fi

        WORKFLOW_ID=$1

        PROMPT="Review the following n8n workflow JSON. Add a new 'Set' node with the name 'Gemini-Modified' that sets a variable 'status' to 'updated'. Connect it between the 'Start' node and whatever 'Start' connects to. Respond ONLY with the new, complete, valid JSON."

        # 1. READ
        echo "Fetching workflow $WORKFLOW_ID..."
        RESPONSE=$(curl -s -w "\n%{http_code}" -X GET \
        "$N8N_URL/api/v1/workflows/$WORKFLOW_ID" \
        -H "accept: application/json" \
        -H "X-N8N-API-KEY: $N8N_API_KEY")

        HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
        BODY=$(echo "$RESPONSE" | sed '$d')

        if [ $HTTP_CODE -ne 200 ]; then
            echo "Error fetching workflow. HTTP Code: $HTTP_CODE"
            echo "Response: $BODY"
            exit 1
        fi

        echo "$BODY" > current_workflow.json

        # 2. MODIFY
        echo "Modifying workflow with Gemini..."
        gemini -p "@current_workflow.json $PROMPT" > modified_workflow.json

        if [ ! -s modified_workflow.json ]; then
            echo "Error: Gemini failed to produce a modified workflow."
            exit 1
        fi

        # 3. WRITE
        echo "Uploading modified workflow..."
        RESPONSE=$(curl -s -w "\n%{http_code}" -X PUT \
        "$N8N_URL/api/v1/workflows/$WORKFLOW_ID" \
        -H "accept: application/json" \
        -H "X-N8N-API-KEY: $N8N_API_KEY" \
        -H "Content-Type: application/json" \
        -d @modified_workflow.json)

        HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
        BODY=$(echo "$RESPONSE" | sed '$d')

        if [ $HTTP_CODE -eq 200 ]; then
            echo "Successfully updated workflow $WORKFLOW_ID."
        else
            echo "Failed to update workflow. HTTP Code: $HTTP_CODE"
            echo "Response: $BODY"
        fi
        ```
    *   Save the file (`Ctrl+X`, `Y`, `Enter`).
    *   Make the script executable: `chmod +x update_workflow.sh`

2.  **Run the script:**
    *   First, get the ID of the workflow you want to update from your n8n instance.
    *   Then, run the script with the workflow ID as an argument:
        ```bash
        ./update_workflow.sh 123
        ```
        (Replace `123` with your actual workflow ID).

---

## Part 3: Local n8n Development with Docker

This section outlines the steps to set up and run n8n locally using Docker. This is useful for testing workflows before deploying them to your production server.

### 1. Prerequisites

*   **Docker:** You must have Docker installed and running on your local machine. You can download it from the [Docker website](https://www.docker.com/products/docker-desktop).

### 2. Pull the n8n Docker Image

Open your terminal or command prompt and run the following command to pull the latest n8n image from Docker Hub:

```bash
docker pull n8nio/n8n
```

### 3. Create a Docker Volume for Data Persistence

To ensure that your workflow data is not lost when you stop or restart the n8n container, you should create a Docker volume:

```bash
docker volume create n8n_data
```

### 4. Run the n8n Container

Now, run the n8n container with the volume you just created. This command will start n8n and make it accessible on `http://localhost:5678`.

```bash
docker run -it --rm --name n8n -p 5679:5678 -v n8n_data:/home/node/.n8n n8nio/n8n
```

**Note:** The port is mapped to `5679` on the host machine to avoid conflicts with other services that might be running on port `5678`.

### 5. Access the n8n UI

Once the container is running, open your web browser and navigate to:

[http://localhost:5679](http://localhost:5679)

You will be prompted to set up an owner account.

### 6. Import Your Workflow

1.  In the n8n UI, go to the "Workflows" section.
2.  Click on the "Import from File" button.
3.  Select the `Chucky (30).json` file from your local file system.
4.  Your workflow will be imported, and you can now run and edit it locally.

---

## Part 4: Version Control

This plan is under version control using Git. All changes to this plan are tracked.

*   **Initial Version:** The initial version of this plan is stored in `plan.v1.md`.
*   **Current Version:** This file, `plan.md`, will always contain the latest version of the plan.
*   **Tracking Changes:** To see the history of changes to the plan, you can use the `git log` command:

    ```bash
    git log --oneline plan.md
    ```
*   **Creating New Versions:** When significant changes are made to the plan, a new versioned file will be created (e.g., `plan.v2.md`).