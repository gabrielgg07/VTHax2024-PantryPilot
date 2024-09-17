import SwiftUI

struct CustomCardView: View {
    // Parameters for customizing the card
    var width: CGFloat
    var height: CGFloat
    var backgroundColor: Color
    var cornerRadius: CGFloat
    var title: String
    var caption: String
    var imageURL: String // URL string for the image to display on the card

    var body: some View {
        ZStack {
            // Asynchronously load the image from the web
            AsyncImage(url: URL(string: imageURL)) { phase in
                switch phase {
                case .empty:
                    // Placeholder while the image is loading
                    Color.gray.opacity(0.1)
                        .frame(width: width, height: height)
                        .cornerRadius(cornerRadius)
                case .success(let image):
                    // Display the loaded image
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: width, height: height)
                        .clipped()
                        .cornerRadius(cornerRadius)
                case .failure:
                    // Display an error placeholder if the image failed to load
                    Color.red
                        .frame(width: width, height: height)
                        .overlay(
                            Text("Failed to load image")
                                .foregroundColor(.white)
                        )
                        .cornerRadius(cornerRadius)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: width, height: height)
            .cornerRadius(cornerRadius)
            .shadow(radius: 5)

            // White bar at the bottom 1/4 of the card
            VStack {
                Spacer() // Push the bar to the bottom
                Rectangle()
                    .fill(Color.white)
                    .frame(height: height / 4) // Make the bar occupy 1/4 of the card height
                    .overlay(
                        Text(title)
                            .font(.headline)
                            .padding()
                            .foregroundColor(.black),
                        alignment: .leading
                    )
                    //.overlay(
                        //Text(caption)
                          //  .font(.caption)
                            //.padding()
                            //.foregroundColor(.gray),
                        //alignment: .trailing
                    //)
            }
            .frame(width: width, height: height)
            .cornerRadius(cornerRadius)
        }
        .frame(width: width, height: height) // Card dimensions
        .cornerRadius(cornerRadius)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5) // Card shadow
    }
}
