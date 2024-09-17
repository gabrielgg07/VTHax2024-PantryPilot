import os
from dotenv import load_dotenv
import glob 
import requests
from typing import List

# Load environment variables from .env file
load_dotenv()
subscription_key = os.getenv("AZURE_SUBSCRIPTION_KEY")


# Set up the endpoint and headers
url = "https://vthaxpredictionmodel2.cognitiveservices.azure.com/customvision/v3.0/Prediction/c72b30d5-6946-45de-ad62-0a961cf38006/detect/iterations/Iteration2/image"
headers = {
    "Prediction-Key": subscription_key,
    "Content-Type": "application/octet-stream"
}

def get_most_recent_image(directory: str) -> str:
    # Use glob to find all files in the directory
    list_of_files = glob.glob(f"{directory}/*")
    
    if not list_of_files:
        raise FileNotFoundError(f"No files found in the directory: {directory}")
    
    # Get the most recent file based on modification time
    latest_file = max(list_of_files, key=os.path.getmtime)
    
    return latest_file



def cv_model_call()-> List[str]:
    # Open the image file and read the content
    image_path = get_most_recent_image('uploads')
    print(image_path)
    with open(image_path, "rb") as image_data:
        # Make the request with image file as the body
        response = requests.post(url, headers=headers, data=image_data)

    # Check the response
    if response.status_code == 200:
        # Parse JSON response
        predictions = response.json()

        detected_ingredients = []
        # Print detected ingredients in a structured format
        print("Detected Ingredients:\n")
        for prediction in predictions['predictions']:
            tag_name = prediction['tagName']
            probability = prediction['probability']
            # Print out predictions with a meaningful probability (e.g., > 0.1)
            if "[Auto-Generated]" not in tag_name and probability > 0.1:
                print(f"Ingredient: {tag_name}, Confidence: {probability:.2%}")
                detected_ingredients.append(tag_name)
            
        return detected_ingredients
    else:
        print(f"Error: {response.status_code}, {response.text}")
        