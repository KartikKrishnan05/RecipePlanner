//
// GroceryCellView.swift
// RecipePlanner
//
// Created by Kartik Krishnan on 10.10.25.
//
import SwiftUI
import Foundation

/// A presentational view component used to display a single ``Grocery`` item within a list.
///
/// This cell displays the item's name, stock quantity, and expiration date, applying a
/// **red color** to the expiration date if the item is due to expire within the next three days.
struct GroceryCellView: View {
    // MARK: - Initial Data
    
    /// The name of the grocery item.
    let name: String
    
    /// The current stock quantity.
    let stock: Int
    
    /// The optional expiration date.
    let expirationDate: Date?
    
    // MARK: - Date Utilities
    
    /// The current calendar instance.
    let calendar = Calendar.current
    
    /// The current date and time.
    let now = Date()
    
    // MARK: - Action Closure
    
    /// The action to be executed when the cell is tapped to view or edit the item details.
    let onSelect: () -> Void
    
    // MARK: - View Body
    
    var body: some View {
        // Defines the date limit (3 days from now) to trigger the warning color.
        let futureLimit = calendar.date(byAdding: .day, value: 3, to: now) ?? .now
        
        HStack {
            VStack(alignment: .leading) {
                // Item Name
                Text(name)
                    .font(.headline)
                    .onTapGesture {
                        onSelect()
                    }
                
                // Stock Quantity
                Text("Stock: \(stock)")
                    .frame(minWidth: 20, alignment: .leading)
            }
            
            Spacer()
            
            // Expiration Date Display Logic
            Group {
                if stock == 0 {
                    Text("No Stock")
                        .foregroundColor(.gray)
                } else if let expiration = expirationDate {
                    if expiration <= futureLimit {
                        // Highlight in red if expiring soon (within 3 days) or already expired.
                        Text(expiration, style: .date)
                            .foregroundColor(.red)
                            .font(.headline)
                    } else {
                        // Standard date display for items not expiring soon.
                        Text(expiration, style: .date)
                    }
                } else {
                    Text("No Expiration Date")
                        .foregroundColor(.secondary)
                }
            }
            // Apply tap gesture to the entire expiration date group for consistency
            .onTapGesture {
                onSelect()
            }
        }
        .listRowSeparator(.hidden)
        .padding(20)
        // Applies background styling for the cell.
        .background(Color(.systemGray5).clipShape(RoundedRectangle(cornerRadius:10)))
    }
}
