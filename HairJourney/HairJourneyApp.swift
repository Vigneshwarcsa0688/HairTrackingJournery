import SwiftUI

@main
struct HairJourneyApp: App {
    
    @StateObject var authVM = AuthViewModel()   // 🔥 KEEP AS IS
    @State private var showSplash = true        // ✅ Splash state
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().tintColor = UIColor.white
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashView()
                        .transition(.opacity)
                } else {
                    RootView()
                        .environmentObject(authVM)   // 🔥 SAME LOGIC
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                    withAnimation {
                        showSplash = false
                    }
                }
            }
        }
    }
}

