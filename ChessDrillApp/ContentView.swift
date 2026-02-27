import SwiftUI

struct ContentView: View {
    @EnvironmentObject var drillManager: DrillManager
    @EnvironmentObject var storeManager: StoreManager
    @State private var showingEditor = false
    @State private var showingPaywall = false
    @State private var selectedDrill: Drill?
    @State private var drillToDelete: Drill?
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if drillManager.drills.isEmpty {
                    emptyStateView
                } else {
                    drillListView
                }
            }
            .navigationTitle("Chess Drills")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: createNewDrill) {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                
                if storeManager.isPremium {
                    ToolbarItem(placement: .navigationBarLeading) {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.yellow)
                            Text("Premium")
                                .font(.caption)
                                .foregroundColor(.yellow)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingEditor) {
                if let drill = selectedDrill {
                    DrillEditorView(drill: drill)
                        .environmentObject(drillManager)
                } else {
                    DrillEditorView()
                        .environmentObject(drillManager)
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
                    .environmentObject(drillManager)
                    .environmentObject(storeManager)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "chess.board")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("No Drills Yet")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Create your first chess drill to start practicing")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: createNewDrill) {
                Text("Create Your First Drill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }
    
    private var drillListView: some View {
        List {
            ForEach(drillManager.drills) { drill in
                DrillRowView(drill: drill, onShare: {
                    ShareService.shareDrill(drill)
                }, onDelete: {
                    drillToDelete = drill
                    showingDeleteConfirmation = true
                })
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedDrill = drill
                    showingEditor = true
                }
            }
            .onDelete(perform: deleteDrills)
        }
        .listStyle(InsetGroupedListStyle())
        .alert("Delete Drill?", isPresented: $showingDeleteConfirmation, presenting: drillToDelete) { drill in
            Button("Delete", role: .destructive) {
                drillManager.deleteDrill(drill)
            }
            Button("Cancel", role: .cancel) {}
        } message: { drill in
            Text("Are you sure you want to delete '\(drill.name)'?")
        }
    }
    
    private func createNewDrill() {
        if drillManager.canCreateNewDrill() {
            selectedDrill = nil
            showingEditor = true
        } else {
            showingPaywall = true
        }
    }
    
    private func deleteDrills(at offsets: IndexSet) {
        offsets.forEach { index in
            let drill = drillManager.drills[index]
            drillManager.deleteDrill(drill)
        }
    }
}

struct DrillRowView: View {
    let drill: Drill
    var onShare: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(drill.name)
                    .font(.headline)
                
                if !drill.description.isEmpty {
                    Text(drill.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Label("\(drill.pieces.count) pieces", systemImage: "circle.grid.3x3.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Text(drill.createdAt, style: .date)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Menu {
                Button(action: onShare) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                
                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title3)
                    .foregroundColor(.blue)
                    .padding(8)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView()
        .environmentObject(DrillManager())
        .environmentObject(StoreManager())
}
