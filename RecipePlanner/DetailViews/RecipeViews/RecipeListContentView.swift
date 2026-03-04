//
// RecipeListContentView.swift
// RecipePlanner
//
// Created by Kartik Krishnan on 14.10.25.
//
import SwiftUI
import SwiftData

/// An intermediate view that displays a list of local recipes and manages the presentation
/// of the ``RecipeDetailView`` for editing a selected recipe.
///
/// This view receives the core data and action closures from its parent view (e.g., ``RecipeView``)
/// and passes them down to the presentational ``RecipeListView``.
struct RecipeListContentView: View {
    /// The array of ``Recipe`` objects to be displayed.
    let recipes: [Recipe]

    // MARK: - Core Recipe Actions (Passed from Parent)
    
    /// The action to perform when a user taps the favorite button on a recipe cell.
    let onToggleFavourite: (Recipe) -> Void
    
    /// The action to perform when the user deletes a recipe via the list (swipe-to-delete).
    let onListDelete: (IndexSet) -> Void
    
    /// The action to perform when a new recipe is saved (although this view primarily handles edits).
    let onSave: (Recipe) -> Void

    // MARK: - Ingredient Modification Callbacks
    
    /// The utility function to add an ingredient, received from the parent.
    /// - Parameters:
    ///   - String: The new ingredient text.
    ///   - Binding<[String]>: A binding to the ingredients array being modified.
    let addIngredient: (String, Binding<[String]>) -> Void
    
    /// The utility function to delete ingredients, received from the parent.
    /// - Parameters:
    ///   - IndexSet: The indices to delete.
    ///   - Binding<[String]>: A binding to the ingredients array being modified.
    let deleteIngredients: (IndexSet, Binding<[String]>) -> Void
            
    // MARK: - Internal State
    
    /// The selected ``Recipe`` object to be edited. When non-nil, the edit sheet is presented.
    @State private var selectedRecipeToEdit: Recipe?

    // MARK: - View Body

    var body: some View {
        // Renders the list of recipes.
        RecipeListView(
            recipes: recipes,
            isFromApi: false, // Indicates these are local/saved recipes.
            onToggleFavourite: onToggleFavourite,
            onListDelete: onListDelete,
            // Sets the selected recipe state, triggering the sheet.
            onSelectForEdit: { recipe in
                selectedRecipeToEdit = recipe
            },
            onSave: onSave
        )
        // Presents the detail view when a recipe is selected for editing.
        .sheet(item: $selectedRecipeToEdit) { recipeToEdit in
            RecipeDetailView(
                // Pass the current property values to the detail view's internal state.
                name: recipeToEdit.name,
                time: recipeToEdit.time ?? -1, // Use -1 as a placeholder for null time if needed.
                ingredients: recipeToEdit.ingredients,
                instructions: recipeToEdit.instruction ?? "",
                image: recipeToEdit.image,
                // Closure to save changes: updates the SwiftData object properties directly.
                onSave: { newName, newTime, newIngredients, newInstruction in
                    recipeToEdit.name = newName
                    recipeToEdit.time = newTime
                    recipeToEdit.ingredients = newIngredients
                    recipeToEdit.instruction = newInstruction
                },
                // Closure to dismiss the sheet.
                onDismiss: {
                    selectedRecipeToEdit = nil
                },
                // Pass ingredient modifier logic down.
                addIngredient: addIngredient,
                deleteIngredients: deleteIngredients
            )
        }
    }
}
