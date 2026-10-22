import SwiftUI

// MARK: - Chat Message Model
struct HairChatMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp: Date = Date()
}

// MARK: - Dedicated Hair Journey AI Knowledge & Guardrail Engine
struct HairAIEngine {
    
    // Quick starter prompt suggestions
    static let starterPrompts: [String] = [
        "How often should I apply hair serum? 🧴",
        "Why is my hair shedding during the first 3 weeks? 🧬",
        "How do I take good progress photos? 📸",
        "What scalp foods encourage thicker hair? 🥑",
        "How do I book a consultation with a specialist? 📅",
        "What does my quiz assessment score mean? 📊",
        "Should I massage my scalp daily? 💆‍♂️",
        "Is dandruff causing my hair loss? ❄️"
    ]
    
    static func getRandomPrompts(count: Int = 4) -> [String] {
        Array(starterPrompts.shuffled().prefix(count))
    }
    
    // Rule-based hair wellness responses
    static func generateResponse(to input: String) -> String {
        let q = input.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Non-hair, irrelevant, or harmful off-topic guardrail
        if isGeneralNonHairQuery(q) {
            return """
            🌿 **Hair Journey Assistant:**
            
            I specialize exclusively in **hair wellness, scalp health, serum routines, photo comparison, and hair care habits**.
            
            Please ask me anything related to:
            • Daily serum & routine schedules 🧴
            • Shedding phases & regrowth expectations 🌱
            • Milestone photo tracking tips 📸
            • Scalp care, hygiene, and nutrition 🥗
            • Navigating your quiz reports and specialist bookings 📑
            """
        }
        
        // 1. Serum & Minoxidil Questions
        if q.contains("serum") || q.contains("minoxidil") || q.contains("apply") || q.contains("frequency") || q.contains("how often") || q.contains("routine") {
            return """
            🧴 **Serum Application & Daily Routine:**
            
            • **Consistency is Key:** Hair serums work best when applied consistently once or twice daily according to your routine plan.
            • **Dry Scalp Application:** Apply directly onto a clean, completely dry scalp rather than damp hair to maximize absorption.
            • **Gentle Massage:** Use your fingertips (not nails) to massage the serum for 1-2 minutes.
            • **Leave-In Time:** Allow at least 4 hours before washing or rinsing.
            
            💡 *Tip: Log your daily doses in the **Serum Calendar** to maintain your streak!*
            """
        }
        
        // 2. Shedding & Dread Shed
        if q.contains("shed") || q.contains("falling") || q.contains("fall") || q.contains("loss") || q.contains("thinning") || q.contains("worse") {
            return """
            🧬 **Understanding Temporary Shedding:**
            
            • **The Telogen Transition:** When starting a new hair stimulation routine, existing weaker hairs in the resting phase (telogen) often shed to make way for new, thicker anagen hair fibers.
            • **Timeline:** This temporary shedding peak typically occurs between **weeks 2 to 6** of routine care.
            • **Do Not Panic:** Stopping treatment during this transition interrupts the growth cycle.
            
            ✨ *If shedding persists past 8-10 weeks or is accompanied by burning or itching, consider booking a review with a hair care specialist.*
            """
        }
        
        // 3. Photo Progress & Angles
        if q.contains("photo") || q.contains("picture") || q.contains("camera") || q.contains("compare") || q.contains("angle") || q.contains("track") {
            return """
            📸 **Milestone Photo Tracking Best Practices:**
            
            For accurate before-and-after comparisons:
            • **Consistent Angles:** Take standardized photos from 3 angles: **Frontal hairline**, **Crown/Vertex**, and **Lateral sides**.
            • **Same Lighting:** Natural indirect daylight or consistent bathroom lighting prevents false shadows.
            • **Dry, Styled Hair:** Always photograph dry hair styled identically (e.g. parted down the middle).
            • **Interval:** Monthly photo milestones (every 30 days) provide the clearest view of density changes.
            
            ✨ *Check out the **Hair Progress Tracker** to compare side-by-side growth photos!*
            """
        }
        
        // 4. Scalp Massage & Blood Flow
        if q.contains("massage") || q.contains("circulation") || q.contains("blood") || q.contains("stimulation") || q.contains("dermaroller") {
            return """
            💆‍♂️ **Scalp Massage & Follicular Stimulation:**
            
            • Daily **4-minute fingertip scalp massages** encourage subcutaneous blood microcirculation, delivering essential oxygen and micronutrients directly to dermal papilla cells.
            • Use slow, circular kneading motions with moderate pressure.
            • If using a dermaroller (0.5mm), sanitize thoroughly with 70% alcohol before and after each session, and wait at least 12-24 hours before applying topical serums.
            """
        }
        
        // 5. Dandruff, Flakes & Itchiness
        if q.contains("dandruff") || q.contains("flake") || q.contains("itch") || q.contains("dry scalp") || q.contains("sebum") || q.contains("oil") {
            return """
            ❄️ **Scalp Health & Flaking Guidance:**
            
            • Differentiate between **dry scalp** (small white flakes caused by cold weather or harsh products) and **seborrheic dermatitis/dandruff** (yellowish oily flakes associated with Malassezia yeast).
            • Consider rotating an anti-fungal care wash (like 1-2% Ketoconazole or Zinc Pyrithione) 2-3 times per week.
            • Avoid hot water rinses which strip natural sebum and trigger rebound oil production.
            """
        }
        
        // 6. Diet, Nutrition & Vitamins
        if q.contains("food") || q.contains("diet") || q.contains("vitamin") || q.contains("biotin") || q.contains("iron") || q.contains("protein") || q.contains("zinc") {
            return """
            🥑 **Nutrition for Follicle Strength:**
            
            Hair is composed of 85-90% keratin protein. Key nutrients include:
            • **Protein & Amino Acids:** Eggs, fish, Greek yogurt, lentils, tofu.
            • **Ferritin & Iron:** Spinach, legumes, pumpkin seeds (low iron is a common trigger for telogen effluvium).
            • **Zinc & Omega-3:** Walnuts, chia seeds, salmon to regulate sebum and follicle cell turnover.
            • **Biotin & Vitamin D3:** Essential co-factors for structural hair synthesis.
            """
        }
        
        // 7. Quiz & Diagnostic Reports
        if q.contains("quiz") || q.contains("diagnostic") || q.contains("assessment") || q.contains("report") {
            return """
            📊 **Hair Health Assessment:**
            
            • Our **13-Question Hair Quiz** analyzes scalp characteristics, genetics, shedding patterns, and lifestyle habits.
            • Once completed, you receive a detailed score breakdown, tailored routine suggestions, and report sharing options.
            
            ✨ *Tap **Hair Growth Quiz** on your dashboard to evaluate your scalp health!*
            """
        }
        
        // 8. Specialist Consultation
        if q.contains("doctor") || q.contains("specialist") || q.contains("consult") || q.contains("appointment") || q.contains("booking") {
            return """
            ✨ **Hair Care Specialist Consultations:**
            
            • Connect 1-on-1 with certified hair care specialists and trichology advisors. 🌿
            • You can book consultation slots directly via the **Book Consultation** section. 📅
            • Track past advice and active care regimens in **My Consultations**. 💬
            
            *Note: HairJourney is an academic thesis project for educational wellness tracking and does not provide clinical medical diagnosis.*
            """
        }
        
        // 9. Greetings
        if q.contains("hi") || q.contains("hello") || q.contains("hey") || q.contains("morning") || q.contains("evening") {
            return """
            👋 Hello! I am your **Hair Journey AI Assistant** 🌿✨
            
            I'm here to support your daily scalp care, track your hair regrowth photos, answer routine queries, and keep your streak strong! 🧴💆‍♂️
            
            What would you like guidance on today? 💬
            """
        }
        
        // Default smart fallback
        return """
        🌿 **Hair Journey Specialist Insight:**
        
        Thank you for asking about **"\(input)"**!
        
        To achieve optimal results on your hair journey:
        • Maintain strict daily serum consistency 🧴
        • Capture standardized photos every 30 days 📸
        • Stimulate scalp circulation with daily fingertip massages 💆‍♂️
        • Consult our verified hair care specialists if you experience irregular shedding ✨
        
        *Feel free to ask more specific questions about serums, shedding phases, photo angles, or diet!*
        """
    }
    
    private static func isGeneralNonHairQuery(_ q: String) -> Bool {
        let unrelated = [
            "weather", "crypto", "bitcoin", "stock", "coding", "python", "swift",
            "car", "flight", "hotel", "movie", "politics", "president", "football",
            "cricket", "basketball", "recipe for cake", "translate"
        ]
        return unrelated.contains { q.contains($0) }
    }
}

// MARK: - Modern Animated AI Chatbot View (Text-Based Pure Chat)
struct HairAIChatView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) var sizeClass
    @ObservedObject private var langManager = AppLanguageManager.shared
    
    @State private var messages: [HairChatMessage] = [
        HairChatMessage(
            text: "👋 Hello! I am your dedicated **Hair Journey AI Assistant** 🌿✨\n\nI can help you with your serum routines, photo progress tracking, scalp health tips, and hair care questions! How can I assist your hair journey today? 🧴💆‍♂️",
            isUser: false
        )
    ]
    
    @State private var inputText: String = ""
    @State private var isBotTyping: Bool = false
    @State private var quickPrompts: [String] = HairAIEngine.getRandomPrompts(count: 4)
    @State private var pulseOrb: Bool = false
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            
            VStack(spacing: 0) {
                
                // MARK: - Chat Header
                HStack(spacing: 12) {
                    ZStack(alignment: .bottomTrailing) {
                        Circle()
                            .fill(AppTheme.brandGradient)
                            .frame(width: 44, height: 44)
                            .shadow(color: AppTheme.primaryBrand.opacity(0.35), radius: 6, y: 3)
                            .scaleEffect(pulseOrb ? 1.05 : 0.95)
                        
                        Image(systemName: "sparkles")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                        
                        // Active pulsing status dot
                        Circle()
                            .fill(AppTheme.emeraldMint)
                            .frame(width: 12, height: 12)
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text("Hair Journey AI")
                                .font(.headline.weight(.bold))
                                .foregroundColor(AppTheme.titleText)
                            
                            HStack(spacing: 3) {
                                Image(systemName: "bubble.left.and.bubble.right.fill")
                                    .font(.system(size: 8, weight: .bold))
                                Text("CHAT")
                                    .font(.system(size: 8, weight: .heavy))
                            }
                            .tracking(0.5)
                            .foregroundColor(AppTheme.primaryBrand)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2.5)
                            .background(AppTheme.primaryBrand.opacity(0.12))
                            .clipShape(Capsule())
                        }
                        
                        Text("Scalp & Hair Care Assistant • 24/7 Online")
                            .font(.caption2)
                            .foregroundColor(AppTheme.bodyText(0.7))
                    }
                    
                    Spacer()
                    
                    // Close Sheet Button
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(AppTheme.bodyText(0.4))
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                .background(Color.white.opacity(0.85))
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.black.opacity(0.05)),
                    alignment: .bottom
                )
                
                // Academic Thesis Project Notice
                HStack(spacing: 6) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.primaryBrand)
                    Text("Educational thesis assistant • For wellness habit tracking, not medical diagnosis")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(AppTheme.bodyText(0.75))
                        .lineLimit(1)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity)
                .background(AppTheme.primaryBrand.opacity(0.06))
                
                // MARK: - Chat Messages Area
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            
                            // Starter Quick Questions Chips (Show when <= 2 messages)
                            if messages.count <= 2 {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("SUGGESTED HAIR QUESTIONS")
                                            .font(.system(size: 10, weight: .heavy))
                                            .tracking(1.0)
                                            .foregroundColor(AppTheme.primaryBrand)
                                        
                                        Spacer()
                                        
                                        Button {
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                                quickPrompts = HairAIEngine.getRandomPrompts(count: 4)
                                            }
                                        } label: {
                                            HStack(spacing: 4) {
                                                Image(systemName: "arrow.triangle.2.circlepath")
                                                    .font(.system(size: 10))
                                                Text("Refresh")
                                                    .font(.system(size: 10, weight: .semibold))
                                            }
                                            .foregroundColor(AppTheme.primaryBrand)
                                        }
                                    }
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            ForEach(quickPrompts, id: \.self) { prompt in
                                                Button {
                                                    sendQuery(prompt)
                                                } label: {
                                                    HStack(spacing: 6) {
                                                        Text(prompt)
                                                            .font(.caption.weight(.medium))
                                                            .foregroundColor(AppTheme.titleText)
                                                    }
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 7)
                                                    .background(Color.white.opacity(0.85))
                                                    .clipShape(Capsule())
                                                    .overlay(
                                                        Capsule().stroke(AppTheme.primaryBrand.opacity(0.2), lineWidth: 1)
                                                    )
                                                    .shadow(color: Color.black.opacity(0.03), radius: 3, y: 1)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 10)
                                .transition(.opacity)
                            }
                            
                            // Messages List
                            ForEach(messages) { msg in
                                ChatBubbleView(message: msg)
                                    .id(msg.id)
                            }
                            
                            // Bot Typing Animation Bubble
                            if isBotTyping {
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(AppTheme.brandGradient)
                                        .frame(width: 28, height: 28)
                                        .overlay(Image(systemName: "sparkles").font(.system(size: 12)).foregroundColor(.white))
                                    
                                    TypingIndicatorView()
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 10)
                                        .background(Color.white.opacity(0.85))
                                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .id("TYPING_INDICATOR")
                            }
                            
                            Spacer(minLength: 20)
                        }
                        .padding(.top, 14)
                    }
                    .onChange(of: messages) { _ in
                        withAnimation(.easeOut(duration: 0.3)) {
                            if let lastId = messages.last?.id {
                                proxy.scrollTo(lastId, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: isBotTyping) { typing in
                        if typing {
                            withAnimation(.easeOut(duration: 0.3)) {
                                proxy.scrollTo("TYPING_INDICATOR", anchor: .bottom)
                            }
                        }
                    }
                }
                
                // MARK: - Input Field & Send Action
                VStack(spacing: 0) {
                    Divider().opacity(0.4)
                    
                    HStack(spacing: 10) {
                        
                        // Text Input Field
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.primaryBrand.opacity(0.7))
                            
                            TextField("Ask about hair growth, serum, photos...", text: $inputText)
                                .font(.subheadline)
                                .foregroundColor(AppTheme.titleText)
                                .autocorrectionDisabled(false)
                            
                            if !inputText.isEmpty {
                                Button {
                                    inputText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(AppTheme.bodyText(0.4))
                                }
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 11)
                        .background(Color.white.opacity(0.85))
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.black.opacity(0.06), lineWidth: 1)
                        )
                        
                        // Send Button
                        Button {
                            guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                            sendQuery(inputText)
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray.opacity(0.3) : AppTheme.primaryBrand)
                                    .frame(width: 44, height: 44)
                                    .shadow(color: AppTheme.primaryBrand.opacity(inputText.isEmpty ? 0 : 0.35), radius: 6, y: 3)
                                
                                Image(systemName: "arrow.up")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isBotTyping)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.85))
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulseOrb = true
            }
        }
    }
    
    // MARK: - Send Message Handler
    private func sendQuery(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        // Add User Message
        let userMsg = HairChatMessage(text: trimmed, isUser: true)
        messages.append(userMsg)
        inputText = ""
        isBotTyping = true
        
        // Simulated natural AI typing response
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            let aiText = HairAIEngine.generateResponse(to: trimmed)
            isBotTyping = false
            let botMsg = HairChatMessage(text: aiText, isUser: false)
            messages.append(botMsg)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
}

// MARK: - Individual Chat Bubble View
struct ChatBubbleView: View {
    let message: HairChatMessage
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isUser {
                Spacer(minLength: 40)
            } else {
                // Bot Icon
                Circle()
                    .fill(AppTheme.brandGradient)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: "sparkles")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    )
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(LocalizedStringKey(message.text))
                    .font(.subheadline)
                    .foregroundColor(message.isUser ? .white : AppTheme.titleText)
                    .lineSpacing(3)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .background(
                        message.isUser
                            ? AnyView(AppTheme.brandGradient)
                            : AnyView(Color.white.opacity(0.88))
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 18,
                            style: .continuous
                        )
                    )
                    .shadow(color: Color.black.opacity(message.isUser ? 0.08 : 0.04), radius: 6, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(message.isUser ? Color.clear : Color.white, lineWidth: 1)
                    )
            }
            
            if !message.isUser {
                Spacer(minLength: 40)
            }
        }
        .padding(.horizontal, 16)
        .transition(.asymmetric(insertion: .scale(scale: 0.95).combined(with: .opacity), removal: .opacity))
    }
}

// MARK: - Typing Indicator Animation View
struct TypingIndicatorView: View {
    @State private var phase: Int = 0
    
    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(AppTheme.primaryBrand)
                    .frame(width: 7, height: 7)
                    .scaleEffect(phase == index ? 1.3 : 0.8)
                    .opacity(phase == index ? 1.0 : 0.35)
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.28, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.25)) {
                    phase = (phase + 1) % 3
                }
            }
        }
    }
}

// MARK: - Floating AI Chat Button
struct HairAIOrbPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.90 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct HairAIFloatingButton: View {
    var action: () -> Void
    
    @State private var rotateOrbit = false
    @State private var pulseAura = false
    
    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            action()
        }) {
            ZStack {
                // 1. Ambient Dynamic Neon Radial Glow
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.0, green: 0.85, blue: 0.95).opacity(0.55),
                                Color(red: 0.45, green: 0.25, blue: 0.95).opacity(0.35),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 10,
                            endRadius: 52
                        )
                    )
                    .frame(width: 92, height: 92)
                    .scaleEffect(pulseAura ? 1.22 : 0.96)
                    .blur(radius: pulseAura ? 14 : 8)

                // 2. Main Outer Glass Disk
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.05, green: 0.50, blue: 0.98),
                                Color(red: 0.52, green: 0.24, blue: 0.96)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 66, height: 66)
                    .shadow(color: Color(red: 0.1, green: 0.4, blue: 0.95).opacity(0.50), radius: 14, x: 0, y: 7)
                    .shadow(color: Color(red: 0.5, green: 0.2, blue: 0.95).opacity(0.35), radius: 24, x: 0, y: 12)

                // 3. Central Icon & Label
                VStack(spacing: 2) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: Color.white.opacity(0.7), radius: 4)
                    
                    Text("HAIR AI")
                        .font(.system(size: 8, weight: .black, design: .rounded))
                        .tracking(0.6)
                        .foregroundColor(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1.5)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.3))
                                .overlay(
                                    Capsule()
                                        .stroke(Color(red: 0.45, green: 0.98, blue: 0.85).opacity(0.85), lineWidth: 0.8)
                                )
                        )
                }

                // 4. Live Pulsing Green Beacon
                ZStack {
                    Circle()
                        .fill(Color(red: 0.1, green: 0.95, blue: 0.55))
                        .frame(width: 14, height: 14)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2.5))
                        .shadow(color: Color(red: 0.1, green: 0.95, blue: 0.55), radius: 5)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 4, height: 4)
                }
                .offset(x: 23, y: -23)
            }
        }
        .buttonStyle(HairAIOrbPressStyle())
        .onAppear {
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                pulseAura = true
            }
        }
    }
}
