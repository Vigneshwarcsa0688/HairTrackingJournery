import SwiftUI

import SwiftUI

struct DoctorDashboardView: View {
    var user: User
    @Environment(\.horizontalSizeClass) var sizeClass
    @State private var animate = false
    @ObservedObject private var langManager = AppLanguageManager.shared
    @ObservedObject private var specManager = ExpertSpecializationManager.shared

    var body: some View {
        TabView {
            ZStack {
                AppBackgroundView()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {

                        // ── Expert Header with Specialization & Language ──
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Text(langManager.text("expert_workspace"))
                                        .font(.system(size: 11, weight: .heavy))
                                        .tracking(1.2)
                                        .foregroundColor(AppTheme.emeraldMint)
                                    Image(systemName: "checkmark.seal.fill")
                                        .font(.system(size: 11))
                                        .foregroundColor(AppTheme.emeraldMint)
                                }
                                Text("Expert \(user.name)")
                                    .font(.system(size: AppTheme.heroTitleSize(sizeClass), weight: .bold, design: .rounded))
                                    .foregroundColor(AppTheme.titleText)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                
                                // Clinical Specialization Badge
                                HStack(spacing: 5) {
                                    Image(systemName: "cross.case.fill")
                                        .font(.system(size: 9))
                                    Text(specManager.getSpecialization(for: user.id))
                                        .font(.system(size: 11, weight: .bold))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.85				)
                                }
                                .padding(.horizontal, 9)
                                .padding(.vertical, 3.5)
                                .background(AppTheme.emeraldMint.opacity(0.12))
                                .foregroundColor(AppTheme.emeraldMint)
                                .clipShape(Capsule())
                            }
                            Spacer()
                            
                            // Expert Avatar
                            NavigationLink(destination: ProfileView(user: user)) {
                                ZStack {
                                    Circle()
                                        .fill(LinearGradient(colors: [AppTheme.emeraldMint, AppTheme.primaryBrand], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 48, height: 48)
                                        .shadow(color: AppTheme.emeraldMint.opacity(0.35), radius: 6, y: 3)
                                    
                                    Image(systemName: "person.badge.shield.checkmark.fill")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(.top, 8)
                        .opacity(animate ? 1 : 0)
                        .offset(y: animate ? 0 : -15)
                        .animation(.easeOut(duration: 0.6), value: animate)

                        // ── Member Portfolios Hero Dossier Card ──
                        GlassCard(cornerRadius: 22, paddingAmount: 20) {
                            NavigationLink(destination: DoctorPatientListView(doctor: user)) {
                                HStack(spacing: 16) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .fill(LinearGradient(colors: [AppTheme.emeraldMint, AppTheme.primaryBrand], startPoint: .topLeading, endPoint: .bottomTrailing))
                                            .frame(width: 58, height: 58)
                                            .shadow(color: AppTheme.emeraldMint.opacity(0.35), radius: 8, y: 4)
                                        
                                        Image(systemName: "folder.badge.person.crop")
                                            .foregroundColor(.white)
                                            .font(.system(size: 26, weight: .semibold))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(langManager.text("member_portfolios"))
                                                .font(.headline.weight(.bold))
                                                .foregroundColor(AppTheme.titleText)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.85)
                                            Spacer()
                                            Text("PRIMARY")
                                                .font(.system(size: 9, weight: .heavy))
                                                .foregroundColor(AppTheme.emeraldMint)
                                                .padding(.horizontal, 7)
                                                .padding(.vertical, 3)
                                                .background(AppTheme.emeraldMint.opacity(0.12))
                                                .clipShape(Capsule())
                                        }
                                        
                                        Text(langManager.text("member_portfolios_desc"))
                                            .font(.caption)
                                            .foregroundColor(AppTheme.bodyText(0.8))
                                            .lineLimit(2)
                                    }
                                    
                                    Image(systemName: "chevron.right.circle.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(AppTheme.primaryBrand.opacity(0.8))
                                }
                            }
                            .buttonStyle(InteractiveCardButtonStyle())
                        }
                        .opacity(animate ? 1 : 0)
                        .offset(y: animate ? 0 : 15)
                        .animation(.easeOut(duration: 0.65), value: animate)

                        // ── SECTION 1: Consultations & Appointments ──
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeaderView(
                                title: langManager.text("consultations_section"),
                                subtitle: "Management",
                                icon: "calendar.badge.clock"
                            )
                            
                            LazyVGrid(columns: AppTheme.dashboardColumns(sizeClass), spacing: 14) {
                                GlassCard(cornerRadius: 18, paddingAmount: 16) {
                                    NavigationLink(destination: DoctorAppointmentsView(doctor: user)) {
                                        DashboardRow(
                                            icon: "person.2.fill",
                                            title: langManager.text("appointment_requests"),
                                            subtitle: langManager.text("appointment_requests_desc"),
                                            iconGradient: LinearGradient(colors: [AppTheme.amberWarm, Color.orange], startPoint: .topLeading, endPoint: .bottomTrailing),
                                            badgeText: "REQUESTS",
                                            badgeColor: AppTheme.amberWarm
                                        )
                                    }
                                    .buttonStyle(InteractiveCardButtonStyle())
                                }

                                GlassCard(cornerRadius: 18, paddingAmount: 16) {
                                    NavigationLink(destination: CreateSlotView(doctor: user)) {
                                        DashboardRow(
                                            icon: "calendar.badge.plus",
                                            title: "Create Slot",
                                            subtitle: "Open new availability for members",
                                            iconGradient: AppTheme.brandGradient,
                                            badgeText: "NEW",
                                            badgeColor: AppTheme.primaryBrand
                                        )
                                    }
                                    .buttonStyle(InteractiveCardButtonStyle())
                                }

                                GlassCard(cornerRadius: 18, paddingAmount: 16) {
                                    NavigationLink(destination: DoctorSlotsView(doctor: user)) {
                                        DashboardRow(
                                            icon: "clock.fill",
                                            title: langManager.text("consultation_slots"),
                                            subtitle: langManager.text("consultation_slots_desc"),
                                            iconGradient: LinearGradient(colors: [Color.teal, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                                        )
                                    }
                                    .buttonStyle(InteractiveCardButtonStyle())
                                }
                            }
                        }

                        // ── SECTION 2: Progress Reviews & Reports ──
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeaderView(
                                title: langManager.text("progress_data_section"),
                                subtitle: "Assessments",
                                icon: "chart.bar.doc.horizontal"
                            )
                            
                            LazyVGrid(columns: AppTheme.dashboardColumns(sizeClass), spacing: 14) {
                                GlassCard(cornerRadius: 18, paddingAmount: 16) {
                                    NavigationLink(destination: DoctorHairImagesView()) {
                                        DashboardRow(
                                            icon: "photo.stack.fill",
                                            title: langManager.text("hair_photo_reviews"),
                                            subtitle: langManager.text("hair_photo_reviews_desc"),
                                            iconGradient: LinearGradient(colors: [Color.cyan, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                                            badgeText: "PHOTOS",
                                            badgeColor: .cyan
                                        )
                                    }
                                    .buttonStyle(InteractiveCardButtonStyle())
                                }

                                GlassCard(cornerRadius: 18, paddingAmount: 16) {
                                    NavigationLink(destination: DoctorQuizReportsListView()) {
                                        DashboardRow(
                                            icon: "doc.text.magnifyingglass",
                                            title: langManager.text("quiz_reports_feed"),
                                            subtitle: langManager.text("quiz_reports_feed_desc"),
                                            iconGradient: LinearGradient(colors: [AppTheme.irisPurple, Color.purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                                        )
                                    }
                                    .buttonStyle(InteractiveCardButtonStyle())
                                }
                            }
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 16)
                    .frame(maxWidth: AppTheme.maxContentWidth(sizeClass))
                    .frame(maxWidth: .infinity, alignment: .top)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .tabItem { Label(langManager.text("expert_workspace"), systemImage: "person.badge.shield.checkmark.fill") }

            ProfileView(user: user)
                .tabItem { Label(langManager.text("profile"), systemImage: "person.crop.circle.fill") }
        }
        .onAppear { 
            animate = true 
            DoctorHairImagesManager.shared.prefetch()
        }
    }
}

