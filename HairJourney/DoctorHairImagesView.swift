import SwiftUI

struct HairImageItem: Codable, Identifiable {
    var id: String
    var patient_name: String
    var image_path: String
    var doctor_remark: String?
}

// MARK: - Shared Fast Hair Images Manager (Instant Local Cache & Preheating)
final class DoctorHairImagesManager: ObservableObject {
    static let shared = DoctorHairImagesManager()
    
    @Published var images: [HairImageItem] = []
    @Published var isInitialLoading: Bool = false
    
    private let cacheKey = "cached_doctor_hair_images_list"
    private var isFetching = false
    
    private init() {
        loadFromCache()
    }
    
    private func loadFromCache() {
        if let data = UserDefaults.standard.data(forKey: cacheKey),
           let cached = try? JSONDecoder().decode([HairImageItem].self, from: data) {
            self.images = cached
            preheat(cached)
        }
    }
    
    private func saveToCache(_ items: [HairImageItem]) {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: cacheKey)
        }
    }
    
    private func preheat(_ items: [HairImageItem]) {
        let urls = items.compactMap { URL(string: APIService.baseURL + $0.image_path) }
        ImageCacheManager.shared.prefetch(urls: urls)
    }
    
    func prefetch() {
        fetchImages(silent: true)
    }
    
    func fetchImages(silent: Bool = false, completion: ((Bool) -> Void)? = nil) {
        if isFetching { 
            completion?(false)
            return 
        }
        isFetching = true
        
        if images.isEmpty && !silent {
            isInitialLoading = true
        }
        
        guard let url = URL(string: APIService.baseURL + "get_all_hair_images.php") else {
            isFetching = false
            isInitialLoading = false
            completion?(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isFetching = false
                self.isInitialLoading = false
                
                guard let data = data,
                      let decoded = try? JSONDecoder().decode([HairImageItem].self, from: data) else {
                    completion?(false)
                    return
                }
                
                self.images = decoded
                self.saveToCache(decoded)
                self.preheat(decoded)
                completion?(true)
            }
        }.resume()
    }
    
    func updateRemark(imageId: String, remark: String) {
        if let idx = images.firstIndex(where: { $0.id == imageId }) {
            images[idx].doctor_remark = remark
            saveToCache(images)
        }
    }
}

// MARK: - Distinct Custom Scalp & Photo Loading Animation View
struct ScalpScannerLoadingView: View {
    @State private var rotateOuter = false
    @State private var rotateInner = false
    @State private var pulseScale = false
    @State private var scanLineOffset: CGFloat = -35
    @State private var progressWidth: CGFloat = 0.25
    
    var body: some View {
        VStack(spacing: 22) {
            
            // ── Diagnostic Radial Scanner ──
            ZStack {
                // Background Ambient Glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AppTheme.emeraldMint.opacity(0.3), AppTheme.primaryBrand.opacity(0.12), Color.clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 75
                        )
                    )
                    .frame(width: 150, height: 150)
                    .scaleEffect(pulseScale ? 1.15 : 0.95)
                
                // Outer Dashed Rotating Ring
                Circle()
                    .strokeBorder(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                AppTheme.emeraldMint,
                                AppTheme.primaryBrand,
                                Color.cyan,
                                AppTheme.irisPurple,
                                AppTheme.emeraldMint
                            ]),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 3, dash: [8, 6])
                    )
                    .frame(width: 110, height: 110)
                    .rotationEffect(.degrees(rotateOuter ? 360 : 0))
                
                // Inner Counter-Rotating Gradient Ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [AppTheme.primaryBrand, Color.cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 86, height: 86)
                    .rotationEffect(.degrees(rotateInner ? -360 : 0))
                
                // Frosted Core Lens with Scalp/Photo Icon
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.85))
                        .frame(width: 68, height: 68)
                        .shadow(color: AppTheme.primaryBrand.opacity(0.25), radius: 8, y: 3)
                    
                    Image(systemName: "photo.stack.fill")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppTheme.primaryBrand, AppTheme.emeraldMint],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(pulseScale ? 1.06 : 0.94)
                    
                    // Sweeping Laser Beam across the lens
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.clear, AppTheme.emeraldMint, Color.clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 52, height: 2.5)
                        .shadow(color: AppTheme.emeraldMint, radius: 4)
                        .offset(y: scanLineOffset)
                        .clipShape(Circle())
                }
            }
            .padding(.top, 10)
            
            // ── Status Text & Progress Bar ──
            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AppTheme.emeraldMint)
                    Text("Loading Scalp Photo Reviews")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.titleText)
                }
                
                Text("Fetching & syncing high-resolution member submissions...")
                    .font(.caption)
                    .foregroundColor(AppTheme.bodyText(0.75))
                    .multilineTextAlignment(.center)
                
                // Animated Progress Bar with Traveling Sheen
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.black.opacity(0.06))
                            .frame(height: 5)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [AppTheme.emeraldMint, AppTheme.primaryBrand, Color.cyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * progressWidth, height: 5)
                            .shadow(color: AppTheme.emeraldMint.opacity(0.4), radius: 3)
                    }
                }
                .frame(width: 200, height: 5)
                .padding(.top, 4)
            }
            
            // ── Anticipatory Skeleton Cards (3 rows) ──
            VStack(spacing: 12) {
                ForEach(0..<3, id: \.self) { idx in
                    GlassCard(cornerRadius: 18, paddingAmount: 14) {
                        HStack(spacing: 14) {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.black.opacity(0.05))
                                .frame(width: 74, height: 74)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color.black.opacity(0.12))
                                )
                            
                            VStack(alignment: .leading, spacing: 10) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.black.opacity(0.08))
                                    .frame(width: 135, height: 16)
                                
                                HStack(spacing: 6) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.black.opacity(0.05))
                                        .frame(width: 95, height: 20)
                                    Spacer()
                                }
                            }
                            
                            Spacer()
                            
                            Circle()
                                .fill(Color.black.opacity(0.04))
                                .frame(width: 22, height: 22)
                        }
                    }
                    .shimmering(duration: 1.8)
                    .opacity(1.0 - Double(idx) * 0.18)
                }
            }
            .padding(.top, 6)
        }
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                rotateOuter = true
            }
            withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
                rotateInner = true
            }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulseScale = true
            }
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                scanLineOffset = 25
            }
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                progressWidth = 0.95
            }
        }
    }
}

struct DoctorHairImagesView: View {
    @ObservedObject private var manager = DoctorHairImagesManager.shared
    @State private var isLoading = true
    @State private var showImages = false
    @State private var animateHeader = false
    
    private func loadData(force: Bool = false) {
        isLoading = true
        showImages = false
        
        let startTime = Date()
        manager.fetchImages(silent: false) { _ in
            let elapsed = Date().timeIntervalSince(startTime)
            // Ensures the distinctive loading animation plays for at least 0.70s for a smooth, high-end feel
            let minDuration: TimeInterval = 0.70
            let delay = max(0.0, minDuration - elapsed)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: 0.35)) {
                    self.isLoading = false
                }
                withAnimation(.easeOut(duration: 0.45).delay(0.06)) {
                    self.showImages = true
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // Header
                    VStack(spacing: 6) {
                        Text("Member Hair Photos")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.titleText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                        
                        Text("Review photo updates and provide expert guidance")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.bodyText)
                    }
                    .padding(.top, 12)
                    .opacity(animateHeader ? 1 : 0)
                    .offset(y: animateHeader ? 0 : -20)
                    .animation(.easeOut(duration: 0.6), value: animateHeader)
                    
                    if isLoading {
                        // ── Custom Loading Animation ──
                        ScalpScannerLoadingView()
                            .transition(.opacity.combined(with: .scale(scale: 0.98)))
                            .padding(.top, 6)
                    } else if manager.images.isEmpty {
                        // ── Empty State ──
                        GlassCard(cornerRadius: 20, paddingAmount: 24) {
                            VStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(AppTheme.primaryBrand.opacity(0.12))
                                        .frame(width: 60, height: 60)
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .font(.system(size: 28))
                                        .foregroundColor(AppTheme.primaryBrand)
                                }
                                
                                Text("No Images Uploaded")
                                    .font(.headline)
                                    .foregroundColor(AppTheme.titleText)
                                
                                Text("Member progress photo submissions will appear here for your expert evaluation.")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.bodyText)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                        }
                        .padding(.top, 20)
                        .transition(.opacity)
                    } else {
                        // ── Review Stats Counter ──
                        HStack {
                            HStack(spacing: 6) {
                                Image(systemName: "photo.stack.fill")
                                    .font(.caption.bold())
                                    .foregroundColor(AppTheme.primaryBrand)
                                Text("\(manager.images.count) Photo Reviews")
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(AppTheme.titleText)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(AppTheme.primaryBrand.opacity(0.1))
                            .clipShape(Capsule())
                            
                            Spacer()
                            
                            let reviewedCount = manager.images.filter { ($0.doctor_remark?.isEmpty == false) }.count
                            Text("\(reviewedCount) Reviewed")
                                .font(.caption2.weight(.semibold))
                                .foregroundColor(AppTheme.bodyText(0.75))
                        }
                        .padding(.horizontal, 4)
                        .opacity(showImages ? 1 : 0)
                        .animation(.easeOut(duration: 0.4), value: showImages)
                        
                        // ── All Photos Perfectly Rendered ──
                        ForEach(Array(manager.images.enumerated()), id: \.element.id) { index, item in
                            GlassCard(cornerRadius: 18, paddingAmount: 14) {
                                NavigationLink(destination: DoctorHairImageDetailView(
                                    imageId: item.id,
                                    imageURL: item.image_path,
                                    existingRemark: item.doctor_remark ?? ""
                                )) {
                                    HStack(spacing: 14) {
                                        
                                        // High-clarity cached thumbnail with smooth shimmer placeholder
                                        CachedAsyncImage(url: URL(string: APIService.baseURL + item.image_path)) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 74, height: 74)
                                                .clipped()
                                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                        .stroke(Color.black.opacity(0.08), lineWidth: 1)
                                                )
                                        } placeholder: {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                    .fill(LinearGradient(colors: [Color.black.opacity(0.04), Color.black.opacity(0.07)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                                    .frame(width: 74, height: 74)
                                                
                                                Image(systemName: "photo")
                                                    .font(.system(size: 20))
                                                    .foregroundColor(AppTheme.primaryBrand.opacity(0.4))
                                            }
                                            .shimmering(duration: 1.8)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(item.patient_name)
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(AppTheme.titleText)
                                                .lineLimit(1)
                                            
                                            if let remark = item.doctor_remark, !remark.isEmpty {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    HStack(spacing: 4) {
                                                        Image(systemName: "checkmark.seal.fill")
                                                            .font(.system(size: 11))
                                                        Text("Remark Added")
                                                            .font(.system(size: 11, weight: .bold))
                                                    }
                                                    .foregroundColor(AppTheme.emeraldMint)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 3)
                                                    .background(AppTheme.emeraldMint.opacity(0.12))
                                                    .clipShape(Capsule())
                                                    
                                                    Text(remark)
                                                        .font(.caption2)
                                                        .foregroundColor(AppTheme.bodyText(0.75))
                                                        .lineLimit(1)
                                                }
                                            } else {
                                                HStack(spacing: 4) {
                                                    Image(systemName: "clock.fill")
                                                        .font(.system(size: 11))
                                                    Text("Awaiting Review")
                                                        .font(.system(size: 11, weight: .bold))
                                                }
                                                .foregroundColor(AppTheme.amberWarm)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 3)
                                                .background(AppTheme.amberWarm.opacity(0.12))
                                                .clipShape(Capsule())
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(AppTheme.primaryBrand.opacity(0.7))
                                    }
                                }
                                .buttonStyle(InteractiveCardButtonStyle())
                            }
                            .opacity(showImages ? 1 : 0)
                            .offset(y: showImages ? 0 : 20)
                            .animation(
                                .spring(response: 0.45, dampingFraction: 0.8)
                                .delay(Double(min(index, 10)) * 0.05),
                                value: showImages
                            )
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
            }
            .refreshable {
                loadData(force: true)
            }
        }
        .navigationTitle("Hair Photos")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    loadData(force: true)
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.primaryBrand)
                }
            }
        }
        .onAppear {
            animateHeader = true
            loadData()
        }
    }
}

