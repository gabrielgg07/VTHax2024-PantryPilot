import requests
from dotenv import load_dotenv
import os
import random
from typing import List
from llm_call import *
from testVision import cv_model_call


# Load environment variables from .env file
load_dotenv()

# Get the API key from the .env file
api_key = os.getenv("SPOONACULAR_API_KEY")


def execute_recipe_search(dietary_restrictions: List[str]):

    ingredients = cv_model_call()
    print(ingredients)

    # Define the Spoonacular API URL
    url = f"https://api.spoonacular.com/recipes/findByIngredients?ingredients={ingredients}&number=5&apiKey={api_key}"

    # Make the request
    response = requests.get(url)
    recipe = random.choice(response.json())

    recipe_title = recipe.get('title', 'Untitled Recipe')  # Get recipe title
    recipe_instructions = recipe.get('instructions', 'No instructions provided.')  # Get recipe instructions
    # Check if 'image' field is present in the recipe
    recipe_image_url = recipe.get('image', None)
    if recipe_image_url:
        print("Image URL found:", recipe_image_url)
    else:
        print("No image URL found in the recipe data.")


    # Prepare the used and missed ingredients and call LLM for each recipe
    used_ingredients = [
        f"{ingredient['name']} ({ingredient['amount']} {ingredient['unit']})"
        for ingredient in recipe['usedIngredients']
    ]
    missed_ingredients = [
        f"{ingredient['name']} ({ingredient['amount']} {ingredient['unit']})"
        for ingredient in recipe['missedIngredients']
    ]

    # Combine used and missed ingredients into a prompt
    used_str = ", ".join(used_ingredients)
    missed_str = ", ".join(missed_ingredients)

    # Debug prints to check used and missed ingredients
    print(f"Used Ingredients: {used_str}")
    print(f"Missed Ingredients: {missed_str}")

    prompt = (
    f"Here is a recipe for {recipe_title}: \n\n"
    f"{recipe_instructions}\n\n"
    f"Used ingredients: {used_str}. \n"
    f"Missing ingredients: {missed_str}. \n"
    f"Please reformat the recipe in a user-friendly way, considering the following dietary restrictions: {', '.join(dietary_restrictions)}. "
    f"Focus on providing healthy substitutions for both the missing and used ingredients. "
    f"Ensure that the substitutions adhere to the dietary restrictions where applicable. "
    f"Organize the recipe with clear headings for ingredients and instructions. Provide a brief introduction to the recipe. Provide suggestions for healthier alternatives where necessary, "
    f"and explain why each substitution is a healthier option."
)

    # Call the function in llm_call.py to generate a recipe with substitutions
    result = generate_recipe_with_substitutions(recipe['title'], prompt)

    
    return result, recipe_image_url

