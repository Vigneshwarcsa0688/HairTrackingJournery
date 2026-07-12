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
            AppTheme.gradient.ignoresSafeArea()
            VStack(spacing: 0) {

                // Header
                VStack(spacing: 6) {
                    Text("Photo Progress").font(.title.bold()).foregroundColor(AppTheme.titleText)
                    Text("Track your hair transformation").font(.subheadline).foregroundColor(AppTheme.bodyText)
                }.padding(.top, 20).padding(.bottom, 12)
                .opacity(animate ? 1 : 0).offset(y: animate ? 0 : -20)
                .animation(.easeOut(duration: 0.6), value: animate)

                ScrollView(showsIndicators: false) {
                    timelineTab
                }
                .frame(maxWidth: AppTheme.maxContentWidth(sizeClass))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Progress Tracker")
                    .font(.headline.bold())
                    .foregroundColor(AppTheme.titleText)
            }
        }
        .onAppear { animate = true; fetchImages() }
        .fullScreenCover(item: $fullScreenItem) { item in
            FullScreenImageViewer(url: item.url)
        }
    }



    // MARK: - Timeline Tab
    var timelineTab: some View {
        VStack(spacing: 0) {
            ForEach(images.indices, id: \.self) { i in
                let img = images[i]
                HStack(alignment: .top, spacing: 16) {
                    VStack(spacing: 0) {
                        Circle().fill(AppTheme.accent).frame(width: 16, height: 16)
                            .shadow(color: AppTheme.accent.opacity(0.4), radius: 4)
                        if i < images.count - 1 {
                            Rectangle().fill(AppTheme.accent.opacity(0.3)).frame(width: 2).frame(maxHeight: .infinity)
                        }
                    }.frame(width: 16)

                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(img.progress_tag).font(.headline.bold()).foregroundColor(AppTheme.titleText)
                                    Text(img.capture_date).font(.caption).foregroundColor(AppTheme.bodyText)
                                }
                                Spacer()
                                Text(img.view_type).font(.caption2.bold())
                                    .padding(.horizontal, 8).padding(.vertical, 4)
                                    .background(Color.orange.opacity(0.15)).foregroundColor(.orange).cornerRadius(8)
                            }

                            Button {
                                if let url = URL(string: APIService.baseURL + img.image_path) {
                                    fullScreenItem = IdentifiableURL(url: url)
                                }
                            } label: {
                                AsyncImage(url: URL(string: APIService.baseURL + img.image_path)) { phase in
                                    if let image = phase.image {
                                        image.resizable().scaledToFill()
                                            .frame(maxWidth: .infinity).frame(height: 200).clipped().cornerRadius(14)
                                            .overlay(Image(systemName: "arrow.up.left.and.arrow.down.right")
                                                .padding(6).background(.ultraThinMaterial).cornerRadius(8)
                                                .foregroundColor(.white), alignment: .topTrailing)
                                    } else {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.1)).frame(height: 200)
                                            ProgressView()
                                        }
                                    }
                                }
                            }

                            if let remark = img.doctor_remark, !remark.isEmpty {
                                Label("Expert remark: \(remark)", systemImage: "stethoscope")
                                    .font(.caption).foregroundColor(AppTheme.bodyText)
                                    .padding(8).background(Color.blue.opacity(0.07)).cornerRadius(10)
                            }
                        }
                    }.frame(maxWidth: .infinity)
                }
                .padding(.horizontal).padding(.bottom, i < images.count - 1 ? 0 : 24)
            }

            if images.isEmpty {
                GlassCard {
                    VStack(spacing: 8) {
                        Image(systemName: "camera.fill").font(.largeTitle).foregroundColor(AppTheme.bodyText(0.4))
                        Text("No images uploaded yet.").multilineTextAlignment(.center).foregroundColor(AppTheme.bodyText)
                    }
                }.padding(.horizontal).padding(.top, 20)
            }

            Spacer(minLength: 40)
        }.padding(.top, 8)
    }
}
