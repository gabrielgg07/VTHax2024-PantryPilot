import SwiftUI

struct RecipeDetailView: View {
    var recipeName: String // The name of the recipe to display
    var imageURL: String // The URL of the image to display

    @State private var displayedText = "" // State to hold the text being displayed
    @State private var timer: Timer? = nil

    var body: some View {
        ScrollView {
            VStack(spacing: 0) { // Remove spacing to ensure full image coverage
                // Display the recipe image
                AsyncImage(url: URL(string: imageURL)) { phase in
                    switch phase {
                    case .empty:
                        // Placeholder while the image is loading
                        Color.gray.opacity(0.1)
                            .edgesIgnoringSafeArea(.top) // Extend to the top of the screen
                            .frame(maxWidth: .infinity, maxHeight: 300) // Fixed height for the image
                            .cornerRadius(20) // Apply rounded corners
                            .padding(.horizontal) // Add horizontal padding
                    case .success(let image):
                        // Display the loaded image
                        image
                            .resizable()
                            .scaledToFill() // Ensure the image fills the space
                            .frame(maxWidth: .infinity, maxHeight: .infinity) // Fixed height for the image
                            .clipped() // Clip the image to maintain the aspect ratio
                            .cornerRadius(20) // Apply rounded corners
                            .edgesIgnoringSafeArea(.top) // Extend to the top of the screen
                            .padding(20)
                            //.padding(.trailing)
                    case .failure:
                        // Display an error placeholder if the image failed to load
                        Color.red
                            .frame(maxWidth: .infinity, maxHeight: 300) // Fixed height for the image
                            .overlay(
                                Text("Failed to load image")
                                    .foregroundColor(.white)
                            )
                            .cornerRadius(20) // Apply rounded corners
                            .edgesIgnoringSafeArea(.top) // Extend to the top of the screen
                            .padding(.horizontal) // Add horizontal padding
                    @unknown default:
                        EmptyView()
                    }
                }.edgesIgnoringSafeArea(.top)

                // Display the recipe name with typewriter effect
                Text(displayedText)
                    .font(.custom("Helvetica Neue", size: 22)) // Slightly larger font size
                    .fontWeight(.light) // Lighter weight for a skinnier look
                    .padding()
                    .padding(.horizontal, 20) // Add horizontal padding around the text
                    .padding(.top, 10) // Add top padding for more space
                    .padding(.bottom, 10) // Add bottom padding for more space
                    .onAppear(perform: startTypewriterEffect) // Start typewriter effect when the view appears

                Spacer() // Add some spacing to center the text
            }
            .background(Color.white) // Set background to white to avoid invisible content
        }
    }
    
    // Function to start the typewriter effect
    private func startTypewriterEffect() {
        let fullText = recipeName
        displayedText = ""
        
        // Create a timer to add one character at a time
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
            if displayedText.count < fullText.count {
                let nextIndex = fullText.index(fullText.startIndex, offsetBy: displayedText.count)
                displayedText += String(fullText[nextIndex])
            } else {
                timer.invalidate() // Stop the timer when all characters are displayed
            }
        }
    }
}

struct IgnoreTopSafeArea: ViewModifier {
    func body(content: Content) -> some View {
        content
            .edgesIgnoringSafeArea(.top)
    }
}

// Extension for easier us
extension View {
    func ignoreTopSafeArea() -> some View {
        self.modifier(IgnoreTopSafeArea())
    }
}
