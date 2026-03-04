//
// SettingsView.swift
// RecipePlanner
//
// Created by Kartik Krishnan on 10.10.25.
//
import SwiftUI
import SwiftData
import OSLog

/// A container view for managing application-level settings, including the API key
/// and the option to permanently reset all stored data.
struct SettingsView: View {
    // MARK: - SwiftData Integration
    
    /// The SwiftData model context, injected from the environment, used to perform database deletions.
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - View State
    
    /// Controls the visibility of the temporary confirmation message shown after a successful app data reset.
    @State private var resetComplete = false
    
    // MARK: - External State (API Key)
    
    /// A binding to the external API key string, shared with the root application view (ContentView).
    ///
    /// Changes made here are reflected immediately in the parent's `@State` property.
    @Binding var apiKey: String
    
    /// The local, mutable state for the API key input field.
    ///
    /// This is separate from the `apiKey` binding to prevent continuous updates to the parent state
    /// until the user explicitly taps the save button.
    @State private var apiKeyInput: String
    
    /// A private logger instance for recording events and errors.
    let logger = Logger()
    
    // MARK: - Initialization
    
    /// Initializes the view, setting up the necessary binding and initial local state.
    ///
    /// - Parameter apiKey: A binding to the shared API key in the application environment.
    init(apiKey: Binding<String>) {
        // Initialize the @Binding property.
        _apiKey = apiKey
        // Initialize the local @State property (`apiKeyInput`) with the current value of the binding.
        _apiKeyInput = State(initialValue: apiKey.wrappedValue)
    }
    
    // MARK: - Actions
    
    /// Permanently deletes all data stored in SwiftData for both ``Recipe`` and ``Grocery`` models.
    ///
    /// This function also resets the API key state and provides temporary visual feedback to the user.
    private func resetAppData() {
        do {
            // Delete all instances of the specified model types from persistent storage.
            try modelContext.delete(model: Recipe.self)
            try modelContext.delete(model: Grocery.self)
            try modelContext.save()
            
            // Clear the shared API key and the local input field.
            apiKey = ""
            apiKeyInput = ""
            
            logger.log("Successfully deleted all Recipe and Grocery data.")
            
            // Start the confirmation message animation.
            withAnimation { resetComplete = true }
            
            // Wait briefly and then hide the confirmation message using structured concurrency.
            Task { @MainActor in
                try await Task.sleep(for: .seconds(0.75))
                withAnimation { resetComplete = false }
            }
        } catch {
            logger.log("Failed to reset app data: \(error)")
        }
    }
    
    // MARK: - View Body
    
    /// The content and behavior of the view.
    var body: some View {
        NavigationStack {
            VStack {
                /// View for entering and saving the external API key.
                ApiKeyInputView(
                    apiKeyInput: apiKeyInput,
                    onSave: { newApiKey  in
                        // Trim whitespace and update the shared API key via the binding.
                        let trimmedKey = newApiKey.trimmingCharacters(in: .whitespacesAndNewlines)
                        self.apiKey = trimmedKey
                        
                        logger.log("API Key updated via Save Button (trimmed)")
                        
                        // Programmatically dismiss the keyboard after saving.
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                )
                
                Spacer()
                
                /// Button for initiating the full application data reset.
                ResetButtonView(resetAppData: resetAppData)
                
                // Confirmation text displayed after a successful reset.
                if resetComplete {
                    Text("Data successfully reset!")
                        .foregroundColor(.green)
                        .transition(.opacity)
                }
            }
            .padding(25)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text("Settings")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                    }
                }
            }
        }
    }
}
