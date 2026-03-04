//
// IngredientModifier.swift
// RecipePlanner
//
// Created by Kartik Krishnan on 14.10.25.
//
import SwiftUI

/// A stateless utility struct designed to perform common modifications on arrays of ingredient strings.
///
/// This struct operates on a `Binding<[String]>`, allowing it to modify the source data
/// (typically a `@State` property in a SwiftUI View) without holding any state itself.
struct IngredientModifier {
    /// Adds a new ingredient string to the bound array.
    ///
    /// The method trims whitespace from the input and ensures the string is not empty
    /// before appending it to the collection.
    ///
    /// - Parameters:
    ///   - newIngredientText: The text of the ingredient to be added.
    ///   - currentIngredients: A `Binding` to the array of ingredients to be modified.
    static func addIngredient(newIngredientText: String, currentIngredients: Binding<[String]>) {
        let trimmedText = newIngredientText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedText.isEmpty {
            currentIngredients.wrappedValue.append(trimmedText)
        }
    }

    /// Deletes ingredients from the bound array at the specified indices.
    ///
    /// - Parameters:
    ///   - offsets: An `IndexSet` specifying the positions of the ingredients to be removed.
    ///   - currentIngredients: A `Binding` to the array of ingredients to be modified.
    static func deleteIngredients(offsets: IndexSet, currentIngredients: Binding<[String]>) {
        currentIngredients.wrappedValue.remove(atOffsets: offsets)
    }
}
