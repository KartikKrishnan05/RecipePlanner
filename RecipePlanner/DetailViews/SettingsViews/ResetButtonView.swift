//
// ResetButtonView.swift
// RecipePlanner
//
// Created by Kartik Krishnan on 14.10.25.
//
import SwiftUI

/// A presentational view that displays a prominent, red-themed button for resetting application data.
///
/// Tapping the button presents a confirmation alert to prevent accidental data deletion.
struct ResetButtonView: View {
    /// Controls the presentation state of the confirmation alert.
    @State private var showingResetAlert = false
    
    /// The action closure to be executed when the user confirms the app reset in the alert.
    ///
    /// The parent view is responsible for defining the logic to permanently delete all stored data.
    let resetAppData: () -> Void
    
    /// The content and behavior of the view.
    var body: some View {
        Button("⚠️ Reset App Completely") {
            showingResetAlert = true
        }
        .font(.headline)
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.red.opacity(0.1))
        .foregroundColor(.red)
        .cornerRadius(10)
        .alert("Confirm App Reset", isPresented: $showingResetAlert) {
            Button("Delete All Data", role: .destructive) {
                resetAppData()
            }
        
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action will **permanently delete all saved data** including **Recipes** and **Grocery** items. This cannot be undone.")
        }
    }
}
