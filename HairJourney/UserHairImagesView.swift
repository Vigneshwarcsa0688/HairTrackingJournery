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

            AsyncImage(url: url) { phase in
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
            AppTheme.gradient.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    VStack(spacing: 6) {
                        Text("Hair Progress Albums")
                            .font(.title.bold()).foregroundColor(AppTheme.titleText)
                        Text("Swipe through your 4-view clinical records")
                            .font(.subheadline).foregroundColor(AppTheme.bodyText)
                    }
                    .padding(.top)
                    .opacity(animate ? 1 : 0).offset(y: animate ? 0 : -20)
                    .animation(.easeOut(duration: 0.6), value: animate)

                    if albums.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 44)).foregroundColor(AppTheme.bodyText(0.4))
                            Text("No albums uploaded yet")
                                .foregroundColor(AppTheme.bodyText)
                        }.padding(.top, 40)
                    }

                    ForEach(albums) { album in
                        GlassCard {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(album.tag).font(.headline.bold()).foregroundColor(AppTheme.titleText)
                                        Text(album.date).font(.caption).foregroundColor(AppTheme.bodyText)
                                    }
                                    Spacer()
                                    Text("\(album.images.count) Views")
                                        .font(.caption2.bold()).padding(.horizontal, 8).padding(.vertical, 4)
                                        .background(Color.purple.opacity(0.15))
                                        .foregroundColor(.purple).cornerRadius(8)
                                }
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(album.images) { img in
                                            Button {
                                                if let url = URL(string: APIService.baseURL + img.image_path) {
                                                    fullScreenItem = IdentifiableURL(url: url)
                                                }
                                            } label: {
                                                VStack(alignment: .center, spacing: 8) {
                                                    AsyncImage(url: URL(string: APIService.baseURL + img.image_path)) { phase in
                                                        if let image = phase.image {
                                                            image.resizable().scaledToFill()
                                                                .frame(width: 140, height: 180).clipped().cornerRadius(12)
                                                        } else if phase.error != nil {
                                                            Color.red.opacity(0.1).frame(width: 140, height: 180).cornerRadius(12)
                                                        } else {
                                                            ZStack {
                                                                RoundedRectangle(cornerRadius: 12)
                                                                    .fill(Color.white.opacity(0.1)).frame(width: 140, height: 180)
                                                                ProgressView()
                                                            }
                                                        }
                                                    }
                                                    Text(img.view_type).font(.caption.bold()).foregroundColor(AppTheme.titleText)
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                // Show doctor remarks if any exist for this album
                                let remarks = album.images.compactMap { $0.doctor_remark }.filter { !$0.isEmpty }
                                if !remarks.isEmpty {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Label("Expert Feedback (from latest view)", systemImage: "stethoscope")
                                            .font(.subheadline.bold()).foregroundColor(AppTheme.titleText)
                                        Text(remarks.last ?? "")
                                            .padding(10).frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color.blue.opacity(0.08)).cornerRadius(12)
                                            .foregroundColor(AppTheme.titleText)
                                    }
                                } else {
                                    Label("Awaiting expert review", systemImage: "hourglass")
                                        .font(.caption).foregroundColor(.orange)
                                }
                            }
                        }
                        .opacity(animate ? 1 : 0).offset(y: animate ? 0 : 25)
                        .animation(.easeOut(duration: 0.7), value: animate)
                    }

                    Spacer(minLength: 40)
                }
                .padding()
                .frame(maxWidth: AppTheme.maxContentWidth(sizeClass))
                .frame(maxWidth: .infinity, alignment: .center)
            }
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
