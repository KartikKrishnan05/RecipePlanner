//
// RecipePlannerApp.swift
// RecipePlanner
//
// Created by Leon Liang on 01/10/2025.
//
import SwiftUI
import SwiftData

/// The entry point for the RecipePlanner application.
///
/// This structure sets up the main application environment, including the
/// **SwiftData** persistence layer and the observable data fetching service.
@main
struct RecipePlannerApp: App {
    /// The main observable service responsible for handling recipe API calls.
    ///
    /// The `@State` wrapper ensures the application retains this single instance of
    /// ``RecipeCollectionFetcher`` throughout its lifecycle.
    @State private var fetcher = RecipeCollectionFetcher()
    
    /// The application's main scene definition.
    var body: some Scene {
        WindowGroup {
            ContentView()
                // Makes the shared `fetcher` instance available to all child views
                .environment(fetcher)
        }
        /// Sets up the persistent storage layer for the entire application.
        ///
        /// This container is configured to handle persistence for both the
        /// ``Recipe`` and ``Grocery`` model types.
        .modelContainer(for: [Recipe.self, Grocery.self])
    }
}
