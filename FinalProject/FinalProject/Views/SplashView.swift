import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Image(systemName: "fork.knife.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                    
                    VStack(spacing: 8) {
                        Text("MealMatch")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("By Elyes Seffar")
                            .font(.system(size: 20))
                            .foregroundColor(.secondary)
                        
                        Text("Z23608883")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .onAppear {
                // Show splash screen for 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
} 