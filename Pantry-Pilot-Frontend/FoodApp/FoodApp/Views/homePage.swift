import SwiftUI
import PhotosUI
import UIKit

struct HomePage: View {
    let userName: String
    @State private var selectedTab = 1 // Track selected tab
    @State private var isImagePickerPresented = false // Track whether the image picker is presented
    @State private var isCameraPickerPresented = false // Track whether the camera picker is presented
    @State private var selectedImage: UIImage? // Store up to 5 selected images
    @State private var showImageSourceOptions = false // Track whether to show image source options
    @State private var showError = false // Track whether to show error for max images
    
    // New state variables for handling recipe detail view
        @State private var selectedRecipe: Recipe? // Track the selected recipe
        @State private var isDetailPresented = false // State to control presentation of RecipeDetailView


    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with background and rounded bottom edges
                ZStack {
                    // Background with rounded bottom edges
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.green.opacity(0.6)) // Light green background color
                        .edgesIgnoringSafeArea(.top)
                        .frame(height: 140) // Fixed height to contain all elements

                    // Header content (Title and Tabs)
                    VStack {
                        // Header title
                        Text("Welcome, \(userName)")
                            .font(.title)
                            .foregroundColor(.white) // White text color
                            .padding(.top, 20) // Top padding for title

                        // Tabs
                        HStack(spacing: 20) {
                            // Tab 1: Images
                            Button(action: {
                                showImageSourceOptions = true
                            }) {
                                VStack {
                                    Image(systemName: "photo")
                                        .font(.title)
                                        .foregroundColor(.white) // White icon color
                                    Text("Scan Food")
                                        .font(.caption)
                                        .foregroundColor(.white) // White text color
                                }
                            }
                            .frame(maxWidth: .infinity)

                            // Tab 2: Recipes
                            Button(action: {
                                selectedTab = 1
                            }) {
                                VStack {
                                    Image(systemName: "book")
                                        .font(.title)
                                        .foregroundColor(.white) // White icon color
                                    Text("Recipes")
                                        .font(.caption)
                                        .foregroundColor(.white) // White text color
                                }
                            }
                            .frame(maxWidth: .infinity)

                            // Tab 3: Diet
                            Button(action: {
                                selectedTab = 2
                            }) {
                                VStack {
                                    Image(systemName: "leaf")
                                        .font(.title)
                                        .foregroundColor(.white) // White icon color
                                    Text("Diet")
                                        .font(.caption)
                                        .foregroundColor(.white) // White text color
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.vertical, 10) // Padding for the tabs
                    }
                    .padding(.horizontal, 20) // Padding on left and right
                }
                .padding(.bottom, -10) // Adjusts padding below the header to align with the divider
                
                // Content Area Below the Divider
                VStack {
                     if selectedTab == 1 {
                        // Content for "Recipes" Section
                         Recipes(selectedRecipe: $selectedRecipe)
                    } else if selectedTab == 2 {
                        // Content for "Diet" Section
                        DietaryRestrictions()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
            .actionSheet(isPresented: $showImageSourceOptions) { // Action sheet to choose image source
                        ActionSheet(
                            title: Text("Choose Image Source"),
                            message: Text("Select an image from your photo library or take a new one."),
                            buttons: [
                                .default(Text("Camera")) {
                                    isImagePickerPresented = true
                                    isCameraPickerPresented = true // Set the source type to camera
                                },
                                .default(Text("Photo Library")) {
                                    isImagePickerPresented = true
                                    isCameraPickerPresented = false // Set the source type to photo library
                                },
                                .cancel()
                            ]
                        )
                    }
            .sheet(isPresented: $isImagePickerPresented) { // Present the image picker sheet
                            CustomImagePicker(selectedImage: $selectedImage, sourceType: isCameraPickerPresented ? .camera : .photoLibrary)
                        }
            .fullScreenCover(isPresented: $isDetailPresented) { // Present the RecipeDetailView in full screen
                if let recipe = selectedRecipe {
                    RecipeDetailView(recipeName: recipe.title, imageURL: recipe.imageURL)
                }
            }
                        .navigationBarHidden(true)
        }
    }
}
// Custom Image Picker using UIImagePickerController
struct CustomImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage? // Bind the selected image
    var sourceType: UIImagePickerController.SourceType // Source type (camera or photo library)

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: CustomImagePicker

        init(_ parent: CustomImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image // Update the selected image
                uploadImage(image) // Call the function to upload the image
            }
            picker.dismiss(animated: true)
        }
        
        
        func uploadImage(_ image: UIImage) {
            // Resize the image to ensure it is less than 4 MB
            let resizedImage = resizeImage(image, targetSize: CGSize(width: 1024, height: 1024))
            
            guard let imageData = resizedImage.jpegData(compressionQuality: 0.7) else {
                print("Error: Unable to convert UIImage to JPEG data.")
                return
            }

            let url = URL(string: "https://vthacks2024backend.onrender.com/api/upload-image")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let boundary = UUID().uuidString
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            var body = Data()
            
            // Add image data to the request body
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"uploadedImage.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
            
            // Load and clear dietary restrictions from file
            let dietaryRestrictions = loadDietaryRestrictions()
            //clearDietaryRestrictions()
            
            // Add dietary restrictions to the request body
            for restriction in dietaryRestrictions {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"dietary_restrictions[]\"\r\n".data(using: .utf8)!)
                body.append("\r\n".data(using: .utf8)!)
                body.append(restriction.data(using: .utf8)!)
                body.append("\r\n".data(using: .utf8)!)
            }
            
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
            
            let task = URLSession.shared.uploadTask(with: request, from: body) { data, response, error in
                if let error = error {
                    print("Error uploading image: \(error)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Server error or unexpected response.")
                    return
                }
                
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    // Print the server response
                    print("Server response: \(responseString)")
                    
                    // Parse the server response into Recipe structure
                    if let serverResponse = try? JSONDecoder().decode(ServerResponse.self, from: data) {
                        let newRecipe = Recipe(
                            title: serverResponse.result ?? "Unknown Title",
                            caption: serverResponse.result ?? "No caption provided",
                            imageURL: serverResponse.image_url ?? ""
                        )
                        
                        // Load existing recipes, append the new recipe, and save
                        var existingRecipes = self.loadRecipesFromFile()
                        existingRecipes.append(newRecipe)
                        self.saveRecipesToFile(existingRecipes)
                        
                        // Load and print the saved recipes
                        let savedRecipes = self.loadRecipesFromFile()
                        print("Saved Recipes: \(savedRecipes)")
                    } else {
                        print("Error parsing server response.")
                    }
                }
            }
            task.resume()
        }
        
        struct ServerResponse: Codable {
            let image_url: String?
            let result: String?
        }

        
        func saveRecipesToFile(_ recipes: [Recipe]) {
            let fileManager = FileManager.default
            guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            let fileURL = documentsURL.appendingPathComponent("recipes.json")
            
            do {
                // Encode the recipes array to JSON data
                let data = try JSONEncoder().encode(recipes)
                // Write the JSON data to the file
                try data.write(to: fileURL)
                print("Recipes saved successfully.")
            } catch {
                print("Error saving recipes: \(error.localizedDescription)")
            }
        }
        
        func loadRecipesFromFile() -> [Recipe] {
            let fileManager = FileManager.default
            guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return [] }
            let fileURL = documentsURL.appendingPathComponent("recipes.json")
            
            do {
                // Check if the file exists
                if fileManager.fileExists(atPath: fileURL.path) {
                    // Load the JSON data from the file
                    let data = try Data(contentsOf: fileURL)
                    // Decode the JSON data to an array of Recipe objects
                    let recipes = try JSONDecoder().decode([Recipe].self, from: data)
                    return recipes
                } else {
                    print("No recipes file found.")
                    return []
                }
            } catch {
                print("Error loading recipes: \(error.localizedDescription)")
                return []
            }
        }
        func clearDietaryRestrictions() {
            let fileManager = FileManager.default
            guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            let fileURL = documentsURL.appendingPathComponent("dietary_restrictions.json")
            
            // Clear or reset the file content
            do {
                try "".write(to: fileURL, atomically: true, encoding: .utf8)
                print("Dietary restrictions file cleared.")
            } catch {
                print("Error clearing dietary restrictions file: \(error.localizedDescription)")
            }
        }
        
    


        func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
            let size = image.size
            
            let widthRatio  = targetSize.width  / image.size.width
            let heightRatio = targetSize.height / image.size.height
            
            // Determine what our new size will be
            var newSize: CGSize
            if widthRatio > heightRatio {
                newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            } else {
                newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
            }
            
            // Resize the image
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage!
        }
        
        func loadDietaryRestrictions() -> [String] {
            let fileManager = FileManager.default
            guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return [] }
            let fileURL = documentsURL.appendingPathComponent("restrictions.json")
            
            // Load existing data from the file if it exists
            if let data = try? Data(contentsOf: fileURL),
               let decoded = try? JSONDecoder().decode([String].self, from: data) {
                return decoded
            }
            
            // Return an empty array if the file does not exist or is empty
            return []
        }
    }
}




//struct homePage_Previews: PreviewProvider {
//    static var previews: some View {
//        HomePage(userName: String)
//    }
//}

import Foundation

struct Recipe: Identifiable, Codable {
    let id = UUID() // Unique identifier for each recipe
    let title: String
    let caption: String
    let imageURL: String
}


