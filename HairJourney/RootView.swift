import SwiftUI

struct RootView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @ObservedObject private var langManager = AppLanguageManager.shared
    
    var body: some View {
        NavigationStack {
            if authVM.isLoggedIn, let user = authVM.user {
                if user.role.lowercased() == "doctor" {
                    DoctorDashboardView(user: user)
                } else {
                    UserDashboardView(user: user)
                }
            } else {
                LoginChoiceView()
            }
        }
        .id("\(authVM.isLoggedIn)_\(langManager.currentLanguage.rawValue)")
    }
}

