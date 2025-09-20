import SwiftUI

struct AnimalDetailView: View {
    @EnvironmentObject var storage: StorageService
    @State private var showingEditSheet = false
    @State private var currentAnimal: Animal
    
    init(animal: Animal) {
        _currentAnimal = State(initialValue: animal)
    }
    
    private var todayFeedings: [FeedingRecord] {
        storage.getFeedingRecords(for: Date())
            .filter { $0.animalId == currentAnimal.id }
    }
    
    var body: some View {
        List {
            Section("General Information") {
                DetailRow(title: "Name", value: currentAnimal.name)
                DetailRow(title: "Type", value: currentAnimal.typeInfo.displayName)
                DetailRow(title: "Age", value: "\(currentAnimal.age) years")
            }
            
            if !currentAnimal.notes.isEmpty {
                Section("Notes") {
                    Text(currentAnimal.notes)
                        .foregroundColor(.secondary)
                }
            }
            
            Section("Today's Feedings") {
                if todayFeedings.isEmpty {
                    Text("No feedings recorded today")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(todayFeedings) { feeding in
                        VStack(alignment: .leading) {
                            Text(feeding.foodType)
                                .font(.headline)
                            Text(feeding.time, style: .time)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle(currentAnimal.name)
        .toolbar {
            Button("Edit") {
                showingEditSheet = true
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditAnimalView(animal: currentAnimal)
                .onDisappear {
                    if let updatedAnimal = storage.animals.first(where: { $0.id == currentAnimal.id }) {
                        currentAnimal = updatedAnimal
                    }
                }
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
        }
    }
}
