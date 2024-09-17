import SwiftUI

struct DietaryRestrictions: View {
    @State private var storedImage: UIImage? = nil
    
    // Track the selected options for each dropdown
    @State private var selectedOptions1: [String] = []
    @State private var selectedOptions2: [String] = []
    @State private var selectedOptions3: [String] = []
    @State private var selectedOptions4: [String] = []
    
    // Control the dropdown visibility
    @State private var showDropdown1 = false
    @State private var showDropdown2 = false
    @State private var showDropdown3 = false
    @State private var showDropdown4 = false
    
    // Options for each dropdown
    let options1 = ["Peanut/Treenuts", "Shellfish", "Eggs", "Fish"]
    let options2 = ["Gluten-Free", "Lactose-Free", "Dairy-Free", "Sugar-Free"]
    let options3 = ["Vegan", "Vegetarian", "Halal", "Kosher", "Low-Sodium", "Low-Carb/Keto"]
    let options4 = ["High-Protein", "Paleo", "Low-Carb"]
    
    var body: some View {
        VStack {
            Text("Dietary Restrictions")
                .font(.largeTitle)
                .padding()
            
            // LazyVStack for vertical scrollable dropdowns
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Dropdown 1
                    dropdownView(title: "Allergies?", selectedOptions: $selectedOptions1, options: options1, showDropdown: $showDropdown1)
                    
                    // Dropdown 2
                    dropdownView(title: "Ingredient-Free diets", selectedOptions: $selectedOptions2, options: options2, showDropdown: $showDropdown2)
                    
                    // Dropdown 3
                    dropdownView(title: "Diet Options", selectedOptions: $selectedOptions3, options: options3, showDropdown: $showDropdown3)
                    
                    // Dropdown 4
                    dropdownView(title: "Fitness Diets", selectedOptions: $selectedOptions4, options: options4, showDropdown: $showDropdown4)
                }
                .padding()
            }
            .onTapGesture {
                // Collapse all dropdowns when tapping outside
                showDropdown1 = false
                showDropdown2 = false
                showDropdown3 = false
                showDropdown4 = false
            }
        }
        .padding()
        .onAppear {
            loadRestrictions() // Load saved restrictions when the view appears
        }
        .onChange(of: selectedOptions1) { _ in saveRestrictions() } // Save restrictions when they change
        .onChange(of: selectedOptions2) { _ in saveRestrictions() }
        .onChange(of: selectedOptions3) { _ in saveRestrictions() }
        .onChange(of: selectedOptions4) { _ in saveRestrictions() }
    }
    
    // Custom dropdown view
    private func dropdownView(title: String, selectedOptions: Binding<[String]>, options: [String], showDropdown: Binding<Bool>) -> some View {
        VStack(alignment: .leading) {
            Text(title)
            Button(action: {
                // Toggle dropdown visibility
                showDropdown.wrappedValue.toggle()
            }) {
                Text(selectedOptions.wrappedValue.isEmpty ? "Select options" : selectedOptions.wrappedValue.joined(separator: ", "))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(5)
            }
            if showDropdown.wrappedValue {
                // Show dropdown options
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        // Toggle selection
                        if selectedOptions.wrappedValue.contains(option) {
                            selectedOptions.wrappedValue.removeAll { $0 == option }
                        } else {
                            selectedOptions.wrappedValue.append(option)
                        }
                        saveRestrictions() // Save changes
                    }) {
                        HStack {
                            CheckboxView(isSelected: selectedOptions.wrappedValue.contains(option)) {}
                            Text(option)
                                .padding(.leading)
                                .onTapGesture {
                                    // Toggle selection when text is clicked
                                    if selectedOptions.wrappedValue.contains(option) {
                                        selectedOptions.wrappedValue.removeAll { $0 == option }
                                    } else {
                                        selectedOptions.wrappedValue.append(option)
                                    }
                                    saveRestrictions() // Save changes
                                }
                        }
                    }
                }
            }
        }
        .background(Color.white) // To prevent the button from collapsing when clicking on it
    }
    
    // Custom checkbox view to manage selection state
    struct CheckboxView: View {
        var isSelected: Bool
        var action: () -> Void
        
        var body: some View {
            Button(action: action) {
                Image(systemName: isSelected ? "checkmark.square" : "square")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .foregroundColor(isSelected ? .black : .white) // Text color for selected state
                    .background(Color.white) // Background color for the checkbox
                    .border(Color.black, width: 1) // Border color and width
                    .shadow(radius: 2) // Shadow for the checkbox
            }
            .buttonStyle(BorderlessButtonStyle())
        }
    }
    
    // Function to save restrictions to a JSON file
    private func saveRestrictions() {
        let restrictions = [
            "Allergies": selectedOptions1,
            "Ingredient-Free": selectedOptions2,
            "Diet Options": selectedOptions3,
            "Fitness Diets": selectedOptions4
        ]
        
        let jsonData = try? JSONEncoder().encode(restrictions)
        
        if let data = jsonData {
            let filename = getDocumentsDirectory().appendingPathComponent("dietary_restrictions.json")
            do {
                try data.write(to: filename)
                print("Restrictions saved successfully.")
            } catch {
                print("Failed to save restrictions: \(error.localizedDescription)")
            }
        }
    }
    
    // Function to load restrictions from the JSON file
    private func loadRestrictions() {
        let filename = getDocumentsDirectory().appendingPathComponent("dietary_restrictions.json")
        
        do {
            let data = try Data(contentsOf: filename)
            if let loadedRestrictions = try? JSONDecoder().decode([String: [String]].self, from: data) {
                // Split loaded restrictions back into categories
                selectedOptions1 = loadedRestrictions["Allergies"] ?? []
                selectedOptions2 = loadedRestrictions["Ingredient-Free"] ?? []
                selectedOptions3 = loadedRestrictions["Diet Options"] ?? []
                selectedOptions4 = loadedRestrictions["Fitness Diets"] ?? []
                
                print("Restrictions loaded successfully.")
            }
        } catch {
            print("Failed to load restrictions: \(error.localizedDescription)")
        }
    }
    
    // Function to get the document directory path
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
