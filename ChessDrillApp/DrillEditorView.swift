import SwiftUI

struct DrillEditorView: View {
    @EnvironmentObject var drillManager: DrillManager
    @Environment(\.dismiss) var dismiss
    
    @State private var drillName: String
    @State private var drillDescription: String
    @State private var pieces: [ChessPiece]
    @State private var isPracticeMode = false
    
    let editingDrill: Drill?
    
    init(drill: Drill? = nil) {
        self.editingDrill = drill
        _drillName = State(initialValue: drill?.name ?? "")
        _drillDescription = State(initialValue: drill?.description ?? "")
        _pieces = State(initialValue: drill?.pieces ?? [])
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Name and description
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Drill Name")
                            .font(.headline)
                        TextField("Enter drill name", text: $drillName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textContentType(.none)
                            .autocorrectionDisabled(true)
                        
                        Text("Description")
                            .font(.headline)
                        TextField("What's this drill for?", text: $drillDescription)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textContentType(.none)
                            .autocorrectionDisabled(true)
                    }
                    .padding(.horizontal)
                    
                    // Mode Picker
                    Picker("Mode", selection: $isPracticeMode) {
                        Text("Setup Pieces").tag(false)
                        Text("Practice Moves").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Chess board
                    ChessBoardView(pieces: $pieces, isPracticeMode: isPracticeMode)
                }
                .padding(.vertical)
            }
            .navigationTitle(editingDrill == nil ? "New Drill" : "Edit Drill")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(editingDrill == nil ? "Create" : "Save") {
                        saveDrill()
                    }
                    .disabled(drillName.isEmpty)
                    .fontWeight(.bold)
                }
            }
        }
    }
    
    private func saveDrill() {
        if let existing = editingDrill {
            // Update existing drill
            var updated = existing
            updated.name = drillName
            updated.description = drillDescription
            updated.pieces = pieces
            drillManager.updateDrill(updated)
        } else {
            // Create new drill
            let newDrill = Drill(
                name: drillName,
                description: drillDescription,
                pieces: pieces
            )
            drillManager.createDrill(newDrill)
        }
        dismiss()
    }
}
