//
// InventoryView.swift
// RecipePlanner
//
// Created by Kartik Krishnan on 08.10.25.
//
import SwiftUI
import SwiftData

/// The main container view for managing the user's grocery inventory.
///
/// This view handles data fetching, filtering, adding new items, and editing existing items
/// using the **SwiftData** persistence framework. It displays a list of ``Grocery`` items
/// sorted by their expiration date.
struct InventoryView: View {
    // MARK: - SwiftData Integration
    
    /// The **SwiftData** context, injected from the environment, used for persisting and deleting grocery data.
    @Environment(\.modelContext) var modelContext
    
    /// A live collection of all ``Grocery`` objects in the store, sorted by their `expirationDate`.
    @Query(sort: \Grocery.expirationDate) var groceriers: [Grocery]

    // MARK: - View State
    
    /// The text entered by the user in the search bar, used to filter the grocery list.
    @State private var searchText = ""
    
    /// Controls the presentation of the sheet used for adding a new grocery item.
    @State private var showingAddGrocerySheet = false
    
    /// The selected ``Grocery`` object to be edited. When this is non-nil, the detail sheet is presented.
    @State private var selectedGroceryToEdit: Grocery?

    // MARK: - Computed Properties
    
    /// An array of groceries filtered based on the current search text.
    private var filteredGroceries: [Grocery] {
        let baseGroceries = groceriers
        if searchText.isEmpty {
            return baseGroceries
        } else {
            // Filters the list, keeping items whose name contains the search text (case- and accent-insensitive).
            return baseGroceries.filter { $0.name.localizedStandardContains(searchText) }
        }
    }
    
    // MARK: - Actions
    
    /// Creates and inserts a new ``Grocery`` object into the **SwiftData** context.
    ///
    /// This function separates the creation logic from the view's body for better readability.
    ///
    /// - Parameters:
    ///   - newName: The name of the grocery item.
    ///   - newStock: The current quantity of the item.
    ///   - newExpirationDate: The optional expiration date.
    func saveNewGrocery(newName: String, newStock: Int, newExpirationDate: Date?) {
        let newGrocery = Grocery(
            name: newName,
            stock: newStock,
            expirationDate: newExpirationDate
        )
        modelContext.insert(newGrocery)
    }
    
    // MARK: - View Body
    
    /// The content and behavior of the view.
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    // Displays the list of filtered groceries and handles user actions.
                    GroceryListView(
                        groceries: filteredGroceries,
                        onListDelete: { indexSet in
                            // Deletes items from the model context based on the indices of the filtered list.
                            indexSet.map { filteredGroceries[$0] }.forEach(modelContext.delete)
                        },
                        onSelectForEdit: { grocery in
                            // Sets the state property to show the detail sheet for editing.
                            selectedGroceryToEdit = grocery
                        }
                    )
                    // Presents the detail view for editing when a grocery item is selected.
                    .sheet(item: $selectedGroceryToEdit) { groceryToEdit in
                        GroceryDetailView(
                            name: groceryToEdit.name,
                            stock: groceryToEdit.stock,
                            expirationDate: groceryToEdit.expirationDate,
                            onSave: { newName, newStock, newExpirationDate in
                                // Updates the properties of the existing SwiftData object directly.
                                groceryToEdit.name = newName
                                groceryToEdit.stock = newStock
                                groceryToEdit.expirationDate = newExpirationDate
                            },
                            onDismiss: {
                                // Dismisses the sheet by clearing the selection.
                                selectedGroceryToEdit = nil
                            }
                        )
                    }
                }
                
                // Overlay for the action button (Add Grocery).
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        /// Button to present the sheet for adding a new grocery item.
                        CircleButton(buttonImage: "document.badge.plus.fill", onCall: { showingAddGrocerySheet = true })
                            .sheet(isPresented: $showingAddGrocerySheet) {
                                // Presents the detail view initialized for a new, blank grocery item.
                                GroceryDetailView(
                                    name: "",
                                    stock: 0,
                                    expirationDate: nil,
                                    onSave: { newName, newStock, newExpirationDate in
                                        saveNewGrocery(newName: newName, newStock: newStock, newExpirationDate: newExpirationDate)
                                    },
                                    onDismiss: {
                                        // Dismisses the sheet by setting the boolean state back to false.
                                        showingAddGrocerySheet = false
                                    },
                                    addGrocery: true
                                )
                            }
                    }
                }
                .padding(25)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text("Groceries")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search for a grocery")
    }
}

#Preview {
    InventoryView()
        .modelContainer(SampleData.shared.modelContainer)
}
