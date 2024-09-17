import SwiftUI

struct WelcomeView: View {
    @Binding var loggedIn: Bool // Binding to control the login state
    @Binding var userName: String // Binding to store the entered name

    var body: some View {
        VStack {
            Spacer()
                .frame(height: 80)

            // Welcome message positioned closer to the top
            Text("PantryPilot")
                .font(.custom("HelveticaNeue-SemiBold", size: 34))
                .foregroundColor(Color.green)
                .padding(.bottom, 10)

            Spacer()
                .frame(height: 20)

            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .padding(.bottom, 20)

            ZStack {
                // Background with shadow
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 2)

                // TextField with custom styling
                TextField("Enter your name", text: $userName)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 10)
                    .font(.custom("Roboto-Light", size: 18))
                    .foregroundColor(Color.black)
            }
            .frame(height: 50)
            .padding(.horizontal, 40)

            Button(action: {
                loggedIn = true // Update the loggedIn state
            }) {
                Text("LOGIN")
                    .font(.custom("HelveticaNeue-SemiBold", size: 16))
                    .padding()
                    .frame(width: 280, height: 40)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
            }
            .disabled(userName.isEmpty)
            .padding(.top, 30)

            Spacer()
        }
        .padding()
    }
}
