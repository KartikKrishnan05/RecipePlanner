//
// ApiKeyInputView.swift
// RecipePlanner
//
//
//
import SwiftUI
import OSLog

/// A presentational view component used for entering and saving an external API key.
///
/// This view displays a text field for key input and a "Save Key" button which, upon
/// success, shows a temporary confirmation message.
struct ApiKeyInputView: View {
    /// The local state that holds the current text input for the API key.
    ///
    /// This value is initialized by the parent view.
    @State var apiKeyInput: String
    
    /// Controls the visibility of the "Saved! ✅" confirmation message.
    @State var showingSaveConfirmation: Bool = false
    
    /// A private logger instance for debugging.
    private let logger = Logger()
    
    /// The action closure to be executed when the "Save Key" button is tapped.
    ///
    /// The closure receives the current value of the API key string.
    let onSave: (String) -> Void
    
    /// The content and behavior of the view.
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("External API Key")
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack {
                TextField("Enter Spoonacular API Key", text: $apiKeyInput)
                    .textFieldStyle(.roundedBorder)
                
                if showingSaveConfirmation {
                    Text("Saved! ✅")
                        .foregroundColor(.green)
                        // Use a transition and ID to ensure the confirmation message
                        // is properly animated when it appears.
                        .transition(.opacity)
                        .id("confirmation")
                } else {
                    Button("Save Key") {
                        showingSaveConfirmation = true
                        // Execute the external save action
                        onSave(apiKeyInput)
                    }
                    .padding(.horizontal)
                    .buttonStyle(.borderedProminent)
                    // Disable the button if the input is empty or contains only whitespace.
                    .disabled(apiKeyInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
