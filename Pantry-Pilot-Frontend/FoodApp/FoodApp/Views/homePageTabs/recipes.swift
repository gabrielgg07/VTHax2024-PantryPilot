import SwiftUI

struct Recipes: View {
    @State var loadedRecipes: [Recipe] = [] // State variable to store loaded recipes
    @Binding var selectedRecipe: Recipe? // Binding to track the selected recipe

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) { // Lazy column with spacing between items
                if loadedRecipes.isEmpty {
                    Text("Loading recipes...") // Show loading message while data loads
                } else {
                    ForEach(loadedRecipes) { recipe in
                        NavigationLink(
                            destination: RecipeDetailView(recipeName: recipe.title, imageURL: recipe.imageURL)
                        ) {
                            CustomCardView(
                                width: 350,
                                height: 220,
                                backgroundColor: Color.white,
                                cornerRadius: 20,
                                title: recipe.title,   // Use the title from loaded data
                                caption: recipe.caption, // Use the caption from loaded data
                                imageURL: recipe.imageURL // Use the image URL from loaded data
                            )
                        }
                        .buttonStyle(PlainButtonStyle()) // Removes default button styling
                    }
                }
            }
            .padding()
        }
        .onAppear {
            loadRecipesFromFile()
        }
    }

    // Function to load the recipes from a file
    func loadRecipesFromFile() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent("recipes.json")

        // Print the path where the app is trying to load the file
        print("Loading recipes from: \(fileURL.path)")
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            var recipes = try decoder.decode([Recipe].self, from: data)
            
            // Reverse the array to display the latest item first
            recipes.reverse()
            
            loadedRecipes = recipes
            
            print("Recipes loaded successfully!")
            for recipe in loadedRecipes {
                print("Title: \(recipe.title), ImageURL: \(recipe.imageURL)")
            }
        } catch {
            print("Failed to load recipes: \(error.localizedDescription)")
        }
    }
}

// Data model for Recipe

