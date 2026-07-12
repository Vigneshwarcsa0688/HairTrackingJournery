import SwiftUI

struct HairImageItem: Codable, Identifiable {
    var id: String
    var patient_name: String
    var image_path: String
    var doctor_remark: String?
}

struct DoctorHairImagesView: View {
    @State private var images: [HairImageItem] = []
    @State private var animate = false
    
    func fetchImages() {
        guard let url = URL(string: APIService.baseURL + "get_all_hair_images.php") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Fetch error:", error.localizedDescription)
                    return
                }
                
                guard let safeData = data else {
                    print("No data received")
                    return
                }
                
                do {
                    images = try JSONDecoder().decode([HairImageItem].self, from: safeData)
                } catch {
                    print("Decode error:", error)
                }
            }
        }.resume()
    }
    
    var body: some View {
        ZStack {
            AppTheme.gradient.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    
                    // MARK: Header
                    VStack(spacing: 6) {
                        Text("Patient Hair Images")
                            .font(.title.bold())
                            .foregroundColor(AppTheme.titleText)

                        
                        Text("Review progress & add medical remarks")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.bodyText)
                    }
                    .padding(.top)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : -20)
                    .animation(.easeOut(duration: 0.6), value: animate)
                    
                    // MARK: Image Cards
                    ForEach(images) { item in
                        GlassCard {
                            NavigationLink(destination: DoctorHairImageDetailView(
                                imageId: item.id,
                                imageURL: item.image_path,
                                existingRemark: item.doctor_remark ?? ""
                            )) {
                                HStack(spacing: 14) {
                                    
                                    AsyncImage(url: URL(string: APIService.baseURL + item.image_path)) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 70, height: 70)
                                            .clipped()
                                            .cornerRadius(12)
                                    } placeholder: {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white.opacity(0.1))
                                                .frame(width: 70, height: 70)
                                            ProgressView()
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(item.patient_name)
                                            .font(.headline)
                                            .foregroundColor(AppTheme.titleText)

                                        
                                        if let remark = item.doctor_remark, !remark.isEmpty {
                                            HStack(spacing: 4) {
                                                Image(systemName: "checkmark.seal.fill")
                                                Text("Remark Added")
                                            }
                                            .font(.caption)
                                            .foregroundColor(.green)
                                        } else {
                                            HStack(spacing: 4) {
                                                Image(systemName: "hourglass")
                                                Text("Awaiting Review")
                                            }
                                            .font(.caption)
                                            .foregroundColor(.yellow)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(AppTheme.bodyText(0.7))
                                }
                            }
                        }
                        .opacity(animate ? 1 : 0)
                        .offset(y: animate ? 0 : 25)
                        .animation(.easeOut(duration: 0.7), value: animate)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding()
            }
        }
        .navigationTitle("Hair Images")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            animate = true
            fetchImages()
        }
    }
}

