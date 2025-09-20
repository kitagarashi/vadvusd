import SwiftUI

struct FeedingPlanView: View {
    @EnvironmentObject var storage: StorageService
    @State private var selectedDate = Date()
    @State private var showingAddFeeding = false
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                
                Group {
                    let records = storage.getFeedingRecords(for: selectedDate)
                    if records.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "clock.badge.questionmark")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            
                            Text("No Feeding Records")
                                .font(.title2)
                                .fontWeight(.medium)
                            
                            Text("Track your pets' meals by adding feeding records.\nTap the + button to add your first record!")
                                .font(.body)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                            
                            if storage.animals.isEmpty {
                                Text("First, add some animals in the Animals tab")
                                    .font(.callout)
                                    .foregroundColor(.orange)
                                    .padding(.top, 5)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(UIColor.systemBackground))
                    } else {
                        List {
                            ForEach(records) { record in
                                if let animal = storage.animals.first(where: { $0.id == record.animalId }) {
                                    VStack(alignment: .leading) {
                                        Text(animal.name)
                                            .font(.headline)
                                        HStack {
                                            Text(record.foodType)
                                            Spacer()
                                            Text(record.time, style: .time)
                                        }
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Feeding Plan")
            .toolbar {
                Button(action: { showingAddFeeding = true }) {
                    Image(systemName: "plus")
                }
                .disabled(storage.animals.isEmpty)
            }
            .sheet(isPresented: $showingAddFeeding) {
                AddFeedingView(selectedDate: selectedDate)
            }
        }
    }
}

struct AddFeedingView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var storage: StorageService
    
    let selectedDate: Date
    
    @State private var selectedAnimal: Animal?
    @State private var foodType = ""
    @State private var selectedTime = Date()
    @FocusState private var isFoodTypeFocused: Bool
    
    private let commonFoodTypes = ["Dry Food", "Wet Food", "Treats", "Water"]
    
    var isFormValid: Bool {
        selectedAnimal != nil && !foodType.isEmpty
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "clock.badge.checkmark.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.accentColor)
                        Text(selectedDate, style: .date)
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // Animal Selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Select Pet")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(storage.animals) { animal in
                                    PetSelectionCard(
                                        animal: animal,
                                        isSelected: selectedAnimal?.id == animal.id,
                                        action: { selectedAnimal = animal }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(height: 100)
                    }
                    
                    // Food Type
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Food Type")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        TextField("Enter food type", text: $foodType)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($isFoodTypeFocused)
                            .padding(.horizontal)
                        
                        // Quick select buttons
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(commonFoodTypes, id: \.self) { type in
                                    Button(action: { foodType = type }) {
                                        Text(type)
                                            .font(.subheadline)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.accentColor, lineWidth: 1)
                                            )
                                            .foregroundColor(.accentColor)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Time Selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Feeding Time")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        DatePicker("", selection: $selectedTime, displayedComponents: [.hourAndMinute])
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden()
                    }
                    .padding(.horizontal)
                    
                    // Save Button
                    Button(action: saveFeeding) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Save Feeding Record")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? Color.accentColor : Color.gray)
                        .cornerRadius(12)
                    }
                    .disabled(!isFormValid)
                    .padding(.horizontal)
                    .padding(.top)
                }
            }
            .navigationTitle("Add Feeding")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() }
            )
        }
    }
    
    private func saveFeeding() {
        guard let animal = selectedAnimal, !foodType.isEmpty else { return }
        let record = FeedingRecord(
            animalId: animal.id,
            foodType: foodType,
            time: selectedTime,
            date: selectedDate
        )
        storage.addFeedingRecord(record)
        dismiss()
    }
}

struct PetSelectionCard: View {
    let animal: Animal
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: animal.typeInfo.type == .cat ? "cat.fill" : 
                                 (animal.typeInfo.type == .dog ? "dog.fill" : "pawprint.fill"))
                    .font(.system(size: 30))
                Text(animal.name)
                    .font(.caption)
                    .lineLimit(1)
            }
            .frame(width: 80, height: 80)
            .padding(8)
            .background(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: 2)
            )
        }
        .foregroundColor(isSelected ? .accentColor : .primary)
    }
}
