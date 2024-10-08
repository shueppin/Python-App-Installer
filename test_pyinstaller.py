import requests

print(requests.get('https://example.com').text)

try:
    import PyInstaller
    print("PyInstaller is installed.")
except ImportError:
    print("PyInstaller is not installed.")
