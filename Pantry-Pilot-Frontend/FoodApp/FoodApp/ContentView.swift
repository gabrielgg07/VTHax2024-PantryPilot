import SwiftUI

struct ContentView: View {
    @State private var loggedIn: Bool = false // Use @State to track if the user is logged in
       @State private var userName: String = "" // Use @State to store the user's name
    var body: some View {
        NavigationView {
            VStack {
                if loggedIn == false {
                    // Show the WelcomeView first
                    WelcomeView(loggedIn: $loggedIn, userName: $userName)
                } else {
                    // After entering the name, show the homePage
                    HomePage(userName: userName) // Pass the user name to homePage
                }
            }
        }
    }
}
