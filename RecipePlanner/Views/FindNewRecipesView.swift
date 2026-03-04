//
// FindNewRecipesView.swift
// RecipePlanner
//
// Created by Kartik Krishnan on 08.10.25.
//

import SwiftUI
import SwiftData
import OSLog

/// A container view responsible for fetching new recipes from an external API
/// based on the user's current ``Grocery`` inventory.
///
/// This view manages the network call lifecycle, converts the fetched API data
/// (`RecipeSummary` structs) into storable local objects (``Recipe`` classes),
/// and handles errors and loading states.
struct FindNewRecipesView: View {
    // MARK: - Environment & Data
    
    /// The observable service used to execute network calls. Injected via the environment.
    @Environment(RecipeCollectionFetcher.self) var fetcher
    
    /// A live collection of all ``Grocery`` objects in the store, used to determine available ingredients.
    @Query(sort: \Grocery.name) private var groceryItems: [Grocery]
    
    /// The SwiftData model context, used to save fetched recipes to the local store.
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - External State
    
    /// A binding to the application's shared API key, sourced from a parent view (e.g., ContentView).
    @Binding var apiKey: String
    
    // MARK: - Internal State
    
    /// The array of ``Recipe`` objects converted from the last successful API call.
    @State private var recipes: [Recipe] = []
    
    /// The selected recipe to view/edit. Not currently used for API recipes, but reserved for future expansion.
    @State private var selectedRecipeToEdit: Recipe?
    
    /// A private logger instance for recording events and errors.
    let logger = Logger()
    
    /// An optional string containing a user-friendly error message to display on the screen.
    @State private var errorMessage: String?
    
    /// A boolean flag indicating whether a network operation is currently in progress.
    @State private var isLoading = false
    
    // MARK: - View Body
    
    /// The content and behavior of the view.
    var body: some View {
        NavigationStack {
            ZStack {
                /// The presentational view that displays the list, loading indicator, or error message.
                FetchedRecipesListView(
                    recipes: recipes,
                    isLoading: isLoading,
                    errorMessage: errorMessage,
                    // Favorite toggling is disabled for API results.
                    onToggleFavourite: { _ in },
                    onListDelete: { indexSet in
                        logger.log("Delete recipes at indices: \(indexSet)")
                        // Delete is performed on the local 'recipes' array state, not SwiftData.
                        recipes.remove(atOffsets: indexSet)
                    },
                    onSelectForEdit: { _ in },
                    onSave: { recipe in
                        // Inserts the new recipe into local persistent storage.
                        modelContext.insert(recipe)
                        logger.log("Saved recipe: \(recipe.name).")
                        // Remove the saved recipe from the temporary fetched list.
                        if let index = recipes.firstIndex(where: { $0.apiId == recipe.apiId }) {
                            recipes.remove(at: index)
                        }
                    },
                    onReload: {
                        Task {
                            await fetchRecipes()
                        }
                    }
                )
                // Overlay for the action button (Reload).
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        /// Button to manually trigger a refresh of the recipe search.
                        CircleButton(buttonImage: "arrow.clockwise", onCall: {
                            Task {
                                await fetchRecipes()
                            }
                        })
                    }
                }
                .padding(25)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text("Find New Recipes")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                    }
                }
            }
        }
    }
    
    // MARK: - Data Conversion
    
    /// Converts an array of API-specific ``RecipeSummary`` structs into an array of storable ``Recipe`` class objects.
    ///
    /// - Parameter summaries: The array of recipe summaries received from the network fetcher.
    /// - Returns: A new array of ``Recipe`` objects ready for display or local saving.
    private func convertToRecipe(summaries: [RecipeSummary]) -> [Recipe] {
        var convertedRecipes: [Recipe] = []
        for summary in summaries {
            let newRecipe = Recipe(
                apiId: summary.id,
                name: summary.title,
                image: summary.image,
                ingredients: summary.allIngredientNames,
                isFav: false,
                time: nil,
                instruction: nil
            )
            convertedRecipes.append(newRecipe)
        }
        return convertedRecipes
    }
    
    // MARK: - Network Logic
    
    /// Executes the asynchronous process to fetch new recipes based on available inventory.
    ///
    /// This function handles prerequisite checks (API key, inventory size), executes the network call,
    /// and manages the `isLoading` and `errorMessage` states.
    func fetchRecipes() async {
        // 1. Check API Key
        guard let keyToUse = (apiKey.isEmpty ? nil : apiKey), !keyToUse.isEmpty else {
            isLoading = false
            errorMessage = "API Key not set. Please go to Settings to enter your Spoonacular API Key."
            recipes = []
            return
        }
        
        // 2. Filter available ingredients from the local grocery items.
        let ingredients = groceryItems
            .filter { grocery in
                let isAvailable = grocery.stock > 0
                // Check if the item is not expired (ExpirationDate must be greater than or equal to yesterday's date).
                let notExp = (grocery.expirationDate ?? .distantFuture) >= (Date() - 86400)
                return isAvailable && notExp
            }
            .map { $0.name }
        
        // 3. Check Inventory Count
        guard !ingredients.isEmpty else {
            isLoading = false
            errorMessage = "Your grocery list is empty. Add ingredients to search for recipes."
            recipes = []
            return
        }
        
        // 4. Start Loading State
        isLoading = true
        errorMessage = nil
        recipes = []
        
        // 5. Perform Fetch
        do {
            try await fetcher.fetchRecipes(apiKey: keyToUse, ingredients: ingredients)
            
            // On success, convert and store the results in the local @State array.
            let fetchedSummaries = fetcher.recipeData.recipes
            self.recipes = convertToRecipe(summaries: fetchedSummaries)
        } catch let error as RecipeCollectionFetcher.FetchError {
            // Handle categorized FetchErrors.
            switch error {
            case .badRequest:
                errorMessage = """
                API Request failed. This often means the **Daily Limit has been reached** or the **Key is invalid**.
                Please check your key in Settings.
                """
            case .badJSON:
                errorMessage = "Failed to decode the recipe data."
            case .invalidURL:
                errorMessage = "Invalid URL was created for the API call."
            }
        } catch {
            // Handle any other uncategorized error.
            errorMessage = "An unexpected error occurred"
        }
        
        // 6. Stop Loading State
        isLoading = false
    }
}
