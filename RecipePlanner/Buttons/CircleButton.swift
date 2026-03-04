//
// ReusableTabBar.swift
// RecipePlanner
//
// Created by Kartik Krishnan on 09.10.25.
//
import SwiftUI

/// A reusable SwiftUI view that displays a circular button with an SF Symbol.
///
/// This component is designed for use in toolbars or control groups, providing a
/// clear visual indicator for actions. It supports special styling for a favorite/filter button.
struct CircleButton: View {
    /// The name of the SF Symbol to display inside the button (e.g., "plus", "heart.fill").
    var buttonImage : String
    
    /// The action closure to execute when the button is tapped.
    let onCall: () -> Void
    
    /// A flag indicating if this button is specifically the "favorite" or filter button.
    let isFavoriteButton: Bool
    
    /// A binding that determines whether the favorite/filter state should be visibly active.
    var showFavourite : Bool
    
    /// Creates a circular button with a custom image and action.
    ///
    /// - Parameters:
    ///   - buttonImage: The name of the SF Symbol to display.
    ///   - onCall: The closure to execute when the button is pressed. This closure is marked
    ///     `@escaping` to be executed later upon user interaction.
    ///   - isFavoriteButton: Set to `true` if this button controls a favorite/filter state. Defaults to `false`.
    ///   - showFavourite: Set to `true` to apply the active favorite button style. Defaults to `false`.
    init(buttonImage: String, onCall: @escaping () -> Void, isFavoriteButton: Bool = false, showFavourite: Bool = false) {
        self.buttonImage = buttonImage
        self.onCall = onCall
        self.isFavoriteButton = isFavoriteButton
        self.showFavourite = showFavourite
    }
    
    var body: some View {
        Button {
            onCall()
        } label: {
            Label("Button", systemImage: buttonImage)
                .labelStyle(.iconOnly)
                .foregroundColor(.white)
                .font(.title)
                .padding(20)
                .background(
                    Circle()
                        .fill((showFavourite && isFavoriteButton) ? Color.red.opacity(0.35) : Color.gray.opacity(0.75)))
        }
        .padding(10)
        .clipShape(Circle())
    }
}
