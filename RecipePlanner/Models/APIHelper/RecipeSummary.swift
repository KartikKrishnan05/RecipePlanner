//
// RecipeSummary.swift
// RecipePlanner
//
// Created by Kartik Krishnan on 13.10.25.
//
import Foundation

/// A lightweight data structure representing a brief overview of a recipe,
/// typically received from an external API.
///
/// This structure provides just enough information to display a list of recipe results
/// and compare them based on available and missing ingredients.
/// It conforms to `Codable` for easy parsing of JSON data and `Identifiable`.
struct RecipeSummary: Codable, Identifiable {
    /// The unique identifier for the recipe, usually provided by the API.
    let id: Int
    
    /// The name of the recipe.
    let title: String
    
    /// A URL string pointing to the recipe's image.
    let image: String
    
    /// The number of ingredients required for the recipe that the user is missing.
    let missedIngredientCount: Int
    
    /// The number of ingredients required for the recipe that the user currently has in stock.
    let usedIngredientCount: Int
    
    /// An array of detailed information about the ingredients the user is missing.
    ///
    /// The type `IngredientDetail` is assumed to be defined elsewhere.
    let missedIngredients: [IngredientDetail]
    
    /// An array of detailed information about the ingredients the user has.
    ///
    /// The type `IngredientDetail` is assumed to be defined elsewhere.
    let usedIngredients: [IngredientDetail]
    
    /// A computed property that returns a combined list of all ingredient names
    /// used in this recipe, both missed and used.
    var allIngredientNames: [String] {
        let missed = missedIngredients.map { $0.name }
        let used = usedIngredients.map { $0.name }
        return missed + used
    }
}

/// A container structure used to hold a collection of ``RecipeSummary`` results.
///
/// This is typically used when the API response wraps an array of recipes
/// in a root object.
struct RecipeCollection {
    /// An array of all recipe summaries received from the API.
    var recipes: [RecipeSummary]
}

/// A default, placeholder ``RecipeSummary`` instance.
///
/// Use this value for SwiftUI Previews or as a fallback when recipe data is unavailable
/// to prevent crashes or display an initial state.
var defaultRecipeSummary = RecipeSummary(
    id: 0,
    title: "Default Recipe",
    image: "RecipePlaceholder",
    missedIngredientCount: 0,
    usedIngredientCount: 0,
    missedIngredients: [],
    usedIngredients: []
)
