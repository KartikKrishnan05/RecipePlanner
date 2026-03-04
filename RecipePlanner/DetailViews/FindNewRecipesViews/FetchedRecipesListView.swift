//
// FetchedRecipesListView.swift
// RecipePlanner
//
// Created by Kartik Krishnan on 14.10.25.
//
import SwiftUI
import OSLog
import SwiftData

/// A presentational view responsible for displaying the results of an API recipe search.
///
/// This view acts as a state machine, switching between **Loading**, **Error**, **Empty**,
/// and **Content** states based on the data received from the network layer. It displays
/// recipes in their temporary state before they are saved locally.
struct FetchedRecipesListView: View {
    // MARK: - External State
    
    /// The array of ``Recipe`` objects fetched from the API. This array is temporary.
    let recipes: [Recipe]
    
    /// A flag indicating if the search operation is currently running.
    let isLoading: Bool
    
    /// An optional string containing the reason for a failed search.
    let errorMessage: String?

    // MARK: - Action Closures
    
    /// The action to perform when the favorite button is tapped. (Functionally empty in this view).
    let onToggleFavourite: (Recipe) -> Void
    
    /// The action to perform when a recipe is deleted from the temporary list (swipe-to-delete).
    let onListDelete: (IndexSet) -> Void
    
    /// The action to perform when a recipe cell is tapped to view its details.
    let onSelectForEdit: (Recipe) -> Void
    
    /// The action to save a temporary recipe to the persistent store.
    let onSave: (Recipe) -> Void
    
    /// The action to re-initiate the recipe search.
    let onReload: () -> Void

    // MARK: - Internal State
    
    /// The selected ``Recipe`` object to view/edit in a sheet.
    @State private var selectedRecipeToEdit: Recipe?

    // MARK: - View Body
    
    /// The content and behavior of the view.
    var body: some View {
        VStack {
            if isLoading {
                /// **Loading State**: Show a progress indicator while fetching data.
                ProgressView("Searching for recipes...")
                    .padding()
            } else if let errorMessage = errorMessage {
                /// **Error State**: Show the error message and provide a retry button.
                ContentUnavailableView {
                    Label("Error", systemImage: "xmark.octagon.fill")
                } description: {
                    Text(errorMessage)
                } actions: {
                    // Button calls the onReload closure to re-attempt the search.
                    Button("Retry Search") {
                        onReload()
                    }
                }
            } else if !recipes.isEmpty {
                /// **Content State**: Display the fetched recipes in a list.
                RecipeListView(
                    recipes: recipes,
                    // Indicates these recipes are temporary API results.
                    isFromApi: true,
                    onToggleFavourite: onToggleFavourite,
                    onListDelete: onListDelete,
                    onSelectForEdit: { recipe in
                        selectedRecipeToEdit = recipe
                    },
                    onSave: onSave
                )
                // Presents the detail view when a recipe is selected.
                .sheet(item: $selectedRecipeToEdit) { recipe in
                    RecipeDetailView(
                        name: recipe.name,
                        time: recipe.time ?? -1,
                        ingredients: recipe.ingredients,
                        instructions: recipe.instruction ?? "",
                        image: recipe.image,
                        onSave: { newName, newTime, newIngredients, newInstruction in
                            // When editing an API result, update the temporary @State array only.
                            if let index = recipes.firstIndex(where: { $0.apiId == recipe.apiId }) {
                                recipes[index].name = newName
                                recipes[index].time = newTime
                                recipes[index].ingredients = newIngredients
                                recipes[index].instruction = newInstruction
                            }
                        },
                        onDismiss: {
                            selectedRecipeToEdit = nil
                        },
                        addIngredient: IngredientModifier.addIngredient,
                        deleteIngredients: IngredientModifier.deleteIngredients
                    )
                }
            } else {
                /// **Empty State**: Show a message when the search was successful but returned no results.
                ContentUnavailableView(
                    "No Recipes Found",
                    systemImage: "magnifyingglass.circle.fill",
                    description: Text("Start by adding ingredients to your grocery list and reload.")
                )
            }
        }
    }
}
