import SwiftUI

// MARK: - Hair Progress Compare View
struct HairProgressCompareView: View {
    var user: User
    @State private var images: [UserHairImageItem] = []
    @State private var selectedTab = 0
    @State private var animate = false
    @State private var fullScreenItem: IdentifiableURL? = nil

    // Compare states
    @State private var selectedViewType = "Frontal"
    @State private var leftHandle: CGFloat  = 0.33   // baseline | 3months boundary
    @State private var rightHandle: CGFloat = 0.67   // 3months | 6months boundary

    @Environment(\.horizontalSizeClass) var sizeClass

    let stages    = ["Baseline", "3 Months", "6 Months"]
    let viewTypes = ["Frontal", "Left Lateral", "Right Lateral", "Vertex"]

    func fetchImages() {
        guard let url = URL(string: APIService.baseURL + "get_user_hair_images.php?user_id=\(user.id)") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                if let data = data {
                    images = (try? JSONDecoder().decode([UserHairImageItem].self, from: data)) ?? []
                }
            }
        }.resume()
    }

    func image(for stage: String) -> UserHairImageItem? {
        images.first { $0.progress_tag == stage && $0.view_type == selectedViewType }
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 6) {
                    Text("Hair Progress Tracker")
                        .font(.title2.bold())
                        .foregroundColor(AppTheme.titleText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                    Text("Visual timeline and growth stage comparisons")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.bodyText(0.75))
                }
                .padding(.top, 16)
                .padding(.bottom, 12)
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : -15)
                .animation(.easeOut(duration: 0.6), value: animate)

                // Segment Switcher
                HStack(spacing: 8) {
                    tabPill("Timeline Feed", isSelected: selectedTab == 0) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedTab = 0 }
                    }
                    tabPill("Compare Stages", isSelected: selectedTab == 1) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedTab = 1 }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 12)

                if selectedTab == 1 {
                    // View Angle Filter
                    ViewAngleSelector(options: viewTypes, selected: $selectedViewType)
                        .padding(.horizontal)
                        .padding(.bottom, 12)
                }

                ScrollView(.vertical, showsIndicators: false) {
                    if selectedTab == 0 {
                        timelineTab
                    } else {
                        compareTab
                    }
                }
                .frame(maxWidth: AppTheme.maxContentWidth(sizeClass))
                .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Hair Progress Tracker")
                    .font(.headline.bold())
                    .foregroundColor(AppTheme.titleText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
        }
        .onAppear { animate = true; fetchImages() }
        .fullScreenCover(item: $fullScreenItem) { item in
            FullScreenImageViewer(url: item.url)
        }
    }

    @ViewBuilder
    private func tabPill(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        }) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(isSelected ? .white : AppTheme.titleText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .background(
                    isSelected
                        ? AnyView(AppTheme.brandGradient)
                        : AnyView(Color.white.opacity(0.65))
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color.white, lineWidth: 1)
                )
                .shadow(color: isSelected ? AppTheme.primaryBrand.opacity(0.25) : Color.black.opacity(0.03), radius: 6, y: 2)
        }
    }

    // MARK: - Stage Comparison Tab
    var compareTab: some View {
        VStack(spacing: 18) {
            ForEach(stages, id: \.self) { stage in
                let matchedImg = image(for: stage)
                
                GlassCard(cornerRadius: 22, paddingAmount: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(stage)
                                    .font(.headline.weight(.bold))
                                    .foregroundColor(AppTheme.titleText)
                                if let img = matchedImg {
                                    Text("Captured: \(formatDate(img.capture_date))")
                                        .font(.caption2)
                                        .foregroundColor(AppTheme.bodyText(0.7))
                                }
                            }
                            Spacer()
                            
                            Text(selectedViewType)
                                .font(.caption2.bold())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(AppTheme.primaryBrand.opacity(0.12))
                                .foregroundColor(AppTheme.primaryBrand)
                                .clipShape(Capsule())
                        }

                        if let img = matchedImg, let url = URL(string: APIService.baseURL + img.image_path) {
                            Button {
                                fullScreenItem = IdentifiableURL(url: url)
                            } label: {
                                CachedAsyncImage(url: url) { phase in
                                    if let image = phase.image {
                                        image.resizable().scaledToFill()
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 220)
                                            .clipped()
                                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                            .overlay(
                                                HStack(spacing: 4) {
                                                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                                                    Text("Tap to Zoom")
                                                }
                                                .font(.caption2.bold())
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 5)
                                                .background(.ultraThinMaterial)
                                                .clipShape(Capsule())
                                                .foregroundColor(.white)
                                                .padding(10),
                                                alignment: .topTrailing
                                            )
                                    } else {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.2)).frame(height: 220)
                                            ProgressView().tint(AppTheme.primaryBrand)
                                        }
                                    }
                                }
                            }

                            if let remark = img.doctor_remark, !remark.isEmpty {
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(AppTheme.emeraldMint)
                                        .font(.caption)
                                    Text(remark)
                                        .font(.caption)
                                        .foregroundColor(AppTheme.bodyText)
                                }
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(AppTheme.emeraldMint.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.black.opacity(0.03))
                                    .frame(height: 140)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                                            .foregroundColor(Color.black.opacity(0.12))
                                    )
                                
                                VStack(spacing: 6) {
                                    Image(systemName: "camera.badge.ellipsis")
                                        .font(.system(size: 28))
                                        .foregroundColor(AppTheme.bodyText(0.35))
                                    Text("No \(selectedViewType) photo logged for \(stage)")
                                        .font(.caption)
                                        .foregroundColor(AppTheme.bodyText(0.6))
                                }
                            }
                        }
                    }
                }
            }
            Spacer(minLength: 40)
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }

    // MARK: - Timeline Tab
    var timelineTab: some View {
        VStack(spacing: 0) {
            ForEach(images.indices, id: \.self) { i in
                let img = images[i]
                HStack(alignment: .top, spacing: 14) {
                    VStack(spacing: 0) {
                        Circle()
                            .fill(AppTheme.brandGradient)
                            .frame(width: 16, height: 16)
                            .shadow(color: AppTheme.primaryBrand.opacity(0.4), radius: 4)
                        if i < images.count - 1 {
                            Rectangle()
                                .fill(AppTheme.primaryBrand.opacity(0.25))
                                .frame(width: 2)
                                .frame(maxHeight: .infinity)
                        }
                    }
                    .frame(width: 16)

                    GlassCard(cornerRadius: 20, paddingAmount: 16) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(img.progress_tag)
                                        .font(.headline.weight(.bold))
                                        .foregroundColor(AppTheme.titleText)
                                    Text(formatDate(img.capture_date))
                                        .font(.caption)
                                        .foregroundColor(AppTheme.bodyText(0.75))
                                }
                                Spacer()
                                Text(img.view_type)
                                    .font(.caption2.bold())
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(AppTheme.amberWarm.opacity(0.15))
                                    .foregroundColor(AppTheme.amberWarm)
                                    .clipShape(Capsule())
                            }

                            Button {
                                if let url = URL(string: APIService.baseURL + img.image_path) {
                                    fullScreenItem = IdentifiableURL(url: url)
                                }
                            } label: {
                                CachedAsyncImage(url: URL(string: APIService.baseURL + img.image_path)) { phase in
                                    if let image = phase.image {
                                        image.resizable().scaledToFill()
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 200)
                                            .clipped()
                                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                            .overlay(
                                                Image(systemName: "arrow.up.left.and.arrow.down.right")
                                                    .font(.system(size: 11, weight: .bold))
                                                    .padding(6)
                                                    .background(.ultraThinMaterial)
                                                    .clipShape(Circle())
                                                    .foregroundColor(.white)
                                                    .padding(8),
                                                alignment: .topTrailing
                                            )
                                    } else {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.1)).frame(height: 200)
                                            ProgressView().tint(AppTheme.primaryBrand)
                                        }
                                    }
                                }
                            }

                            if let remark = img.doctor_remark, !remark.isEmpty {
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(AppTheme.primaryBrand)
                                        .font(.caption)
                                    Text(remark)
                                        .font(.caption)
                                        .foregroundColor(AppTheme.bodyText)
                                }
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(AppTheme.primaryBrand.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, i < images.count - 1 ? 16 : 24)
            }

            if images.isEmpty {
                GlassCard(cornerRadius: 22, paddingAmount: 24) {
                    VStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 40))
                            .foregroundColor(AppTheme.bodyText(0.35))
                        Text("No Progress Photos Yet")
                            .font(.headline.bold())
                            .foregroundColor(AppTheme.titleText)
                        Text("Upload photos of your scalp across Baseline, 3 Months & 6 Months to see your transformation over time.")
                            .font(.caption)
                            .foregroundColor(AppTheme.bodyText(0.75))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 10)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
            }

            Spacer(minLength: 40)
        }
        .padding(.top, 8)
    }
}
