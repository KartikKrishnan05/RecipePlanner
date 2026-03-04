//
// SampleData.swift
// RecipePlanner
//
// Created by Kartik Krishnan on 09.10.25.
//
import Foundation
import SwiftData

/// A utility class for creating and managing an in-memory **SwiftData** container
/// populated with sample data for previews and testing.
///
/// This class ensures that a ``ModelContainer`` is initialized with the ``Grocery``
/// and ``Recipe`` models, and automatically inserts their respective `sampleData`.
/// It is annotated with `@MainActor` to ensure all model operations happen on the
/// main thread.
@MainActor
class SampleData {
    // MARK: - Shared Instance
    
    /// The shared, singleton instance of ``SampleData``.
    ///
    /// Use this instance to access the `modelContainer` and `context`
    /// for working with sample data.
    static let shared = SampleData()
    
    // MARK: - Properties
    
    /// The in-memory model container configured for the sample data.
    ///
    /// This container stores data only for the duration of the app's or preview's lifecycle.
    let modelContainer: ModelContainer
    
    /// A convenience computed property to access the main context of the `modelContainer`.
    var context: ModelContext {
        modelContainer.mainContext
    }
    
    // MARK: - Initialization
    
    /// Initializes the singleton `SampleData` instance.
    ///
    /// This performs the following steps:
    /// 1. Defines the **SwiftData** schema to include ``Grocery`` and ``Recipe``.
    /// 2. Configures the model to be stored exclusively *in memory*.
    /// 3. Creates the ``ModelContainer``.
    /// 4. Calls ``insertSampleData()`` to populate the context.
    /// 5. Saves the context.
    ///
    /// - Important: If the container creation fails, a fatal error is triggered.
    private init() {
        let schema = Schema([
            Grocery.self,
            Recipe.self
        ])
        // Use an in-memory store for sample data purposes
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            insertSampleData()
            
            try context.save()
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    // MARK: - Data Insertion
    
    /// Inserts the static `sampleData` from the ``Grocery`` and ``Recipe`` models
    /// into the current ``ModelContext``.
    private func insertSampleData() {
        for grocery in Grocery.sampleData {
            context.insert(grocery)
        }
        
        for recipe in Recipe.sampleData {
            context.insert(recipe)
        }
    }
}
