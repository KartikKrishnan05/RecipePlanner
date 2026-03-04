//
// RecipeCollectionFetcher.swift
// RecipePlanner
//
// Created by Kartik Krishnan on 12.10.25.
//
import Foundation
import SwiftData
import SwiftUI
import OSLog

/// An observable service class responsible for fetching recipe collections from the Spoonacular API.
///
/// This class is marked with the `@Observable` macro, making its properties,
/// such as ``recipeData``, automatically trigger SwiftUI view updates upon change.
/// It uses Swift's async/await concurrency model for network operations.
@Observable
class RecipeCollectionFetcher {
    /// The base URL for the Spoonacular API endpoint used to find recipes by ingredients.
    private let BASE_URL = "https://api.spoonacular.com/recipes/findByIngredients"
    
    /// The container for the fetched recipe summaries.
    ///
    /// This property holds the results of the last successful fetch operation. It is initialized
    /// with a ``RecipeCollection`` containing the ``defaultRecipeSummary``.
    var recipeData = RecipeCollection(recipes: [defaultRecipeSummary])
    
    /// A private logger instance for recording network and decoding events.
    private let logger = Logger()

    // MARK: - Error Handling
    
    /// Enumerates the possible errors that can occur during the recipe fetching process.
    enum FetchError: Error {
        /// Indicates a non-200 HTTP status code was received from the server.
        case badRequest
        /// Indicates an error occurred during the JSON decoding process.
        case badJSON
        /// Indicates the URL could not be constructed correctly from the components.
        case invalidURL
    }
    
    // MARK: - Fetch Method
    
    /// Initiates an asynchronous network request to the Spoonacular API to find recipes.
    ///
    /// This method constructs the API URL using the provided ingredients and API key,
    /// performs the data fetch, validates the response, and decodes the JSON data.
    ///
    /// - Parameters:
    ///   - apiKey: The secret API key required for Spoonacular access.
    ///   - ingredients: An array of ingredient names (e.g., "milk", "eggs") to search for.
    ///
    /// - Throws: A ``FetchError`` if the request fails, the URL is invalid, or decoding fails.
    ///
    /// - Note: This function is marked with `@MainActor` to ensure that updating the
    ///         `@Observable` property ``recipeData`` occurs safely on the main thread.
    @MainActor
    func fetchRecipes(apiKey: String, ingredients: [String]) async throws {
        guard !ingredients.isEmpty else {
            logger.log("No ingredients provided. Skipping API call.")
            return
        }
        
        let ingredientList = ingredients.joined(separator: ",")
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.spoonacular.com"
        components.path = "/recipes/findByIngredients"
        components.queryItems = [
            URLQueryItem(name: "ingredients", value: ingredientList),
            URLQueryItem(name: "number", value: "10"),
            URLQueryItem(name: "ranking", value: "1"),
            URLQueryItem(name: "ignorePantry", value: "true"),
            URLQueryItem(name: "apiKey", value: apiKey)
        ]
        
        guard let finalURL = components.url else {
            throw FetchError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: finalURL)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw FetchError.badRequest
        }
        
        do {
            let decodedSummaries = try JSONDecoder().decode([RecipeSummary].self, from: data)
            self.recipeData = RecipeCollection(recipes: decodedSummaries)
            
            logger.log("Successfully fetched and decoded \(decodedSummaries.count) recipe summaries.")
        } catch {
            logger.log("Decoding Error")
            throw FetchError.badJSON
        }
    }
}
