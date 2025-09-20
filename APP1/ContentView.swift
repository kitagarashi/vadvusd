//
//  ContentView.swift
//  vadvusd
//
//  Created by Герман Юрченко on 18.09.25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            AnimalsView()
                .tabItem {
                    Label("Animals", systemImage: "pawprint.fill")
                }
            
            FeedingPlanView()
                .tabItem {
                    Label("Feeding", systemImage: "clock.fill")
                }
            
            StatisticsView()
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar.fill")
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(StorageService())
}
