# Python Setup Verification Guide

This guide will walk you through the steps to verify that Python and the necessary `requests` library are correctly installed and configured on your system.

## Step 1: Check if Python is in your PATH

Open your terminal (PowerShell or Command Prompt) and run the following command:

```bash
python --version
```

*   **If you see a version number** (e.g., `Python 3.11.4`), Python is correctly installed and added to your system's PATH. You can proceed to Step 2.
*   **If you see an error** like `'python' is not recognized...`, it means Python is either not installed or not in your PATH. 
    *   **Solution:** Download and install Python from the [official Python website](https://www.python.org/downloads/). **Crucially, during installation, make sure to check the box that says "Add Python to PATH".**

## Step 2: Check if the `requests` Library is Installed

Once you've confirmed Python is installed, run this command in your terminal:

```bash
pip show requests
```

*   **If you see information** about the `requests` library (Name, Version, Summary, etc.), it means the library is installed. You are ready to run the scripts.
*   **If you see a warning** like `Package(s) not found: requests`, it means the library is not installed.
    *   **Solution:** Run the following command to install it:
        ```bash
        pip install requests
        ```

## Step 3: Run the Verification Script

To be absolutely sure everything is working together, I have created a simple test script called `verify_python.py`.

1.  Make sure you are in your `chucky_project` directory in your terminal.
2.  Run the script with this command:

    ```bash
    python verify_python.py
    ```

If you see the output `Success: Python and the requests library are working correctly!`, then your setup is confirmed and you are ready to proceed with the workflow automation tasks.
