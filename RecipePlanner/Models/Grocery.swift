//
// Grocery.swift
// RecipePlanner
//
// Created by Kartik Krishnan on 10.10.25.
//
import Foundation
import SwiftData

/// An item in the user's pantry or grocery list.
///
/// This model represents a single food item, tracking its name, current quantity (stock),
/// and an optional expiration date. It is marked with `@Model` for persistence using **SwiftData**.
@Model
final class Grocery: Identifiable {
    /// The unique identifier for the grocery item.
    ///
    /// This property is automatically initialized with a new ``UUID``.
    var id = UUID()
    
    /// The name of the grocery item (e.g., "milk", "flour").
    var name: String
    
    /// The current quantity of the item in stock.
    ///
    /// A value of `0` typically indicates the item is out of stock or needs to be purchased.
    var stock: Int
    
    /// The date when the item is expected to expire.
    ///
    /// This property is optional.
    var expirationDate: Date?
    
    /// Creates a new `Grocery` item, including an optional expiration date.
    ///
    /// - Parameters:
    ///   - name: The required name of the grocery item.
    ///   - stock: The current quantity of the item in stock. Defaults to `0`.
    ///   - expirationDate: The date the item expires. Defaults to `nil`.
    init(name: String, stock: Int = 0, expirationDate: Date? = nil) {
        self.name = name
        self.expirationDate = expirationDate
        self.stock = stock
    }
    
    /// Creates a new `Grocery` item without specifying an expiration date.
    ///
    /// - Parameters:
    ///   - name: The required name of the grocery item.
    ///   - stock: The current quantity of the item in stock. Defaults to `0`.
    init(name: String, stock: Int = 0) {
        self.name = name
        self.stock = stock
    }
    
    /// A collection of basic grocery items for use in previews, testing, and initial setup.
    ///
    /// Use this sample data to easily populate a **SwiftData** container during development.
    static let sampleData = [
        Grocery(name: "apple", stock: 2),
        Grocery(name: "banana", stock: 0),
        Grocery(name: "milk", stock: 2),
        Grocery(name: "eggs", stock: 2),
    ]
}
