import SwiftUI
import PhotosUI

struct UploadHairImageView: View {
    var user: User
    @Environment(\.dismiss) private var dismiss
    
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
    @State private var showSuccessAlert = false
    
    @Environment(\.horizontalSizeClass) var sizeClass
    
    var capturedCount: Int {
        var count = 0
        if frontalImage != nil { count += 1 }
        if leftImage != nil { count += 1 }
        if rightImage != nil { count += 1 }
        if vertexImage != nil { count += 1 }
        return count
    }
    
    var progressFraction: CGFloat {
        CGFloat(capturedCount) / 4.0
    }
    
    func uploadAlbum() {
        guard let frontal = frontalImage?.jpegData(compressionQuality: 0.8),
              let left = leftImage?.jpegData(compressionQuality: 0.8),
              let right = rightImage?.jpegData(compressionQuality: 0.8),
              let vertex = vertexImage?.jpegData(compressionQuality: 0.8),
              let url = URL(string: APIService.baseURL + "upload_hair_image.php") else {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            withAnimation {
                message = "⚠️ Please capture all 4 required perspectives before uploading."
            }
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
                self.isUploading = false
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                withAnimation {
                    self.showSuccessAlert = true
                    self.frontalImage = nil
                    self.leftImage = nil
                    self.rightImage = nil
                    self.vertexImage = nil
                }
            }
        }.resume()
    }
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 22) {
                    
                    // ── Hero Header ──
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [AppTheme.emeraldMint, AppTheme.primaryBrand], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 76, height: 76)
                                .shadow(color: AppTheme.emeraldMint.opacity(0.35), radius: 10, y: 5)
                            
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 34, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .scaleEffect(animate ? 1 : 0.7)
                        .animation(.spring(response: 0.6), value: animate)
                        
                        VStack(spacing: 4) {
                            HStack(spacing: 6) {
                                Text("CLINICAL PHOTOGRAPHY")
                                    .font(.system(size: 11, weight: .heavy))
                                    .tracking(1.2)
                                    .foregroundColor(AppTheme.emeraldMint)
                                Image(systemName: "sparkles")
                                    .font(.system(size: 11))
                                    .foregroundColor(AppTheme.emeraldMint)
                            }
                            
                            Text("Progress Photo Upload")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.titleText)
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)
                            
                            Text("Capture all 4 standard scalp perspectives to accurately track your hair transformation.")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.bodyText(0.75))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)
                        }
                    }
                    .padding(.top, 10)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : -20)
                    .animation(.easeOut(duration: 0.6), value: animate)
                    
                    // ── Completion Progress Indicator ──
                    GlassCard(cornerRadius: 18, paddingAmount: 14) {
                        VStack(spacing: 8) {
                            HStack {
                                HStack(spacing: 6) {
                                    Image(systemName: capturedCount == 4 ? "checkmark.circle.fill" : "camera.fill")
                                        .foregroundColor(capturedCount == 4 ? AppTheme.emeraldMint : AppTheme.primaryBrand)
                                        .font(.system(size: 13, weight: .bold))
                                    Text("\(capturedCount) of 4 Perspectives Added")
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundColor(AppTheme.titleText)
                                }
                                
                                Spacer()
                                
                                Text(capturedCount == 4 ? "READY TO UPLOAD" : "\(4 - capturedCount) NEEDED")
                                    .font(.system(size: 9, weight: .heavy))
                                    .foregroundColor(capturedCount == 4 ? AppTheme.emeraldMint : AppTheme.amberWarm)
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 3)
                                    .background((capturedCount == 4 ? AppTheme.emeraldMint : AppTheme.amberWarm).opacity(0.12))
                                    .clipShape(Capsule())
                            }
                            
                            // Visual Track
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.black.opacity(0.06))
                                        .frame(height: 6)
                                    
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [AppTheme.emeraldMint, AppTheme.primaryBrand],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geo.size.width * max(progressFraction, 0.05), height: 6)
                                        .animation(.spring(response: 0.4), value: progressFraction)
                                }
                            }
                            .frame(height: 6)
                        }
                    }
                    .opacity(animate ? 1 : 0)
                    .animation(.easeOut(duration: 0.6).delay(0.1), value: animate)
                    
                    // ── Settings Card: Phase & Capture Date ──
                    GlassCard(cornerRadius: 22, paddingAmount: 18) {
                        VStack(spacing: 16) {
                            
                            // Phase Selector
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("GROWTH STAGE")
                                        .font(.system(size: 11, weight: .heavy))
                                        .tracking(1.0)
                                        .foregroundColor(AppTheme.primaryBrand)
                                    Spacer()
                                    Text("Phase Tag")
                                        .font(.caption2)
                                        .foregroundColor(AppTheme.bodyText(0.6))
                                }
                                
                                HStack(spacing: 8) {
                                    phasePill(title: "Baseline", tag: "Baseline")
                                    phasePill(title: "3 Months", tag: "3 Months")
                                    phasePill(title: "6 Months", tag: "6 Months")
                                }
                            }
                            
                            Divider().opacity(0.4)
                            
                            // Date Picker Row
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("CAPTURE DATE")
                                        .font(.system(size: 11, weight: .heavy))
                                        .tracking(1.0)
                                        .foregroundColor(AppTheme.primaryBrand)
                                    Text("Date photos were taken")
                                        .font(.caption2)
                                        .foregroundColor(AppTheme.bodyText(0.6))
                                }
                                
                                Spacer()
                                
                                DatePicker("", selection: $captureDate, displayedComponents: .date)
                                    .labelsHidden()
                                    .tint(AppTheme.primaryBrand)
                            }
                        }
                    }
                    .opacity(animate ? 1 : 0)
                    .animation(.easeOut(duration: 0.6).delay(0.15), value: animate)
                    
                    // ── 4 Photo Angles Grid ──
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Standard Perspectives")
                                .font(.headline.weight(.bold))
                                .foregroundColor(AppTheme.titleText)
                            Spacer()
                            Text("All 4 Required")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(AppTheme.bodyText(0.7))
                        }
                        
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                            imageSlot(
                                title: "Frontal",
                                subtitle: "Hairline & forehead",
                                icon: "face.smiling",
                                image: $frontalImage,
                                key: "frontal"
                            )
                            imageSlot(
                                title: "Left Lateral",
                                subtitle: "Left temple & side",
                                icon: "arrow.left.circle.fill",
                                image: $leftImage,
                                key: "left"
                            )
                            imageSlot(
                                title: "Right Lateral",
                                subtitle: "Right temple & side",
                                icon: "arrow.right.circle.fill",
                                image: $rightImage,
                                key: "right"
                            )
                            imageSlot(
                                title: "Vertex (Crown)",
                                subtitle: "Top scalp & vertex",
                                icon: "crown.fill",
                                image: $vertexImage,
                                key: "vertex"
                            )
                        }
                    }
                    .opacity(animate ? 1 : 0)
                    .animation(.easeOut(duration: 0.6).delay(0.2), value: animate)
                    
                    // ── Error Message Banner ──
                    if !message.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption.bold())
                            Text(message)
                                .font(.caption.bold())
                        }
                        .foregroundColor(AppTheme.coralRose)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(AppTheme.coralRose.opacity(0.12))
                        .clipShape(Capsule())
                    }
                    
                    // ── Upload Button ──
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        uploadAlbum()
                    } label: {
                        HStack(spacing: 8) {
                            if isUploading {
                                ProgressView().tint(.white)
                                Text("Uploading Album...")
                                    .font(.headline.weight(.bold))
                            } else {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.headline)
                                Text("Upload Photo Album")
                                    .font(.headline.weight(.bold))
                            }
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(height: 52))
                    .disabled(isUploading)
                    .padding(.top, 4)
                    
                    // Photography Tips
                    HStack(spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.amberWarm)
                        Text("Tip: Maintain consistent lighting & head angles for best comparison.")
                            .font(.caption2)
                            .foregroundColor(AppTheme.bodyText(0.7))
                    }
                    .padding(.bottom, 10)
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 16)
                .frame(maxWidth: AppTheme.maxContentWidth(sizeClass))
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
        }
        .onAppear { animate = true }
        .navigationTitle("Upload Photos")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: pickerItem) {
            Task {
                guard let pItem = pickerItem,
                      let data = try? await pItem.loadTransferable(type: Data.self),
                      let uiImg = UIImage(data: data) else { return }
                
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    switch activePicker {
                    case "frontal": frontalImage = uiImg
                    case "left": leftImage = uiImg
                    case "right": rightImage = uiImg
                    case "vertex": vertexImage = uiImg
                    default: break
                    }
                }
                pickerItem = nil
            }
        }
        .alert("Album Uploaded", isPresented: $showSuccessAlert) {
            Button("Done") {
                dismiss()
            }
        } message: {
            Text("✅ Your \(progressTag) photo album with 4 perspectives has been logged successfully.")
        }
    }
    
    // MARK: - Phase Selector Pill
    @ViewBuilder
    private func phasePill(title: String, tag: String) -> some View {
        let isSelected = progressTag == tag
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                progressTag = tag
            }
        }) {
            Text(title)
                .font(.system(size: 13, weight: isSelected ? .bold : .semibold))
                .foregroundColor(isSelected ? .white : AppTheme.titleText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    isSelected
                        ? AnyView(AppTheme.brandGradient)
                        : AnyView(Color.white.opacity(0.6))
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color.white, lineWidth: 1)
                )
                .shadow(
                    color: isSelected ? AppTheme.primaryBrand.opacity(0.25) : Color.clear,
                    radius: 6,
                    y: 2
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Photo Angle Card Component
    @ViewBuilder
    private func imageSlot(
        title: String,
        subtitle: String,
        icon: String,
        image: Binding<UIImage?>,
        key: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.titleText)
                    .lineLimit(1)
                Spacer()
                if image.wrappedValue != nil {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.emeraldMint)
                }
            }
            
            PhotosPicker(selection: $pickerItem, matching: .images) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.65))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .strokeBorder(
                                    image.wrappedValue != nil
                                        ? AppTheme.emeraldMint
                                        : AppTheme.primaryBrand.opacity(0.35),
                                    style: StrokeStyle(
                                        lineWidth: image.wrappedValue != nil ? 2 : 1.2,
                                        dash: image.wrappedValue != nil ? [] : [6, 4]
                                    )
                                )
                        )
                        .frame(height: 140)
                    
                    if let img = image.wrappedValue {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 140)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay(
                                // Remove button on top-right
                                Button(action: {
                                    withAnimation {
                                        image.wrappedValue = nil
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color.black.opacity(0.65))
                                        .background(Color.white)
                                        .clipShape(Circle())
                                }
                                .padding(8),
                                alignment: .topTrailing
                            )
                            .overlay(
                                // Edit chip at bottom
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                        .font(.system(size: 9, weight: .bold))
                                    Text("Change")
                                        .font(.system(size: 10, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.black.opacity(0.65))
                                .clipShape(Capsule())
                                .padding(8),
                                alignment: .bottomLeading
                            )
                    } else {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.primaryBrand.opacity(0.12))
                                    .frame(width: 44, height: 44)
                                
                                Image(systemName: icon)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(AppTheme.primaryBrand)
                            }
                            
                            VStack(spacing: 2) {
                                Text("Add Photo")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(AppTheme.titleText)
                                
                                Text(subtitle)
                                    .font(.system(size: 9))
                                    .foregroundColor(AppTheme.bodyText(0.7))
                                    .lineLimit(1)
                            }
                        }
                    }
                }
            }
            .simultaneousGesture(TapGesture().onEnded {
                activePicker = key
            })
        }
    }
}
