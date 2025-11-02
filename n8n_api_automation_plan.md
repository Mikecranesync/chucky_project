# Plan: Programmatic n8n Workflow Management

This plan outlines the steps to achieve programmatic building and fixing of n8n workflows using the n8n API.

## 1. Core Concepts

*   **n8n API:** The n8n API is the key to programmatic access. It allows you to create, read, update, and delete workflows, credentials, and executions.
*   **Workflow as JSON:** Every n8n workflow is represented as a JSON object. To build or modify a workflow, you will be creating or manipulating this JSON structure.
*   **API Client:** You will need an API client to make HTTP requests to the n8n API. You can use `curl` for simple tasks, but for more complex operations, a scripting language like Python or JavaScript is recommended.

## 2. Prerequisites

*   **n8n Instance:** A running n8n instance (local or remote).
*   **API Key:** An n8n API key.
*   **Scripting Environment:** A Python or Node.js environment to write your automation scripts.

## 3. Phase 1: Reading and Understanding Workflows

*   **Goal:** To be able to fetch a workflow from your n8n instance and understand its structure.
*   **Steps:**
    1.  **Get Workflow ID:** Manually get the ID of a workflow from the n8n UI.
    2.  **Fetch Workflow JSON:** Use a script (Python with `requests` or Node.js with `axios`) to make a GET request to the `/api/v1/workflows/{workflow_id}` endpoint.
    3.  **Analyze the JSON:** Study the JSON structure. Identify the `nodes` and `connections` arrays. Understand how nodes are defined (type, parameters, credentials) and how they are connected.

## 4. Phase 2: Creating New Workflows

*   **Goal:** To be able to create a new, simple workflow from scratch.
*   **Steps:**
    1.  **Define a Simple Workflow in JSON:** Create a JSON object in your script that defines a simple workflow (e.g., a "Manual Trigger" node connected to a "Set" node).
    2.  **Create the Workflow:** Make a POST request to the `/api/v1/workflows` endpoint with the JSON payload.
    3.  **Verify Creation:** Check your n8n UI to see if the new workflow has been created.

## 5. Phase 3: Modifying Existing Workflows

*   **Goal:** To be able to add, remove, or modify nodes and connections in an existing workflow.
*   **Steps:**
    1.  **Fetch the Workflow:** Get the JSON of the workflow you want to modify.
    2.  **Manipulate the JSON:**
        *   **Add a node:** Create a new node object and add it to the `nodes` array.
        *   **Add a connection:** Add a new connection object to the `connections` array, linking the new node to an existing one.
        *   **Modify a node:** Find the node you want to change in the `nodes` array and update its `parameters`.
    3.  **Update the Workflow:** Make a PUT request to the `/api/v1/workflows/{workflow_id}` endpoint with the modified JSON payload.
    4.  **Verify Changes:** Check the n8n UI to see if the workflow has been updated.

## 6. Phase 4: Advanced - "Fixing" Workflows

*   **Goal:** To be able to programmatically identify and fix common issues in workflows.
*   **Example "Fix":** Let's say you want to replace all instances of a deprecated node with a new one.
*   **Steps:**
    1.  **Fetch the Workflow:** Get the workflow's JSON.
    2.  **Iterate through Nodes:** Loop through the `nodes` array.
    3.  **Identify the Deprecated Node:** Check the `type` of each node. If it matches the deprecated node's type, you've found one.
    4.  **Replace the Node:**
        *   Create a new node object for the replacement node.
        *   Copy over any relevant parameters from the old node to the new one.
        *   Update the `connections` array to point to the new node's ID.
        *   Remove the old node from the `nodes` array.
    5.  **Update the Workflow:** Make a PUT request with the fixed JSON.

## 7. Building a Reusable Library

*   As you develop these scripts, you can encapsulate the logic into reusable functions or classes. For example, you could have functions like:
    *   `get_workflow(workflow_id)`
    *   `create_workflow(workflow_json)`
    *   `update_workflow(workflow_id, workflow_json)`
    *   `add_node(workflow_json, node_to_add)`
    *   `add_connection(workflow_json, from_node, to_node)`
