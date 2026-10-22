import SwiftUI

// MARK: - Model
struct UserHairImageItem: Codable, Identifiable {
    var id: String
    var image_path: String
    var doctor_remark: String?
    var progress_tag: String
    var view_type: String
    var capture_date: String
    var created_at: String
}

// Album grouping
struct HairAlbum: Identifiable {
    let id = UUID()
    let tag: String
    let date: String
    let images: [UserHairImageItem]
}

struct FullScreenImageViewer: View {
    let url: URL
    @Environment(\.dismiss) var dismiss
    @State private var scale: CGFloat = 1.0
    @GestureState private var magnifyBy: CGFloat = 1.0

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            CachedAsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(scale * magnifyBy)
                        .gesture(
                            MagnificationGesture()
                                .updating($magnifyBy) { current, state, _ in
                                    state = current
                                }
                                .onEnded { value in
                                    scale = max(1.0, scale * value)
                                }
                        )
                        .onTapGesture(count: 2) {
                            withAnimation { scale = 1.0 }
                        }
                case .failure:
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.largeTitle).foregroundColor(.orange)
                        Text("Failed to load image")
                            .foregroundColor(.white)
                    }
                default:
                    ProgressView().tint(.white)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(20)
            }
        }
        .background(Color.black)
    }
}

struct UserHairImagesView: View {
    var user: User
    @State private var allImages: [UserHairImageItem] = []
    @State private var albums: [HairAlbum] = []
    @State private var animate = false
    @State private var fullScreenItem: IdentifiableURL? = nil
    
    @Environment(\.horizontalSizeClass) var sizeClass

    func fetchImages() {
        guard let url = URL(string: APIService.baseURL + "get_user_hair_images.php?user_id=\(user.id)") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                guard let data = data else { return }
                do {
                    let decoded = try JSONDecoder().decode([UserHairImageItem].self, from: data)
                    self.allImages = decoded
                    
                    // Group by (capture_date, progress_tag)
                    var grouped = [String: [UserHairImageItem]]()
                    for img in decoded {
                        let key = "\(img.capture_date)||\(img.progress_tag)"
                        grouped[key, default: []].append(img)
                    }
                    
                    self.albums = grouped.map { key, imgs in
                        let parts = key.components(separatedBy: "||")
                        return HairAlbum(tag: parts[1], date: parts[0], images: imgs)
                    }.sorted(by: { $0.date > $1.date })
                    
                } catch {
                    print("Decode error: \(error)")
                }
            }
        }.resume()
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {

                    VStack(spacing: 6) {
                        Text("Hair Progress Albums")
                            .font(.title2.bold())
                            .foregroundColor(AppTheme.titleText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                        Text("Review multi-angle progress photography and expert feedback")
                            .font(.subheadline).foregroundColor(AppTheme.bodyText(0.75))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 16)
                    .opacity(animate ? 1 : 0).offset(y: animate ? 0 : -15)
                    .animation(.easeOut(duration: 0.6), value: animate)

                    if albums.isEmpty {
                        GlassCard(cornerRadius: 22, paddingAmount: 24) {
                            VStack(spacing: 12) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 44)).foregroundColor(AppTheme.bodyText(0.35))
                                Text("No Albums Uploaded Yet")
                                    .font(.headline.bold())
                                    .foregroundColor(AppTheme.titleText)
                                Text("Document your baseline and progress photos across 4 progress angles to view your visual transformation.")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.bodyText(0.75))
                                    .multilineTextAlignment(.center)
                                
                                NavigationLink(destination: UploadHairImageView(user: user)) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "camera.badge.plus")
                                        Text("Upload First Album")
                                    }
                                }
                                .buttonStyle(PrimaryButtonStyle(height: 46))
                                .padding(.top, 6)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                        }
                        .padding(.top, 20)
                    }

                    ForEach(albums) { album in
                        GlassCard(cornerRadius: 22, paddingAmount: 18) {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(album.tag)
                                            .font(.headline.weight(.bold))
                                            .foregroundColor(AppTheme.titleText)
                                        Text(formatDate(album.date))
                                            .font(.caption)
                                            .foregroundColor(AppTheme.bodyText(0.75))
                                    }
                                    Spacer()
                                    
                                    HStack(spacing: 4) {
                                        Image(systemName: "square.2.layers.3d.top.filled")
                                            .font(.system(size: 10))
                                        Text("\(album.images.count) Perspectives")
                                            .font(.system(size: 10, weight: .heavy))
                                    }
                                    .padding(.horizontal, 9)
                                    .padding(.vertical, 5)
                                    .background(AppTheme.primaryBrand.opacity(0.12))
                                    .foregroundColor(AppTheme.primaryBrand)
                                    .clipShape(Capsule())
                                }
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 14) {
                                        ForEach(album.images) { img in
                                            Button {
                                                if let url = URL(string: APIService.baseURL + img.image_path) {
                                                    fullScreenItem = IdentifiableURL(url: url)
                                                }
                                            } label: {
                                                VStack(alignment: .center, spacing: 8) {
                                                    CachedAsyncImage(url: URL(string: APIService.baseURL + img.image_path)) { phase in
                                                        if let image = phase.image {
                                                            image.resizable().scaledToFill()
                                                                .frame(width: 145, height: 185)
                                                                .clipped()
                                                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                                                .overlay(
                                                                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                                                                        .font(.system(size: 11, weight: .bold))
                                                                        .padding(5)
                                                                        .background(.ultraThinMaterial)
                                                                        .clipShape(Circle())
                                                                        .foregroundColor(.white)
                                                                        .padding(6),
                                                                    alignment: .topTrailing
                                                                )
                                                        } else if phase.error != nil {
                                                            Color.red.opacity(0.1).frame(width: 145, height: 185)
                                                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                                        } else {
                                                            ZStack {
                                                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                                    .fill(Color.white.opacity(0.2))
                                                                    .frame(width: 145, height: 185)
                                                                ProgressView().tint(AppTheme.primaryBrand)
                                                            }
                                                        }
                                                    }
                                                    
                                                    Text(img.view_type)
                                                        .font(.caption.weight(.bold))
                                                        .foregroundColor(AppTheme.titleText)
                                                }
                                            }
                                        }
                                    }
                                    .padding(.vertical, 2)
                                }
                                
                                // Show doctor remarks if any exist for this album
                                let remarks = album.images.compactMap { $0.doctor_remark }.filter { !$0.isEmpty }
                                if !remarks.isEmpty {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Label("Expert Feedback", systemImage: "sparkles")
                                            .font(.caption.bold())
                                            .foregroundColor(AppTheme.primaryBrand)
                                        Text(remarks.last ?? "")
                                            .font(.caption)
                                            .padding(10)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(AppTheme.primaryBrand.opacity(0.08))
                                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                            .foregroundColor(AppTheme.titleText)
                                    }
                                } else {
                                    HStack(spacing: 5) {
                                        Image(systemName: "hourglass")
                                        Text("Awaiting specialist review")
                                    }
                                    .font(.caption)
                                    .foregroundColor(AppTheme.amberWarm)
                                }
                            }
                        }
                        .opacity(animate ? 1 : 0)
                        .offset(y: animate ? 0 : 20)
                        .animation(.easeOut(duration: 0.65), value: animate)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 16)
                .frame(maxWidth: AppTheme.maxContentWidth(sizeClass))
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("My Hair Albums")
                    .font(.headline.bold())
                    .foregroundColor(AppTheme.titleText)
            }
        }
        .onAppear { animate = true; fetchImages() }
        .fullScreenCover(item: $fullScreenItem) { item in
            FullScreenImageViewer(url: item.url)
        }
    }
}
