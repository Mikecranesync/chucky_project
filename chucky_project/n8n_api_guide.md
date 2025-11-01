# n8n API Guide: How to Get Your Workflow JSON

This guide provides a simple, step-by-step process to securely get your n8n workflow as a JSON file using the n8n API. This method is the best way to share your workflow for editing, as it preserves your credentials.

## Prerequisites

*   **n8n is running:** Your n8n instance must be running and accessible from your web browser.
*   **Terminal:** You need a command-line terminal.
    *   **Windows:** You can use **PowerShell** or **Command Prompt**.
    *   **macOS/Linux:** You can use the **Terminal** application.

## Step 1: Get Your n8n API Key

Your API key is like a password for your n8n instance. Keep it safe and do not share it.

1.  **Open your n8n instance** in your web browser (e.g., `http://localhost:5678`).
2.  In the left-hand menu, click on **Credentials & API**.
3.  Click on the **API** tab at the top.
4.  If you don't have an API key, click the **Add API Key** button to create one.
5.  Click the **copy icon** next to the API key to copy it to your clipboard.

    ![n8n API Key Location](https://i.imgur.com/sL4Z8aE.png)

## Step 2: Find Your Workflow ID

Each workflow in n8n has a unique ID.

1.  In the n8n UI, click on **Workflows** in the left-hand menu.
2.  **Open the workflow** you want to edit.
3.  Look at the URL in your browser's address bar. It will look like this:

    `http://localhost:5678/workflow/1`

    The number at the very end of the URL is your **Workflow ID**. In this example, the ID is `1`.

## Step 3: Get Your Workflow JSON

Now, we'll use the `curl` command in your terminal to get the workflow's JSON.

1.  **Open your terminal** (PowerShell, Command Prompt, etc.).
2.  **Copy the following command template:**

    ```bash
    curl --request GET --url <YOUR_N8N_URL>/api/v1/workflows/<YOUR_WORKFLOW_ID> --header "X-N8N-API-KEY: <YOUR_API_KEY>"
    ```

3.  **Replace the placeholders** in the command:
    *   Replace `<YOUR_N8N_URL>` with the URL of your n8n instance (e.g., `http://localhost:5678`).
    *   Replace `<YOUR_WORKFLOW_ID>` with the ID you found in Step 2.
    *   Replace `<YOUR_API_KEY>` with the API key you copied in Step 1.

    **Example:**

    If your n8n URL is `http://localhost:5678`, your workflow ID is `1`, and your API key is `n8n-api-xxxxxxxx`, the command would look like this:

    ```bash
    curl --request GET --url http://localhost:5678/api/v1/workflows/1 --header "X-N8N-API-KEY: n8n-api-xxxxxxxx"
    ```

4.  **Press Enter** to run the command.

## Step 4: Share the JSON Output

The command will print the JSON of your workflow directly into your terminal window.

1.  **Select and copy the entire JSON output.** It will start with `{` and end with `}`.
2.  **Paste the copied JSON** into our chat.

Once you provide the JSON, I can help you make the changes you need. I will then give you an updated JSON and a `curl` command to update your workflow in n8n.
