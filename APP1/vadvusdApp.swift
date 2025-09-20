//
//  vadvusdApp.swift
//  vadvusd
//
//  Created by Герман Юрченко on 18.09.25.
//

import SwiftUI

@main
struct vadvusdApp: App {
    @StateObject private var storage = StorageService()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var isOnboardingPresented = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environmentObject(storage)
                
                if !hasSeenOnboarding {
                    OnboardingView(isOnboardingPresented: Binding(
                        get: { !hasSeenOnboarding },
                        set: { newValue in
                            hasSeenOnboarding = !newValue
                        }
                    ))
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut, value: hasSeenOnboarding)
        }
    }
}
