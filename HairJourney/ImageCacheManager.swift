import SwiftUI

// MARK: - High-Performance Memory & Disk Image Cache
final class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    private let cache = NSCache<NSURL, UIImage>()
    private let session: URLSession
    
    private init() {
        cache.countLimit = 300
        cache.totalCostLimit = 150 * 1024 * 1024 // 150MB memory cache
        
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.urlCache = URLCache(
            memoryCapacity: 60 * 1024 * 1024,
            diskCapacity: 250 * 1024 * 1024,
            diskPath: "hair_journey_cache"
        )
        self.session = URLSession(configuration: config)
    }
    
    func get(for url: URL) -> UIImage? {
        cache.object(forKey: url as NSURL)
    }
    
    func set(_ image: UIImage, for url: URL) {
        let cost = Int(image.size.width * image.size.height * 4)
        cache.setObject(image, forKey: url as NSURL, cost: cost)
    }
    
    func prefetch(urls: [URL]) {
        for url in urls {
            if get(for: url) != nil { continue }
            session.dataTask(with: url) { [weak self] data, _, _ in
                guard let data = data, let image = UIImage(data: data) else { return }
                self?.set(image, for: url)
            }.resume()
        }
    }
    
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        if let cached = get(for: url) {
            completion(cached)
            return
        }
        
        session.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            self?.set(image, for: url)
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}

// MARK: - Helper for Content + Placeholder init
struct _CachedAsyncImageHelper<I: View, P: View>: View {
    let phase: AsyncImagePhase
    let content: (Image) -> I
    let placeholder: () -> P

    var body: some View {
        switch phase {
        case .success(let image):
            content(image)
        default:
            placeholder()
        }
    }
}

// MARK: - Instant Cached Async Image View
struct CachedAsyncImage<Content: View>: View {
    private let url: URL?
    private let content: (AsyncImagePhase) -> Content

    @State private var phase: AsyncImagePhase
    @State private var isFetching = false

    // Initializer 1: Matches standard SwiftUI `AsyncImage(url:) { phase in ... }`
    init(url: URL?, @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        self.url = url
        self.content = content
        if let url = url, let cached = ImageCacheManager.shared.get(for: url) {
            _phase = State(initialValue: .success(Image(uiImage: cached)))
        } else {
            _phase = State(initialValue: .empty)
        }
    }

    // Initializer 2: Matches `CachedAsyncImage(url:) { image in ... } placeholder: { ... }`
    init<I: View, P: View>(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> I,
        @ViewBuilder placeholder: @escaping () -> P
    ) where Content == _CachedAsyncImageHelper<I, P> {
        self.url = url
        self.content = { p in
            _CachedAsyncImageHelper(phase: p, content: content, placeholder: placeholder)
        }
        if let url = url, let cached = ImageCacheManager.shared.get(for: url) {
            _phase = State(initialValue: .success(Image(uiImage: cached)))
        } else {
            _phase = State(initialValue: .empty)
        }
    }

    var body: some View {
        content(phase)
            .onAppear {
                loadImage()
            }
    }

    private func loadImage() {
        guard let url = url else { return }
        if case .success = phase { return }
        guard !isFetching else { return }
        isFetching = true
        ImageCacheManager.shared.loadImage(from: url) { image in
            self.isFetching = false
            if let image = image {
                withAnimation(.easeOut(duration: 0.15)) {
                    self.phase = .success(Image(uiImage: image))
                }
            } else {
                self.phase = .failure(URLError(.cannotDecodeContentData))
            }
        }
    }
}
