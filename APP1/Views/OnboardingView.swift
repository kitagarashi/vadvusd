import SwiftUI

struct OnboardingView: View {
    @Binding var isOnboardingPresented: Bool
    @State private var currentPage = 0
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(OnboardingItem.items.indices, id: \.self) { index in
                        OnboardingPageView(item: OnboardingItem.items[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // Page Control and Button
                VStack(spacing: 20) {
                    PageControl(numberOfPages: OnboardingItem.items.count, currentPage: currentPage)
                    
                    Button(action: {
                        if currentPage < OnboardingItem.items.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            withAnimation {
                                isOnboardingPresented = false
                            }
                        }
                    }) {
                        Text(currentPage < OnboardingItem.items.count - 1 ? "Next" : "Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct OnboardingPageView: View {
    let item: OnboardingItem
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Animated Icon
            ZStack {
                Circle()
                    .fill(item.color.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .scaleEffect(isAnimating ? 1 : 0.5)
                    .opacity(isAnimating ? 1 : 0)
                
                Circle()
                    .fill(item.color.opacity(0.2))
                    .frame(width: 160, height: 160)
                    .scaleEffect(isAnimating ? 1 : 0.5)
                    .opacity(isAnimating ? 1 : 0)
                
                Circle()
                    .fill(item.color.opacity(0.3))
                    .frame(width: 120, height: 120)
                    .scaleEffect(isAnimating ? 1 : 0.5)
                    .opacity(isAnimating ? 1 : 0)
                
                Image(systemName: item.image)
                    .font(.system(size: 60))
                    .foregroundColor(item.color)
                    .scaleEffect(isAnimating ? 1 : 0.1)
                    .opacity(isAnimating ? 1 : 0)
            }
            .frame(height: 250)
            .offset(y: isAnimating ? 0 : 50)
            
            // Text Content
            VStack(spacing: 16) {
                Text(item.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .offset(x: isAnimating ? 0 : -30)
                    .opacity(isAnimating ? 1 : 0)
                
                Text(item.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .offset(x: isAnimating ? 0 : 30)
                    .opacity(isAnimating ? 1 : 0)
            }
            
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                isAnimating = true
            }
        }
        .onDisappear {
            isAnimating = false
        }
    }
}

struct PageControl: View {
    let numberOfPages: Int
    let currentPage: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { page in
                Circle()
                    .fill(page == currentPage ? Color.accentColor : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .scaleEffect(page == currentPage ? 1.2 : 1)
                    .animation(.spring(), value: currentPage)
            }
        }
    }
}
