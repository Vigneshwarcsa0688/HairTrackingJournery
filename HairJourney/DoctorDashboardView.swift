import SwiftUI

struct DoctorDashboardView: View {
    var user: User
    @Environment(\.horizontalSizeClass) var sizeClass
    @State private var animate = false

    var body: some View {
        TabView {
            ZStack {
                AppTheme.gradient.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {

                        // ── Welcome Header ──
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Welcome Expert,")
                                .foregroundColor(AppTheme.bodyText)
                            Text(user.name)
                                .font(.largeTitle.bold())
                                .foregroundColor(AppTheme.titleText)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(animate ? 1 : 0).offset(y: animate ? 0 : -20)
                        .animation(.easeOut(duration: 0.6), value: animate)

                        // ── Member Portfolio (NEW - Primary Feature) ──
                        GlassCard {
                            NavigationLink(destination: DoctorPatientListView(doctor: user)) {
                                HStack(spacing: 16) {
                                    ZStack {
                                        Circle()
                                            .fill(AppTheme.premiumAccentGradient)
                                            .frame(width: 58, height: 58)
                                            .shadow(color: AppTheme.accent.opacity(0.35), radius: 8, y: 4)
                                        Image(systemName: "folder.badge.person.crop").foregroundColor(.white).font(.title3.bold())
                                    }
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Patient Portfolios")
                                            .font(.headline.bold()).foregroundColor(AppTheme.titleText)
                                        Text("Full history, clinical photos & compliance scores")
                                            .font(.caption).foregroundColor(AppTheme.bodyText).lineLimit(2)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(AppTheme.accent.opacity(0.8))
                                }
                            }
                        }
                        .overlay(
                            // "NEW" badge
                            Text("NEW")
                                .font(.system(size: 9, weight: .heavy))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8).padding(.vertical, 4)
                                .background(AppTheme.error).cornerRadius(6)
                                .shadow(color: AppTheme.error.opacity(0.4), radius: 4, y: 2)
                                .padding(.top, -6).padding(.trailing, 4),
                            alignment: .topTrailing
                        )
                        .opacity(animate ? 1 : 0)
                        .animation(.easeOut(duration: 0.5), value: animate)

                        LazyVGrid(columns: AppTheme.dashboardColumns(sizeClass), spacing: 20) {
                            GlassCard {
                                NavigationLink(destination: CreateSlotView(doctor: user)) {
                                    DashboardRow(icon: "calendar.badge.plus", title: "Create Slot", subtitle: "Add appointment times")
                                }
                            }

                            GlassCard {
                                NavigationLink(destination: DoctorSlotsView(doctor: user)) {
                                    DashboardRow(icon: "clock.fill", title: "My Slots", subtitle: "View created slots")
                                }
                            }

                            GlassCard {
                                NavigationLink(destination: DoctorAppointmentsView(doctor: user)) {
                                    DashboardRow(icon: "person.2.fill", title: "Appointment Requests", subtitle: "Approve or reject bookings")
                                }
                            }
                        }
                        .opacity(animate ? 1 : 0)
                        .animation(.easeOut(duration: 0.7), value: animate)

                        Spacer(minLength: 40)
                    }
                    .padding()
                    .frame(maxWidth: AppTheme.maxContentWidth(sizeClass))
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .tabItem { Label("Dashboard", systemImage: "stethoscope") }

            ProfileView(user: user)
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
        }
        .onAppear { animate = true }
    }
}
