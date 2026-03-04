//
// GroceryListView.swift
// RecipePlanner
//
// Created by Kartik Krishnan on 11.10.25.
//
import SwiftUI

/// A presentational view that displays a scrollable list of grocery items.
///
/// This view is designed to be highly reusable and purely presentational, relying on its
/// parent view (e.g., ``InventoryView``) to provide the data and handle all user actions
/// via closure callbacks.
struct GroceryListView: View {
    // MARK: - Initial Data
    
    /// The array of ``Grocery`` objects to be displayed in the list.
    let groceries: [Grocery]
    
    // MARK: - Action Closures
    
    /// The action to perform when the user initiates a swipe-to-delete action on the list.
    /// - Parameter: An `IndexSet` indicating the indices of the groceries to be deleted.
    let onListDelete: (IndexSet) -> Void
    
    /// The action to perform when a user taps a grocery item cell to view its details or edit it.
    /// - Parameter: The ``Grocery`` instance that was selected.
    let onSelectForEdit: (Grocery) -> Void
    
    // MARK: - View Body
    
    /// The content and behavior of the view.
    var body: some View {
        List {
            // list all groceries
            ForEach(groceries) { grocery in
                GroceryCellView(
                    name: grocery.name,
                    stock: grocery.stock,
                    expirationDate: grocery.expirationDate,
                    onSelect: {
                        onSelectForEdit(grocery)
                    }
                )
                .listRowSeparator(.hidden)
            }
            // Attaches the deletion action to the list.
            .onDelete(perform: onListDelete)
        }
        .listStyle(.plain)
        .padding(.horizontal, 20)
    }
}
