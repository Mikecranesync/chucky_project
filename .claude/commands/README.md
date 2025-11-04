# Claude Code Slash Commands

This directory contains custom slash commands for the Chucky n8n workflow system.

## Available Commands

- `/chucky-node-builder` - Generate n8n nodes from natural language descriptions
- `/chucky-workflow-validator` - Validate n8n workflow JSON for errors
- `/chucky-doc-generator` - Auto-generate documentation from workflow changes
- `/chucky-troubleshoot-builder` - Create troubleshooting decision trees
- `/chucky-test-scenario` - Generate test scenarios for Discord interactions
- `/chucky-embed-designer` - Design Discord embed templates

## Usage

Each command is defined in a separate markdown file. Commands are invoked in Claude Code CLI using the `/` prefix followed by the command name.

Example:
```bash
/chucky-node-builder "Create a node that parses sensor data"
```
