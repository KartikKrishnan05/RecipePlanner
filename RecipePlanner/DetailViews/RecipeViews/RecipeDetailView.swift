//
// RecipeDetailView.swift
// RecipePlanner
//
// Created by Kartik Krishnan on 08.10.25.
//
import SwiftUI
import Kingfisher

/// A presentational view that displays and allows editing of all details for a single recipe.
///
/// This view is versatile, serving both to **edit** an existing ``Recipe`` (passed via initial values)
/// or to **create** a new one (passed with empty/default values). It manages all mutable properties
/// using local `@State` variables and communicates the final, saved state back to the parent
/// view using the `onSave` closure.
struct RecipeDetailView: View {
    // MARK: - Initial Values (Read-Only)
    
    /// The initial name of the recipe.
    let name: String
    /// The initial preparation time in minutes.
    let time: Int
    /// The initial array of ingredients.
    let ingredients: [String]
    /// The initial instructions string.
    let instructions: String
    /// The initial image URL string.
    let image: String
    
    // MARK: - Editable State
    
    /// The mutable state for the recipe's name.
    @State private var newName: String
    /// The mutable state for the recipe's time, stored as a string for text field input.
    @State private var newTime: String
    /// The mutable state for the array of ingredients.
    @State private var newIngredients: [String]
    /// The temporary input text used for adding a new ingredient.
    @State private var newIngredientText: String = ""
    /// The mutable state for the recipe's instructions.
    @State private var newInstructions: String
    
    // MARK: - Action Closures
    
    /// The action to be executed when the user saves the changes.
    /// - Parameters:
    ///   - String: The updated name.
    ///   - Int: The updated time (converted to an integer, or -1 if invalid).
    ///   - [String]: The updated list of ingredients.
    ///   - String: The updated instructions.
    let onSave: (String, Int, [String], String) -> Void
    
    /// The action to be executed when the view needs to be dismissed (e.g., after save or cancel).
    let onDismiss: () -> Void
    
    /// The utility function for adding a new ingredient to the array.
    let addIngredient: (String, Binding<[String]>) -> Void
    
    /// The utility function for deleting ingredients from the array.
    let deleteIngredients: (IndexSet, Binding<[String]>) -> Void
    
    /// A flag indicating if this view is being used to add a new recipe, which can affect toolbar titles.
    let addRecipe: Bool
    
    // MARK: - Initialization
    
    /// Initializes the `RecipeDetailView` with initial recipe data and action callbacks.
    init(
        name: String,
        time: Int,
        ingredients: [String],
        instructions: String,
        image: String,
        onSave: @escaping (String, Int, [String], String) -> Void,
        onDismiss: @escaping () -> Void,
        addRecipe: Bool = false,
        addIngredient: @escaping (String, Binding<[String]>) -> Void,
        deleteIngredients: @escaping (IndexSet, Binding<[String]>) -> Void
    ) {
        self.name = name
        self._newName = State(initialValue: name)
        self.time = time
        // Converts the initial time (Int) to a String for the TextField. Uses an empty string if time is -1.
        self._newTime = State(initialValue: (time == -1) ? "" : String(time))
        self.ingredients = ingredients
        self._newIngredients = State(initialValue: ingredients)
        self.instructions = instructions
        self._newInstructions = State(initialValue: instructions)
        self.image = image
        self.onSave = onSave
        self.onDismiss = onDismiss
        self.addRecipe = addRecipe
        self.addIngredient = addIngredient
        self.deleteIngredients = deleteIngredients
    }
    
    // MARK: - Subviews
    
    /// The main scrollable form containing all editable fields for the recipe details.
    private var FormView: some View {
        Form {
            TextField("Name", text: $newName)
                .autocorrectionDisabled()
            
            // Displays the recipe image using Kingfisher for asynchronous loading.
            KFImage(URL(string: image))
                .placeholder {
                    Image("RecipePlaceholder")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .frame(maxHeight: 200)
            
            Section("Preparation Time (Minutes): ") {
                TextField("e.g., 30", text: $newTime)
                    .keyboardType(.numberPad)
            }
            
            Section("Ingredients:") {
                // List of existing ingredients, allowing individual text field editing.
                ForEach($newIngredients, id: \.self) { $ingredient in
                    TextField("Ingredient", text: $ingredient)
                        .autocorrectionDisabled()
                }
                // Attaches the delete action for ingredient rows.
                .onDelete { offsets in
                    deleteIngredients(offsets, $newIngredients)
                }
                
                // Input field and button for adding new ingredients.
                HStack {
                    TextField("New Ingredient", text: $newIngredientText)
                        .autocorrectionDisabled()
                    
                    Button(action: {
                        if !newIngredientText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            addIngredient(newIngredientText, $newIngredients)
                            newIngredientText = ""
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(newIngredientText.isEmpty ? .gray : .green)
                    }
                    .disabled(newIngredientText.isEmpty)
                }
            }
            
            Section("Instructions:") {
                TextEditor(text: $newInstructions)
                    .frame(minHeight: 150)
                    .border(Color(.systemGray5), width: 1)
                    .cornerRadius(5)
            }
        }
    }
    
    // MARK: - Main View Body
    
    var body: some View {
        NavigationStack {
            VStack {
                FormView
                
                Spacer()
                
                // Save and Cancel buttons at the bottom.
                HStack {
                    // Cancel/Dismiss Button
                    CircleButton(buttonImage: "arrowshape.turn.up.backward.fill", onCall: {
                        onDismiss()
                    })
                    
                    Spacer()
                    
                    // Save Button
                    CircleButton(buttonImage: "checkmark.circle.fill", onCall: {
                        // Call the onSave closure, converting time input to Int and trimming whitespace from name.
                        onSave(newName.trimmingCharacters(in: .whitespacesAndNewlines), Int(newTime) ?? -1, newIngredients, newInstructions)
                        onDismiss()
                    })
                    // Disable save if the recipe name field is empty.
                    .disabled(newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(5)
            }
        }
        .padding(20)
        .navigationTitle("")
        .scrollContentBackground(.hidden)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    // Customize the title based on whether the view is for adding or editing.
                    Text(addRecipe ? "Add Recipe" : "Edit Recipe")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                }
            }
        }
    }
}
