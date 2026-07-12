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
            AppTheme.gradient.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    
                    // MARK: Hair Image Card
                    GlassCard {
                        AsyncImage(url: URL(string: APIService.baseURL + imageURL)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(16)
                        } placeholder: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 220)
                                ProgressView()
                            }
                        }
                    }
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : -20)
                    .animation(.easeOut(duration: 0.6), value: animate)
                    
                    // MARK: Doctor Remark Section
                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "stethoscope")
                                Text("Doctor Evaluation")
                                    .font(.headline)
                            }
                            .foregroundColor(AppTheme.titleText)

                            
                            TextEditor(text: $existingRemark)
                                .frame(height: 140)
                                .padding(10)
                                .background(Color.white.opacity(0.12))
                                .cornerRadius(12)
                                .foregroundColor(AppTheme.titleText)

                        }
                    }
                    .opacity(animate ? 1 : 0)
                    .animation(.easeOut(duration: 0.7), value: animate)
                    
                    // MARK: Save Button
                    Button(action: submitRemark) {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                            Text("Save Medical Remark")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(AppTheme.titleText)

                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(colors: [.green, .mint],
                                           startPoint: .leading,
                                           endPoint: .trailing)
                        )
                        .cornerRadius(14)
                        .shadow(color: .green.opacity(0.4), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 4)
                    
                    if !message.isEmpty {
                        Text(message)
                            .foregroundColor(.green)
                            .font(.subheadline)
                            .padding(.top, 6)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding()
            }
        }
        .navigationTitle("Image Review")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { animate = true }
    }
}

