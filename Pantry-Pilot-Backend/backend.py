from flask import Flask, render_template, request, jsonify
import os
from dotenv import load_dotenv
from werkzeug.utils import secure_filename
from recipe import execute_recipe_search

# Load environment variables from .env
load_dotenv()

app = Flask(__name__)

# Folder to store uploaded images
UPLOAD_FOLDER = 'uploads/'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

# Allowed file extensions for images
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}

# Helper function to check if the file has an allowed extension
def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

# Helper function to check if the file has an allowed extension
def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

# Image upload route
@app.route('/api/upload-image', methods=['POST'])
def upload_image():
    # Check if the post request has the file part
    if 'file' not in request.files:
        return jsonify({"error": "No file part"}), 400

    file = request.files['file']

    # If no file is selected
    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400

    # Check if the file is allowed
    if file and allowed_file(file.filename):
        # Secure the filename and save it
        filename = secure_filename(file.filename)
        file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
        
        # Get dietary restrictions from the request form (as a comma-separated string)
        dietary_restrictions_str = request.form.get('dietary_restrictions', '')  # Default to empty string if not provided
        
        # Split the dietary restrictions into a list
        dietary_restrictions = [item.strip() for item in dietary_restrictions_str.split(',') if item.strip()]

        # Pass the dietary restrictions to the function that processes the recipe
        result, image_url = execute_recipe_search(dietary_restrictions)

        # Return the result as a string
        return jsonify({
            "message": f"File uploaded successfully: {filename}",
            "result": result,
            "image_url": image_url
        }), 200

    return jsonify({"error": "File type not allowed"}), 400



# Home route
@app.route('/')
def index():
    return render_template('index.html')

# Example API route
@app.route('/api/hello', methods=['GET'])
def hello_api():
    name = request.args.get('name', 'World')
    return jsonify({"message": f"Hello, {name}!"})

# Error handling route
@app.errorhandler(404)
def page_not_found(e):
    return render_template('404.html'), 404

# Run the app
if __name__ == '__main__':
    app.run(debug=True)