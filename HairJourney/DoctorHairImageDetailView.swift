import SwiftUI

struct DoctorHairImageDetailView: View {
    var imageId: String
    var imageURL: String
    @State var existingRemark: String
    @State private var message = ""
    @State private var animate = false
    
    struct RemarkReq: Codable {
        let image_id: Int
        let doctor_remark: String
    }
    
    func submitRemark() {
        guard let url = URL(string: APIService.baseURL + "add_image_remark.php"),
              let id = Int(imageId) else { return }
        
        DoctorHairImagesManager.shared.updateRemark(imageId: imageId, remark: existingRemark)
        
        let body = RemarkReq(image_id: id, doctor_remark: existingRemark)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                message = "Remark saved successfully"
            }
        }.resume()
    }
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // Hair Image Card
                    GlassCard(cornerRadius: 24, padding: 16) {
                        CachedAsyncImage(url: URL(string: APIService.baseURL + imageURL)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.black.opacity(0.06), lineWidth: 1)
                                )
                        } placeholder: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.black.opacity(0.06))
                                    .frame(height: 240)
                                ProgressView().tint(AppTheme.primaryBrand)
                            }
                        }
                    }
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : -20)
                    .animation(.easeOut(duration: 0.6), value: animate)
                    
                    // Expert Remark Section
                    GlassCard(cornerRadius: 22, padding: 18) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                    .foregroundColor(AppTheme.primaryBrand)
                                Text("Expert Evaluation & Guidance")
                                    .font(.headline)
                                    .foregroundColor(AppTheme.titleText)
                            }
                            
                            TextEditor(text: $existingRemark)
                                .frame(minHeight: 120)
                                .padding(10)
                                .background(Color.white.opacity(0.7))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.black.opacity(0.08), lineWidth: 1)
                                )
                                .foregroundColor(AppTheme.titleText)
                            
                            if !message.isEmpty {
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text(message)
                                }
                                .font(.caption.bold())
                                .foregroundColor(.green)
                                .transition(.opacity)
                            }
                            
                            Button(action: {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                submitRemark()
                            }) {
                                Text("Save Expert Remark")
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            .padding(.top, 4)
                        }
                    }
                    .opacity(animate ? 1 : 0)
                    .animation(.easeOut(duration: 0.7), value: animate)
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
        }
        .navigationTitle("Image Review")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { animate = true }
    }
}

