import SwiftUI

struct EditAnimalView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var storage: StorageService
    
    let animal: Animal
    
    @State private var name: String
    @State private var selectedType: AnimalType
    @State private var customType: String
    @State private var age: String
    @State private var notes: String
    
    init(animal: Animal) {
        self.animal = animal
        _name = State(initialValue: animal.name)
        _selectedType = State(initialValue: animal.typeInfo.type)
        _customType = State(initialValue: animal.typeInfo.customType ?? "")
        _age = State(initialValue: String(animal.age))
        _notes = State(initialValue: animal.notes)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Name", text: $name)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Type")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Picker("", selection: $selectedType) {
                            ForEach(AnimalType.allCases, id: \.self) { type in
                                Text(type.rawValue)
                                    .tag(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        if selectedType == .other {
                            TextField("Enter pet type", text: $customType)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    .animation(.easeInOut, value: selectedType)
                    
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Additional Information")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Edit \(animal.name)")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    saveChanges()
                }
                .disabled(name.isEmpty || age.isEmpty)
            )
        }
    }
    
    private func saveChanges() {
        guard let ageInt = Int(age) else { return }
        
        let updatedAnimal = Animal(
            id: animal.id,
            name: name,
                            typeInfo: AnimalTypeInfo(
                                type: selectedType,
                                customType: selectedType == .other ? customType : nil
                            ),
            age: ageInt,
            notes: notes
        )
        
        if let index = storage.animals.firstIndex(where: { $0.id == animal.id }) {
            storage.animals[index] = updatedAnimal
            storage.saveAnimals()
            dismiss()
        }
    }
}
