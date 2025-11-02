import sys

try:
    import requests
    print("Success: Python and the requests library are working correctly!")
    print(f"Python version: {sys.version}")
    print(f"Requests version: {requests.__version__}")
except ImportError:
    print("Error: The 'requests' library is not installed.")
    print("Please install it by running: pip install requests")
except Exception as e:
    print(f"An unexpected error occurred: {e}")
