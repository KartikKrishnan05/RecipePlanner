//
// IngredientDetail.swift
// RecipePlanner
//
// Created by Kartik Krishnan on 13.10.25.
//
import Foundation

/// A compact data structure representing a single ingredient's core details.
///
/// This structure is primarily used within a ``RecipeSummary`` to list both
/// the ingredients the user has (**usedIngredients**) and those they are missing
/// (**missedIngredients**).
/// It conforms to `Codable` for seamless integration with JSON data received from an API.
struct IngredientDetail: Codable {
    /// The unique identifier for the ingredient, typically from the API source.
    let id: Int
    
    /// The common name of the ingredient (e.g., "sugar", "butter").
    let name: String
    
    /// An optional URL string pointing to an image of the ingredient.
    ///
    /// This property may be `nil` if the image is not provided by the data source.
    let image: String?
}
