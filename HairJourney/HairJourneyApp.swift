import SwiftUI

@main
struct HairJourneyApp: App {
    
    @StateObject var authVM = AuthViewModel()   // 🔥 KEEP AS IS
    @StateObject var langManager = AppLanguageManager.shared
    @State private var showSplash = true        // ✅ Splash state
    @AppStorage("has_chosen_initial_app_language") private var hasChosenInitialLanguage = false
    
    init() {
        let navTitleColor = UIColor(red: 0.12, green: 0.18, blue: 0.35, alpha: 1.0)
        let navTintColor  = UIColor(red: 0.18, green: 0.42, blue: 0.88, alpha: 1.0)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: navTitleColor, .font: UIFont.systemFont(ofSize: 17, weight: .bold)]
        appearance.largeTitleTextAttributes = [.foregroundColor: navTitleColor, .font: UIFont.systemFont(ofSize: 34, weight: .bold)]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = navTintColor
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
                        .environmentObject(langManager)
                        .transition(.opacity)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        showSplash = false
                    }
                }
            }
        }
    }
}

