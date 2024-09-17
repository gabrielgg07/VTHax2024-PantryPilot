import SwiftUI

struct HeaderView: View {
    var title: String // The title text for the header
    var iconNames: [String] // The system names of the icons to display in the header
    @Binding var selectedTab: Int // Binding to the selected tab index

    var body: some View {
        VStack {
            // Title
            Text(title)
                .font(.largeTitle)
                .padding(.top, 60) // Top padding for the header

            // Tabs
            HStack {
                ForEach(0..<iconNames.count, id: \.self) { index in
                    Button(action: {
                        selectedTab = index
                    }) {
                        VStack {
                            Image(systemName: iconNames[index])
                                .font(.title) // Icon size
                            Text(getTabName(for: index))
                                .font(.caption)
                        }
                    }
                    .foregroundColor(selectedTab == index ? .blue : .gray)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 20) // Padding between title and tabs
            .padding(.bottom, 20) // Additional padding below tabs

            // Divider
            Divider()
                .frame(height: 1)
                .background(Color.gray)
                .padding(.horizontal, -20) // Extend the divider width
        }
    }

    // Helper function to get the tab name based on the index
    private func getTabName(for index: Int) -> String {
        switch index {
        case 0: return "Images"
        case 1: return "Recipes"
        case 2: return "Diet"
        default: return ""
        }
    }
}
