import Foundation

enum AnimalType: String, Codable, CaseIterable {
    case cat = "Cat"
    case dog = "Dog"
    case other = "Other"
}

struct AnimalTypeInfo: Codable, Hashable {
    let type: AnimalType
    let customType: String?
    
    var displayName: String {
        if type == .other && customType != nil {
            return customType!
        }
        return type.rawValue
    }
}

struct Animal: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var typeInfo: AnimalTypeInfo
    var age: Int
    var notes: String
    
    init(id: UUID = UUID(), name: String, typeInfo: AnimalTypeInfo, age: Int, notes: String) {
        self.id = id
        self.name = name
        self.typeInfo = typeInfo
        self.age = age
        self.notes = notes
    }
}

struct FeedingRecord: Identifiable, Codable {
    let id: UUID
    var animalId: UUID
    var foodType: String
    var time: Date
    var date: Date
    
    init(id: UUID = UUID(), animalId: UUID, foodType: String, time: Date, date: Date) {
        self.id = id
        self.animalId = animalId
        self.foodType = foodType
        self.time = time
        self.date = date
    }
}

struct StatisticsMetric: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var value: Int
    
    init(id: UUID = UUID(), name: String, value: Int) {
        self.id = id
        self.name = name
        self.value = value
    }
}
