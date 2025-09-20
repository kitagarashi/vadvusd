import Foundation

class StorageService: ObservableObject {
    @Published var animals: [Animal] = []
    @Published var feedingRecords: [FeedingRecord] = []
    @Published var statistics: [StatisticsMetric] = []
    
    private let animalsKey = "animals"
    private let feedingRecordsKey = "feedingRecords"
    private let statisticsKey = "statistics"
    
    init() {
        loadData()
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: animalsKey),
           let decoded = try? JSONDecoder().decode([Animal].self, from: data) {
            animals = decoded
        } else {
            // Add default animals if no data exists
            animals = [
                Animal(
                    name: "Luna",
                    typeInfo: AnimalTypeInfo(type: .cat, customType: nil),
                    age: 3,
                    notes: "Loves to play with toys and sleep in sunny spots"
                ),
                Animal(
                    name: "Max",
                    typeInfo: AnimalTypeInfo(type: .dog, customType: nil),
                    age: 5,
                    notes: "Energetic and friendly, needs daily walks"
                ),
                Animal(
                    name: "Charlie",
                    typeInfo: AnimalTypeInfo(type: .dog, customType: nil),
                    age: 2,
                    notes: "Still learning basic commands, very food motivated"
                )
            ]
            saveAnimals()
        }
        
        if let data = UserDefaults.standard.data(forKey: feedingRecordsKey),
           let decoded = try? JSONDecoder().decode([FeedingRecord].self, from: data) {
            feedingRecords = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: statisticsKey),
           let decoded = try? JSONDecoder().decode([StatisticsMetric].self, from: data) {
            statistics = decoded
        } else {
            // Initialize default statistics metrics
            statistics = [
                StatisticsMetric(name: "Walks", value: 0),
                StatisticsMetric(name: "Vet Visits", value: 0)
            ]
            saveStatistics()
        }
    }
    
    func saveAnimals() {
        if let encoded = try? JSONEncoder().encode(animals) {
            UserDefaults.standard.set(encoded, forKey: animalsKey)
        }
    }
    
    func saveFeedingRecords() {
        if let encoded = try? JSONEncoder().encode(feedingRecords) {
            UserDefaults.standard.set(encoded, forKey: feedingRecordsKey)
        }
    }
    
    func saveStatistics() {
        if let encoded = try? JSONEncoder().encode(statistics) {
            UserDefaults.standard.set(encoded, forKey: statisticsKey)
        }
    }
    
    func addAnimal(_ animal: Animal) {
        animals.append(animal)
        saveAnimals()
    }
    
    func deleteAnimal(_ animal: Animal) {
        animals.removeAll { $0.id == animal.id }
        // Also remove related feeding records
        feedingRecords.removeAll { $0.animalId == animal.id }
        saveAnimals()
        saveFeedingRecords()
    }
    
    func addFeedingRecord(_ record: FeedingRecord) {
        feedingRecords.append(record)
        saveFeedingRecords()
    }
    
    func getFeedingRecords(for date: Date) -> [FeedingRecord] {
        let calendar = Calendar.current
        return feedingRecords.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    func updateStatistic(_ statistic: StatisticsMetric) {
        if let index = statistics.firstIndex(where: { $0.id == statistic.id }) {
            statistics[index] = statistic
            saveStatistics()
        }
    }
    
    func getAnimalTypeCount() -> [AnimalType: Int] {
        var counts: [AnimalType: Int] = [:]
        for type in AnimalType.allCases {
            counts[type] = animals.filter { $0.typeInfo.type == type }.count
        }
        return counts
    }
    
    func getAverageAge() -> Double {
        guard !animals.isEmpty else { return 0 }
        let totalAge = animals.reduce(0) { $0 + $1.age }
        return Double(totalAge) / Double(animals.count)
    }
}
