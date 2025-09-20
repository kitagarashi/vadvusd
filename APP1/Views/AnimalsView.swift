import SwiftUI

struct AnimalsView: View {
    @EnvironmentObject var storage: StorageService
    @State private var showingAddAnimal = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(storage.animals) { animal in
                    NavigationLink(destination: AnimalDetailView(animal: animal)) {
                        VStack(alignment: .leading) {
                            Text(animal.name)
                                .font(.headline)
                            HStack {
                                Text(animal.typeInfo.displayName)
                                Text("•")
                                Text("\(animal.age) years")
                            }
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            if !animal.notes.isEmpty {
                                Text(animal.notes)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteAnimal)
            }
            .navigationTitle("Animals")
            .toolbar {
                Button(action: { showingAddAnimal = true }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddAnimal) {
                AddAnimalView()
            }
        }
    }
    
    private func deleteAnimal(at offsets: IndexSet) {
        for index in offsets {
            storage.deleteAnimal(storage.animals[index])
        }
    }
}

struct AddAnimalView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var storage: StorageService
    
    @State private var name = ""
    @State private var selectedType = AnimalType.cat
    @State private var customType = ""
    @State private var age = ""
    @State private var notes = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, age, notes, customType
    }
    
    var isFormValid: Bool {
        !name.isEmpty && !age.isEmpty && Int(age) != nil && 
        (selectedType != .other || (selectedType == .other && !customType.isEmpty))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Image
                    Image(systemName: selectedType == .cat ? "cat.fill" : (selectedType == .dog ? "dog.fill" : "pawprint.fill"))
                        .font(.system(size: 60))
                        .foregroundColor(.accentColor)
                        .padding(.top, 20)
                    
                    // Form Fields
                    VStack(spacing: 20) {
                        // Name Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Name")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            TextField("Enter pet's name", text: $name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .focused($focusedField, equals: .name)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .age
                                }
                        }
                        .padding(.horizontal)
                        
                        // Type Picker
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
                                    .focused($focusedField, equals: .customType)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        focusedField = .age
                                    }
                            }
                        }
                        .padding(.horizontal)
                        .animation(.easeInOut, value: selectedType)
                        
                        // Age Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Age")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            TextField("Enter age in years", text: $age)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                                .focused($focusedField, equals: .age)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .notes
                                }
                            if !age.isEmpty && Int(age) == nil {
                                Text("Please enter a valid number")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Notes Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            TextEditor(text: $notes)
                                .frame(height: 100)
                                .focused($focusedField, equals: .notes)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Save Button
                    Button(action: saveAnimal) {
                        Text("Add Pet")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isFormValid ? Color.accentColor : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(!isFormValid)
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
            }
            .navigationTitle("Add New Pet")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() }
            )
        }
    }
    
    private func saveAnimal() {
        guard let ageInt = Int(age), !name.isEmpty else { return }
        
        let typeInfo = AnimalTypeInfo(
            type: selectedType,
            customType: selectedType == .other ? customType : nil
        )
        
        let animal = Animal(
            name: name,
            typeInfo: typeInfo,
            age: ageInt,
            notes: notes
        )
        storage.addAnimal(animal)
        dismiss()
    }
}
