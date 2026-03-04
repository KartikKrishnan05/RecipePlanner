//
// RecipeView.swift
// RecipePlanner
//
// Created by Kartik Krishnan on 07.10.25.
//

import SwiftUI
import SwiftData

/// The main container view for managing locally saved recipes.
///
/// This view orchestrates data persistence, filtering, searching, and navigation
/// for the user's recipe collection. It uses `@Query` to fetch data from **SwiftData**
/// and manages UI state with various `@State` properties.
struct RecipeView: View {
    // MARK: - SwiftData Integration
    
    /// The **SwiftData** context, injected from the environment, used for saving and deleting data.
    @Environment(\.modelContext) private var modelContext
    
    /// A live collection of all ``Recipe`` objects in the store, sorted alphabetically by name.
    @Query(sort: \Recipe.name) private var recipes: [Recipe]
    
    // MARK: - View State
    
    /// Controls whether the displayed list should be filtered to show only favorite recipes.
    @State var showFavourite : Bool = false
    
    /// Controls the presentation of the sheet used for adding new recipes.
    @State private var isShowingAddRecipeView = false
    
    /// The text entered by the user in the search bar, used to filter the recipe list.
    @State private var searchText = ""
    
    // MARK: - Computed Properties
    
    /// An array of recipes filtered based on the current search text and the favorite filter state.
    private var filteredRecipes: [Recipe] {
        // Apply the favorite filter first if 'showFavourite' is true.
        let baseRecipes = showFavourite ? recipes.filter { $0.isFav } : recipes
        
        // Apply the search filter if 'searchText' is not empty.
        if searchText.isEmpty {
            return baseRecipes
        } else {
            // Performs a case- and accent-insensitive search on the recipe name.
            return baseRecipes.filter { $0.name.localizedStandardContains(searchText) }
        }
    }
    
    // MARK: - View Body
    
    /// The content and behavior of the view.
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    /// The presentational list view that displays the currently filtered recipes.
                    RecipeListContentView(
                        recipes: filteredRecipes,
                        // Toggles the favorite state directly on the SwiftData object.
                        onToggleFavourite: { recipe in recipe.isFav.toggle() },
                        // Deletes recipes from the model context based on the indices of the filtered list.
                        onListDelete: { indexSet in indexSet.map { filteredRecipes[$0] }.forEach(modelContext.delete) },
                        // Inserts a new recipe into the model context.
                        onSave: { recipe in modelContext.insert(recipe) },
                        // Passes through the stateless utility methods for ingredient modification.
                        addIngredient: IngredientModifier.addIngredient,
                        deleteIngredients: IngredientModifier.deleteIngredients
                    )
                }
                
                // Overlay for the action buttons (Favorite filter and Add Recipe).
                VStack {
                    Spacer()
                    HStack {
                        /// Button to toggle the favorite filter state.
                        CircleButton(
                            buttonImage: "heart.fill",
                            onCall: { showFavourite.toggle() },
                            isFavoriteButton: true,
                            showFavourite: showFavourite
                        )
                        Spacer()
                        /// Button to present the view for adding a new custom recipe.
                        CircleButton(buttonImage: "document.badge.plus.fill", onCall: { isShowingAddRecipeView = true })
                            .sheet(isPresented: $isShowingAddRecipeView) {
                                // Presents the detail view initialized for a new, blank recipe.
                                RecipeDetailView(
                                    name: "",
                                    time: -1,
                                    ingredients: [""],
                                    instructions: "",
                                    image: "",
                                    // Closure to handle saving a new recipe object.
                                    onSave: { newName, newTime, newIngredients, newInstructions in
                                        let newRecipe = Recipe(
                                            name: newName,
                                            ingredients: newIngredients,
                                            time: newTime,
                                            instruction: newInstructions
                                        )
                                        modelContext.insert(newRecipe)
                                    },
                                    // Closure to dismiss the sheet after saving or canceling.
                                    onDismiss: {
                                        isShowingAddRecipeView = false
                                    },
                                    addRecipe: true,
                                    addIngredient: IngredientModifier.addIngredient,
                                    deleteIngredients: IngredientModifier.deleteIngredients
                                )
                            }
                    }
                }
                .padding(25)
            }
            // Customizes the navigation bar appearance.
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Custom-styled title placed in the center of the navigation bar.
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text("Saved Recipes")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                    }
                }
            }
        }
        // Adds the search bar functionality to the view.
        .searchable(text: $searchText, prompt: "Search for a recipe")
    }
}

#Preview {
    RecipeView()
        // Injects the model container with sample data for previewing.
        .modelContainer(SampleData.shared.modelContainer)
}
