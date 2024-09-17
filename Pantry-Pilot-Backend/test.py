import requests

# URL for the Flask API (make sure it's running)
url = 'http://127.0.0.1:5000/api/upload-image'

# Path to the image file you want to upload
image_path = 'app_images/fridge.jpeg'

# Open the image in binary mode
with open(image_path, 'rb') as image_file:
    # Create a dictionary for the files to upload
    files = {'file': image_file}

    # Make the POST request to upload the image
    response = requests.post(url, files=files)

# Check the response from the server
if response.status_code == 200:
    print(f"Success: {response.json()}")
else:
    print(f"Error: {response.status_code}, {response.text}")