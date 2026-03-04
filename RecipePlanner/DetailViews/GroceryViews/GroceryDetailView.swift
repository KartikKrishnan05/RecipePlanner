//
// GroceryDetailView.swift
// RecipePlanner
//
// Created by Kartik Krishnan on 10.10.25.
//
import SwiftUI
import SwiftData

/// A presentational view that allows the user to view, add, or edit the details of a single ``Grocery`` item.
///
/// It uses local `@State` variables to manage user input and communicates the final, saved data
/// back to the parent container view via the `onSave` closure.
struct GroceryDetailView: View {
    // MARK: - Initial Values (Read-Only)
    
    /// The initial name of the grocery item.
    let name: String
    
    /// The initial stock quantity.
    let stock: Int
    
    /// The initial, optional expiration date.
    let expirationDate: Date?
    
    // MARK: - Editable State
    
    /// The mutable state for the grocery item's name.
    @State private var newName: String
    
    /// The mutable state for the stock quantity.
    @State private var newstock: Int
    
    /// The mutable state for the optional expiration date.
    @State private var newexpirationDate: Date?
    
    // MARK: - Flags and Actions
    
    /// A flag indicating if this view is being used to add a new item (`true`) or edit an existing one (`false`).
    let addGrocery: Bool
    
    /// The action to be executed when the user saves the changes.
    /// - Parameters:
    ///   - String: The updated name.
    ///   - Int: The updated stock quantity.
    ///   - Date?: The updated optional expiration date.
    let onSave: (String, Int, Date?) -> Void
    
    /// The action to be executed when the view needs to be dismissed (e.g., after save or cancel).
    let onDismiss: () -> Void
    
    // MARK: - Initialization
    
    /// Initializes the `GroceryDetailView` with initial item data and action callbacks.
    init(
        name: String,
        stock: Int,
        expirationDate: Date?,
        onSave: @escaping (String, Int, Date?) -> Void,
        onDismiss: @escaping () -> Void,
        addGrocery: Bool = false) {
        self.name = name
        self.stock = stock
        self.expirationDate = expirationDate
        // Initialize @State properties with initial values
        self._newexpirationDate = State(initialValue: expirationDate)
        self._newName = State(initialValue: name)
        self._newstock = State(initialValue: stock)
        self.onSave = onSave
        self.onDismiss = onDismiss
        self.addGrocery = addGrocery
    }

    // MARK: - Custom Bindings
    
    /// A custom `Binding<Date>` used by the `DatePicker`.
    ///
    /// When read, it returns the current `newexpirationDate` or a default `Date()` if nil.
    /// When written, it updates `newexpirationDate` directly. This is necessary because `DatePicker` requires a non-optional `Binding<Date>`.
    var expirationDateBinding: Binding<Date> {
        Binding(
            get: { self.newexpirationDate ?? Date() },
            set: { self.newexpirationDate = $0 }
        )
    }
    
    /// A custom `Binding<Bool>` used by the `Toggle` to enable/disable the expiration date.
    ///
    /// When read, it returns `true` if `newexpirationDate` is non-nil.
    /// When written (`isSet`), it sets the `newexpirationDate` to the current date if enabled, or to `nil` if disabled.
    private var isDateSetBinding: Binding<Bool> {
        Binding(
            get: { newexpirationDate != nil },
            set: { isSet in
                if isSet {
                    newexpirationDate = newexpirationDate ?? Date()
                } else {
                    newexpirationDate = nil
                }
            }
        )
    }

    // MARK: - View Body
    
    /// The content and behavior of the view.
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    TextField("Name", text: $newName)
                        .autocorrectionDisabled()
                    
                    HStack {
                        Text("Stock")
                        Spacer()
                        
                        // Stepper for quantity control
                        Stepper("", value: $newstock, in: 0...Int.max)
                            .labelsHidden()
                        
                        Text("\(newstock)")
                            .foregroundColor(.secondary)
                            .frame(minWidth: 30, alignment: .trailing)
                    }

                    // Toggle to enable/disable the optional expiration date.
                    Toggle("Has Expiration Date", isOn: isDateSetBinding)
                    
                    if newexpirationDate != nil {
                        // DatePicker is only shown if the expiration date is set.
                        DatePicker("Date", selection: expirationDateBinding, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .padding(.leading)
                    }
                }
                
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
                        // Call the onSave closure, trimming the name before passing the final data.
                        onSave(
                            newName.trimmingCharacters(in: .whitespacesAndNewlines),
                            newstock,
                            newexpirationDate
                        )
                        onDismiss()
                    })
                    // Disable save if the name field is empty.
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
                    Text(addGrocery ? "Add Grocery" : "Edit Grocery")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                }
            }
        }
    }
}
