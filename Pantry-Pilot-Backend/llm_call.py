from openai import AzureOpenAI
from dotenv import load_dotenv
import os

# Load environment variables from .env file
load_dotenv()

# Get the API key from the environment variable
api_key = os.getenv("AZURE_OPENAI_API_KEY")

client = AzureOpenAI(
    azure_endpoint="https://vthacks1.openai.azure.com/",
    api_version="2022-12-01",
    api_key= api_key,
    )

if api_key is None:
    raise ValueError("API key not found. Make sure to set AZURE_OPENAI_API_KEY in your .env file.")

# Set the deployment name (this is the name you gave to the GPT-3.5 Turbo deployment)
model_name = "gpt-35-turbo"
    
deployment_name='vthacks1'

# Function to generate a recipe with substitutions
def generate_recipe_with_substitutions(recipe_title, prompt)-> str:
    # Send the prompt to the OpenAI GPT-3.5 Turbo model
    completion = client.completions.create(
        model=deployment_name,
        prompt=prompt,
        max_tokens=500,  # Limiting the response length
        temperature=0.5 
    )

    # Extract the generated text from the completion
    generated_text = completion.choices[0].text.strip()

    # Format the result as a string
    result = f"Recipe: {recipe_title}\n{generated_text}\n---\n"

    # Return the formatted string
    return result

