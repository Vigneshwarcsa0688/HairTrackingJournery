import SwiftUI
import PhotosUI

struct UploadHairImageView: View {
    var user: User
    
    @State private var frontalImage: UIImage?
    @State private var leftImage: UIImage?
    @State private var rightImage: UIImage?
    @State private var vertexImage: UIImage?
    
    @State private var activePicker: String? = nil
    @State private var pickerItem: PhotosPickerItem?
    
    @State private var message = ""
    @State private var progressTag = "Baseline"
    @State private var captureDate = Date()
    @State private var animate = false
    @State private var isUploading = false
    
    @Environment(\.horizontalSizeClass) var sizeClass
    
    func uploadAlbum() {
        guard let frontal = frontalImage?.jpegData(compressionQuality: 0.8),
              let left = leftImage?.jpegData(compressionQuality: 0.8),
              let right = rightImage?.jpegData(compressionQuality: 0.8),
              let vertex = vertexImage?.jpegData(compressionQuality: 0.8),
              let url = URL(string: APIService.baseURL + "upload_hair_image.php") else {
            message = "⚠️ Please select all 4 required angles."
            return
        }
        
        isUploading = true
        message = ""
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        func appendText(_ key: String, _ value: String) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        func appendFile(_ key: String, _ data: Data) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(key).jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(data)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        appendText("user_id", "\(user.id)")
        appendText("progress_tag", progressTag)
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        appendText("capture_date", df.string(from: captureDate))
        
        appendFile("image_frontal", frontal)
        appendFile("image_left", left)
        appendFile("image_right", right)
        appendFile("image_vertex", vertex)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                isUploading = false
                withAnimation {
                    message = "✅ Album uploaded successfully!"
                    frontalImage = nil
                    leftImage = nil
                    rightImage = nil
                    vertexImage = nil
                }
            }
        }.resume()
    }
    
    var body: some View {
        ZStack {
            AppTheme.gradient.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    
                    // HEADER
                    VStack(spacing: 10) {
                        Image(systemName: "camera.metering.matrix")
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.titleText)
                            .scaleEffect(animate ? 1 : 0.6)
                            .animation(.spring(response: 0.6), value: animate)
                        
                        Text("Clinical Album Upload")
                            .font(.title.bold())
                            .foregroundColor(AppTheme.titleText)
                        
                        Text("Upload all 4 angles to form a complete clinical record.")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.bodyText)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)
                    
                    GlassCard {
                        VStack(spacing: 22) {
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Tracker Phase").font(.caption.bold()).foregroundColor(AppTheme.bodyText)
                                Picker("Phase", selection: $progressTag) {
                                    Text("Baseline").tag("Baseline")
                                    Text("3 Months").tag("3 Months")
                                    Text("6 Months").tag("6 Months")
                                }.pickerStyle(.segmented)
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Capture Date").font(.caption.bold()).foregroundColor(AppTheme.bodyText)
                                DatePicker("", selection: $captureDate, displayedComponents: .date)
                                    .labelsHidden()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            Divider()
                            
                            Text("Capture all 4 angles")
                                .font(.headline).foregroundColor(AppTheme.titleText)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                imageSlot(title: "Frontal", image: $frontalImage, key: "frontal")
                                imageSlot(title: "Left Lateral", image: $leftImage, key: "left")
                                imageSlot(title: "Right Lateral", image: $rightImage, key: "right")
                                imageSlot(title: "Vertex", image: $vertexImage, key: "vertex")
                            }
                            
                            Button {
                                uploadAlbum()
                            } label: {
                                HStack {
                                    if isUploading { ProgressView().tint(.white).padding(.trailing, 4) }
                                    Text(isUploading ? "Uploading..." : "Save Album")
                                }
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            .disabled(isUploading)
                            
                            if !message.isEmpty {
                                Text(message)
                                    .font(.caption.bold())
                                    .foregroundColor(message.contains("✅") ? .green : .red)
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }
                    .onChange(of: pickerItem) {
                        Task {
                            guard let pItem = pickerItem,
                                  let data = try? await pItem.loadTransferable(type: Data.self),
                                  let uiImg = UIImage(data: data) else { return }
                            
                            switch activePicker {
                            case "frontal": frontalImage = uiImg
                            case "left": leftImage = uiImg
                            case "right": rightImage = uiImg
                            case "vertex": vertexImage = uiImg
                            default: break
                            }
                            pickerItem = nil
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding()
                .frame(maxWidth: AppTheme.maxContentWidth(sizeClass))
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .onAppear { animate = true }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    func imageSlot(title: String, image: Binding<UIImage?>, key: String) -> some View {
        VStack(spacing: 8) {
            Text(title).font(.caption.bold()).foregroundColor(AppTheme.bodyText)
            
            PhotosPicker(selection: $pickerItem, matching: .images) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.3))
                        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(AppTheme.accent.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [5])))
                        .frame(height: 120)
                    
                    if let img = image.wrappedValue {
                        Image(uiImage: img)
                            .resizable().scaledToFill()
                            .frame(height: 120).clipped().cornerRadius(12)
                    } else {
                        VStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill").font(.title).foregroundColor(AppTheme.accent)
                            Text("Select").font(.caption2).foregroundColor(AppTheme.accent)
                        }
                    }
                }
            }.simultaneousGesture(TapGesture().onEnded {
                activePicker = key
            })
        }
    }
}
