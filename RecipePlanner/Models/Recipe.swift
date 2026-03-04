//
// Recipe.swift
// RecipePlanner
//
// Created by Kartik Krishnan on 07.10.25.
//
import Foundation
import SwiftData

/// A delicious recipe that can be saved, planned, and managed within the application.
///
/// This model is designed to store all essential information about a culinary recipe,
/// including its ingredients, preparation time, and whether a user has marked it as a favorite.
/// It conforms to `Identifiable` and is annotated with `@Model` for persistence using **SwiftData**.
@Model
final class Recipe: Identifiable {
    /// The unique identifier for the recipe within the application database.
    ///
    /// This property is automatically initialized with a new ``UUID``.
    var id = UUID()
    
    /// The unique identifier for the recipe from an external API, if applicable.
    ///
    /// Recipes created locally will typically have an `apiId` of 0.
    var apiId: Int
    
    /// The user-friendly name of the recipe (e.g., "Cheesecake").
    var name: String
    
    /// A URL string pointing to an image of the finished dish.
    var image: String
    
    /// A list of ingredients required for the recipe.
    var ingredients: [String]
    
    /// The estimated total preparation and cook time in minutes.
    ///
    /// This property is optional, as the time might not always be provided.
    var time: Int?
    
    /// The detailed, step-by-step instructions for preparing the recipe.
    var instruction: String?
    
    /// A boolean indicating whether the user has marked this recipe as a favorite.
    ///
    /// - Note: Favorite recipes can be quickly filtered and accessed in the UI.
    var isFav: Bool

    /// Creates a new `Recipe` instance with specified details.
    ///
    /// - Parameters:
    ///   - apiId: The unique identifier from an external source. Defaults to `0`.
    ///   - name: The required name of the recipe.
    ///   - image: An image URL string. Defaults to an empty string.
    ///   - ingredients: A list of ingredients. Defaults to an empty array.
    ///   - isFav: A boolean to mark the recipe as a favorite. Defaults to `false`.
    ///   - time: The estimated total time in minutes. Defaults to `nil`.
    ///   - instruction: The preparation instructions. Defaults to `nil`.
    init(
        apiId: Int = 0,
        name: String,
        image: String = "",
        ingredients: [String] = [],
        isFav: Bool = false,
        time: Int? = nil,
        instruction: String? = nil) {
        self.apiId = apiId
        self.name = name
        self.image = image
        self.ingredients = ingredients
        self.isFav = isFav
        self.time = time
        self.instruction = instruction
    }
   
    
    /// A collection of simple, local recipes for use in previews, testing, and initial setup.
    ///
    /// This static property provides a convenient way to populate a **SwiftData** container
    /// with basic data for development purposes.
    static let sampleData = [
        Recipe(name: "cheese cake"),
        Recipe(name: "apple cake"),
        Recipe(name: "pancakes"),
        Recipe(name: "scrambled eggs")
    ]
}
