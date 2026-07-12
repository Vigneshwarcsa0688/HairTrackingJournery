import SwiftUI

struct RootView: View {
    @EnvironmentObject var authVM: AuthViewModel
    
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
        .id(authVM.isLoggedIn) // Forces navigation stack reset on login/logout
    }
}

