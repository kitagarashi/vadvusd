import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var storage: StorageService
    @State private var showingAddMetric = false
    @State private var selectedMetric: StatisticsMetric?
    
    private var averageAge: Double {
        storage.getAverageAge()
    }
    
    private var totalAnimals: Int {
        storage.animals.count
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Summary Card
                    VStack(spacing: 16) {
                        HStack(spacing: 20) {
                            StatCard(
                                title: "Total Pets",
                                value: "\(totalAnimals)",
                                icon: "pawprint.fill",
                                color: .blue
                            )
                            
                            StatCard(
                                title: "Average Age",
                                value: String(format: "%.1f", averageAge),
                                icon: "calendar",
                                color: .purple
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Pet Types Distribution
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Pet Distribution")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(AnimalType.allCases, id: \.self) { type in
                                    let count = storage.getAnimalTypeCount()[type] ?? 0
                                    TypeDistributionCard(
                                        type: type,
                                        count: count,
                                        total: totalAnimals
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Custom Metrics
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Custom Metrics")
                                .font(.headline)
                            Spacer()
                            Button(action: { showingAddMetric = true }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .padding(.horizontal)
                        
                        if storage.statistics.isEmpty {
                            EmptyMetricsView()
                        } else {
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                ForEach(storage.statistics) { metric in
                                    MetricCard(metric: metric) {
                                        selectedMetric = metric
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Statistics")
            .sheet(isPresented: $showingAddMetric) {
                AddMetricView()
            }
            .sheet(item: $selectedMetric) { metric in
                MetricDetailView(metric: metric)
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .foregroundColor(.secondary)
            }
            .font(.subheadline)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct TypeDistributionCard: View {
    let type: AnimalType
    let count: Int
    let total: Int
    
    private var percentage: Double {
        total == 0 ? 0 : (Double(count) / Double(total)) * 100
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: type == .cat ? "cat.fill" : 
                                 (type == .dog ? "dog.fill" : "pawprint.fill"))
                Text(type.rawValue)
            }
            .font(.headline)
            
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(String(format: "%.1f%%", percentage))
                .font(.caption)
                .foregroundColor(.secondary)
            
            ProgressView(value: percentage, total: 100)
                .tint(type == .cat ? .orange : 
                      (type == .dog ? .blue : .purple))
        }
        .frame(width: 120)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct MetricCard: View {
    let metric: StatisticsMetric
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(metric.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text("\(metric.value)")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EmptyMetricsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            Text("No Custom Metrics")
                .font(.headline)
            Text("Add metrics to track important pet activities")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct MetricDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var storage: StorageService
    let metric: StatisticsMetric
    @State private var value: Int
    
    init(metric: StatisticsMetric) {
        self.metric = metric
        _value = State(initialValue: metric.value)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text(metric.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Current Value")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Value Stepper
                HStack {
                    Button(action: { value -= 1 }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title)
                            .foregroundColor(.red)
                    }
                    
                    Text("\(value)")
                        .font(.system(size: 48, weight: .bold))
                        .frame(minWidth: 100)
                        .animation(.spring(), value: value)
                    
                    Button(action: { value += 1 }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
                
                Spacer()
            }
            .padding()
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    var updatedMetric = metric
                    updatedMetric.value = value
                    storage.updateStatistic(updatedMetric)
                    dismiss()
                }
            )
        }
    }
}

struct AddMetricView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var storage: StorageService
    
    @State private var name = ""
    @State private var value = 0
    @State private var selectedTemplate: MetricTemplate?
    @FocusState private var isNameFocused: Bool
    
    private let metricTemplates = [
        MetricTemplate(name: "Walks", icon: "figure.walk"),
        MetricTemplate(name: "Vet Visits", icon: "cross.case"),
        MetricTemplate(name: "Grooming", icon: "scissors"),
        MetricTemplate(name: "Training", icon: "star"),
        MetricTemplate(name: "Play Time", icon: "sportscourt"),
        MetricTemplate(name: "Medicine", icon: "pills")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.accentColor)
                        Text("Track What Matters")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // Templates
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Add")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(metricTemplates) { template in
                                    MetricTemplateCard(
                                        template: template,
                                        isSelected: selectedTemplate?.name == template.name,
                                        action: {
                                            selectedTemplate = template
                                            name = template.name
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Custom Metric Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Metric Name")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        TextField("Enter metric name", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($isNameFocused)
                    }
                    .padding(.horizontal)
                    
                    // Value Selector
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Initial Value")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Button(action: { if value > 0 { value -= 1 } }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.accentColor)
                            }
                            
                            Text("\(value)")
                                .font(.title)
                                .frame(minWidth: 60)
                                .multilineTextAlignment(.center)
                            
                            Button(action: { value += 1 }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Save Button
                    Button(action: saveMetric) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Add Metric")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(!name.isEmpty ? Color.accentColor : Color.gray)
                        .cornerRadius(12)
                    }
                    .disabled(name.isEmpty)
                    .padding(.horizontal)
                    .padding(.top)
                }
            }
            .navigationTitle("Add New Metric")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() }
            )
        }
    }
    
    private func saveMetric() {
        guard !name.isEmpty else { return }
        let metric = StatisticsMetric(name: name, value: value)
        storage.statistics.append(metric)
        storage.saveStatistics()
        dismiss()
    }
}

struct MetricTemplate: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
}

struct MetricTemplateCard: View {
    let template: MetricTemplate
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: template.icon)
                    .font(.system(size: 30))
                Text(template.name)
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
