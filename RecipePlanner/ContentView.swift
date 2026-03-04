//
// ContentView.swift
// RecipePlanner
//
// Created by Leon Liang on 01/10/2025.
//

import SwiftUI

/// The root view of the RecipePlanner application.
///
/// This view is responsible for setting up the main tab-based navigation
/// and managing the shared API key state for the entire app.
struct ContentView: View {
    /// The API key used for accessing external recipe services (like Spoonacular).
    ///
    /// This key is marked with `@State` to manage its value internally and is passed
    /// down to subviews like ``FindNewRecipesView`` and ``SettingsView`` using
    /// the `@Binding` property wrapper.
    @State private var sharedApiKey: String = ""
    
    /// The content and behavior of the view.
    var body: some View {
        VStack {
            TabView {
                /// The tab dedicated to viewing and managing saved recipes.
                Tab("Recipes", systemImage: "book.pages.fill") {
                    RecipeView()
                }
                
                /// The tab for searching and finding new recipes based on available ingredients.
                Tab("Find", systemImage: "wand.and.sparkles") {
                    FindNewRecipesView(apiKey: $sharedApiKey)
                }
                
                /// The tab for managing the user's current inventory or grocery list.
                Tab("Inventory", systemImage: "cart.fill") {
                    InventoryView()
                }
                
                /// The tab for accessing application settings, including API key configuration.
                Tab("Settings", systemImage: "gear") {
                    SettingsView(apiKey: $sharedApiKey)
                }
            }
        }
    }
}

#Preview {
    ContentView()
        // Provide the sample data container for the preview environment.
        .modelContainer(SampleData.shared.modelContainer)
        // Inject a RecipeCollectionFetcher into the environment for the preview.
        .environment(RecipeCollectionFetcher())
}
