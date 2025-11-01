# Programmatic Workflow Automation: Integrating the Gemini CLI with the n8n REST API

This document outlines the goals and strategies for moving beyond the n8n GUI to a "meta-automation" paradigm, enabling programmatic, terminal-based control over n8n workflows.

## Executive Summary: Beyond the GUI

The core idea is to leverage the Google Gemini CLI as an intelligent "programmer" and the n8n REST API as the execution "engine." This transforms n8n from a tool to be "clicked" into a platform to be "programmed."

## The Read-Modify-Write Cycle

All programmatic n8n workflow management is based on a three-phase cycle:

1.  **Read:** The current state of the workflow is fetched from the n8n REST API as a JSON object.
2.  **Modify:** The local JSON file is used as context for the Gemini CLI. A natural language prompt is used to instruct Gemini to make changes to the JSON.
3.  **Write:** The new, modified JSON object is sent back to the n8n REST API, overwriting the old workflow.

## Architectural Methods

There are two primary methods to achieve this:

1.  **The "Scripted" Method:** A flexible, universal approach using standard command-line tools (`curl`, `|`, `cat`) to orchestrate a command-line-driven process. This method is powerful but can be brittle as it relies on Gemini's general knowledge of the n8n JSON structure.

2.  **The "Integrated" (MCP) Method:** An advanced, context-aware solution that uses a Model Context Protocol (MCP) server. This method "teaches" the Gemini CLI to be natively "n8n-aware," enabling it to understand n8n-specific tools and execute complex workflow management tasks directly with natural language commands. This is a more robust and reliable solution.

## Key Goals and Information

*   **Primary Goal:** Enable developers to manage n8n workflows entirely from the command line using natural language prompts with the Gemini CLI.
*   **"Meta-Automation":** We are not just building automations; we are automating the process of building automations.
*   **Gemini as a "Programmer":** The Gemini CLI will act as an intelligent agent that can translate high-level requests into the structured JSON that the n8n API requires.
*   **`GEMINI.md` Context File:** This file will be used to provide persistent instructions to the Gemini CLI, making it an expert on our specific n8n setup and requirements.
*   **n8n-mcp Server:** For the "Integrated" method, the n8n-mcp server will be a key component, providing a bridge between Gemini and the n8n API.

## Final Recommendations

*   **For Prototyping, Debugging, and Visual Flow:** Use the n8n GUI.
*   **For CI/CD, GitOps, and Stateless Deployment:** Use the "Scripted" API Method.
*   **For AI-Native Development and Programmatic Control:** Use the "Integrated" MCP Method.
