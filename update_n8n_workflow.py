import requests
import json
import os

# --- Configuration ---
# IMPORTANT: Replace these with your actual n8n URL, API Key, and Workflow ID
N8N_URL = "http://localhost:5679"  # e.g., "http://localhost:5678" or "https://your.n8n.domain"
N8N_API_KEY = "YOUR_N8N_API_KEY"  # Your n8n API key
WORKFLOW_ID = "AAfZJ6kwGjP9Vt6G"  # The ID of the workflow you want to update
# The local file containing the modified workflow JSON
MODIFIED_WORKFLOW_FILE = "modified_workflow.json"
# -------------------

def update_workflow(n8n_url, api_key, workflow_id, file_path):
    """
    Updates an n8n workflow using a local JSON file.
    """
    if not os.path.exists(file_path):
        print(f"Error: The file '{file_path}' was not found.")
        return False

    with open(file_path, 'r') as f:
        try:
            workflow_data = json.load(f)
        except json.JSONDecodeError as e:
            print(f"Error: Invalid JSON in '{file_path}'. {e}")
            return False

    headers = {
        "X-N8N-API-KEY": api_key,
        "Accept": "application/json",
        "Content-Type": "application/json"
    }
    url = f"{n8n_url}/api/v1/workflows/{workflow_id}"

    print(f"Attempting to update workflow {workflow_id} from file '{file_path}'...")

    try:
        response = requests.put(url, headers=headers, data=json.dumps(workflow_data))
        response.raise_for_status()  # Raise an exception for HTTP errors (4xx or 5xx)
        print("\nSuccessfully updated workflow!")
        print("Response:")
        print(json.dumps(response.json(), indent=2))
        return True
    except requests.exceptions.RequestException as e:
        print(f"\nError updating workflow: {e}")
        if hasattr(e, 'response') and e.response is not None:
            print(f"Response status code: {e.response.status_code}")
            print(f"Response body: {e.response.text}")
        return False

if __name__ == "__main__":
    print("Starting n8n Workflow Updater...")
    success = update_workflow(N8N_URL, N8N_API_KEY, WORKFLOW_ID, MODIFIED_WORKFLOW_FILE)

    if success:
        print("\nUpdate process completed successfully.")
    else:
        print("\nUpdate process failed.")
    print("Script finished.")
