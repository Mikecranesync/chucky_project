import requests
import json

# --- Configuration ---
# IMPORTANT: Replace these with your actual n8n URL, API Key, and Workflow ID
N8N_URL = "http://localhost:5679"  # e.g., "http://localhost:5678" or "https://your.n8n.domain"
N8N_API_KEY = "YOUR_N8N_API_KEY"  # Your n8n API key
WORKFLOW_ID = "AAfZJ6kwGjP9Vt6G"  # The ID of the workflow you want to fetch (e.g., "1")
# -------------------

def get_workflow_json(n8n_url, api_key, workflow_id):
    """
    Fetches the JSON representation of an n8n workflow.
    """
    headers = {
        "X-N8N-API-KEY": api_key,
        "Accept": "application/json"
    }
    url = f"{n8n_url}/api/v1/workflows/{workflow_id}"

    print(f"Attempting to fetch workflow from: {url}")

    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()  # Raise an exception for HTTP errors (4xx or 5xx)
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Error fetching workflow: {e}")
        if hasattr(e, 'response') and e.response is not None:
            print(f"Response status code: {e.response.status_code}")
            print(f"Response body: {e.response.text}")
        return None

def analyze_workflow_json(workflow_json):
    """
    Analyzes and prints key parts of the workflow JSON.
    """
    if not workflow_json:
        print("No workflow JSON to analyze.")
        return

    print("\n--- Workflow Name ---")
    print(workflow_json.get("name", "N/A"))

    print("\n--- Workflow Nodes ---")
    nodes = workflow_json.get("nodes", [])
    if nodes:
        for i, node in enumerate(nodes):
            print(f"  Node {i+1}:")
            print(f"    Name: {node.get('name', 'N/A')}")
            print(f"    Type: {node.get('type', 'N/A')}")
            print(f"    ID: {node.get('id', 'N/A')}")
            # You can add more details here if needed, e.g., node.get('parameters')
    else:
        print("  No nodes found in this workflow.")

    print("\n--- Workflow Connections ---")
    connections = workflow_json.get("connections", [])
    if connections:
        for i, conn in enumerate(connections):
            print(f"  Connection {i+1}:")
            print(f"    From Node: {conn.get('from', {}).get('node', 'N/A')}")
            print(f"    To Node: {conn.get('to', {}).get('node', 'N/A')}")
            # You can add more details here if needed
    else:
        print("  No connections found in this workflow.")

    print("\n--- Full Workflow JSON (for detailed inspection) ---")
    print(json.dumps(workflow_json, indent=2))

if __name__ == "__main__":
    print("Starting n8n Workflow Fetcher and Analyzer...")
    workflow_data = get_workflow_json(N8N_URL, N8N_API_KEY, WORKFLOW_ID)

    if workflow_data:
        analyze_workflow_json(workflow_data)
    else:
        print("Failed to retrieve workflow data.")
    print("\nScript finished.")
