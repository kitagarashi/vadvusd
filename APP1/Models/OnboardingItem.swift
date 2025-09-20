import SwiftUI

struct OnboardingItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let image: String
    let color: Color
    static let items = [
        OnboardingItem(
            title: "Track Your Pets",
            description: "Keep all information about your pets in one place. Add their details, notes, and track their growth.",
            image: "pawprint.fill",
            color: .blue
        ),
        OnboardingItem(
            title: "Feeding Schedule",
            description: "Never miss a meal! Set up feeding schedules and track what and when your pets eat.",
            image: "clock.fill",
            color: .orange
        ),
        OnboardingItem(
            title: "Monitor Progress",
            description: "Track important metrics and see how your pets are doing over time with detailed statistics.",
            image: "chart.bar.fill",
            color: .purple
        )
    ]
}
