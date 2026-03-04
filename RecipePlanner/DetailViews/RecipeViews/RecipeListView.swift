//
// RecipeListView.swift
// RecipePlanner
//
// Created by Kartik Krishnan on 08.10.25.
//
import SwiftUI
import SwiftData

/// A presentational view that displays a scrollable list of recipes.
///
/// This view is decoupled from the data persistence layer and relies on its parent view
/// to provide the list of ``Recipe`` objects and to handle all user interactions via
/// action closures (e.g., toggling a favorite state, deleting, or selecting for edit).
struct RecipeListView: View {
    /// The array of ``Recipe`` objects to be displayed in the list.
    let recipes: [Recipe]
    
    /// A flag indicating if the list content originates from an external API call rather than local storage.
    let isFromApi: Bool
    
    /// The action to perform when a user taps the favorite button on a recipe cell.
    /// - Parameter: The ``Recipe`` instance whose favorite state should be toggled.
    let onToggleFavourite: (Recipe) -> Void
    
    /// The action to perform when the user initiates a swipe-to-delete action on the list.
    /// - Parameter: An `IndexSet` indicating the indices of the recipes to be deleted.
    let onListDelete: (IndexSet) -> Void
    
    /// The action to perform when a user taps a recipe cell to view its details or edit it.
    /// - Parameter: The ``Recipe`` instance that was selected.
    let onSelectForEdit: (Recipe) -> Void
    
    /// The action to perform when a user saves a newly fetched recipe to local storage.
    /// - Parameter: The ``Recipe`` instance to be saved.
    let onSave: (Recipe) -> Void
    
    /// The content and behavior of the view.
    var body: some View {
        List {
            ForEach(recipes) { recipe in
                // RecipeCellView is assumed to handle the individual cell display and nested actions.
                RecipeCellView(
                    recipe: recipe,
                    isFavourite: recipe.isFav,
                    isFromApi: isFromApi,
                    onSelect: {
                        onSelectForEdit(recipe)
                    },
                    onToggleFavourite: {
                        onToggleFavourite(recipe)
                    },
                    onSave: {
                        onSave(recipe)
                    }
                )
                .listRowSeparator(.hidden)
            }
            // Attaches the deletion action to the ForEach loop.
            .onDelete(perform: onListDelete)
        }
        .listStyle(.plain)
        .padding(20)
    }
}
