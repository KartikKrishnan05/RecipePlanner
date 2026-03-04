//
// RecipeCellView.swift
// RecipePlanner
//
// Created by Kartik Krishnan on 09.10.25.
//
import SwiftUI
import SwiftData

/// A presentational view component used to display a single recipe item within a list.
///
/// This view supports two primary modes:
/// 1. **Local Recipe Mode** (`isFromApi: false`): Shows a favorite button.
/// 2. **API Result Mode** (`isFromApi: true`): Shows a save button.
struct RecipeCellView: View {
    // MARK: - Initial Data
    
    /// The ``Recipe`` data object displayed by the cell.
    let recipe: Recipe
    
    /// The current favorite status of the recipe, used to determine the heart icon's color.
    let isFavourite: Bool
    
    /// A flag indicating if the recipe is a temporary result from an API search (`true`)
    /// or a permanently saved local recipe (`false`).
    let isFromApi: Bool
    
    // MARK: - Action Closures
    
    /// The action to be executed when the main part of the cell is tapped to view details.
    let onSelect: () -> Void
    
    /// The action to be executed when the favorite button is tapped (in local mode).
    let onToggleFavourite: () -> Void
    
    /// The action to be executed when the save button is tapped (in API mode).
    let onSave: () -> Void
    
    // MARK: - Internal State
    
    /// Local state to track whether an API recipe has been saved, primarily to update the UI (though this state is not currently used to disable the button).
    @State var isSaved: Bool = false
    
    // MARK: - View Body
    
    var body: some View {
        HStack {
            // Main cell content button for selection/editing
            Button {
                onSelect()
            } label: {
                Text(recipe.name)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
            }
            .buttonStyle(PlainButtonStyle()) // Ensures the tap area is correct
            
            Spacer()
            
            // Toggles between the Favorite button and the Save button based on the source.
            if !isFromApi {
                // Local Recipe: Favorite Button
                Button {
                    onToggleFavourite()
                } label: {
                    Label("Like", systemImage: "heart.fill")
                        .labelStyle(.iconOnly)
                        .foregroundColor(isFavourite ? .red : .gray)
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                // API Recipe: Save Button
                Button {
                    onSave()
                    isSaved = true
                } label: {
                    Label("save", systemImage: "square.and.arrow.down")
                        .labelStyle(.iconOnly)
                        .foregroundColor(.gray)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(20)
        // Applies the standard background styling to the entire cell.
        .background(Color(.systemGray5).clipShape(RoundedRectangle(cornerRadius:10)))
    }
}
