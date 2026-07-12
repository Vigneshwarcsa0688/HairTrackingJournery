import SwiftUI

struct HairAnalysisReportView: View {
    var score: Int
    var onFinish: () -> Void   // ✅ ADDED
    
    @Environment(\.dismiss) var dismiss
    @State private var animate = false
    
    var risk: String {
        if score < 15 { return "Low Risk" }
        if score < 30 { return "Moderate Risk" }
        return "High Risk"
    }
    
    var riskColor: Color {
        switch risk {
        case "Low Risk": return .green
        case "Moderate Risk": return .orange
        default: return .red
        }
    }
    
    var body: some View {
        ZStack {
            AppTheme.gradient.ignoresSafeArea()
            
            VStack(spacing: 28) {
                
                Spacer()
                
                VStack(spacing: 12) {
                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 70))
                        .foregroundColor(AppTheme.titleText)
                        .scaleEffect(animate ? 1 : 0.6)
                        .animation(.easeOut(duration: 0.6), value: animate)
                    
                    Text("Hair Health Report")
                        .font(.title.bold())
                        .foregroundColor(AppTheme.titleText)
                }
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : -20)
                .animation(.easeOut(duration: 0.6), value: animate)
                
                GlassCard {
                    VStack(spacing: 16) {
                        Text("Your Risk Level")
                            .font(.caption)
                            .foregroundColor(AppTheme.bodyText)
                        
                        Text(risk)
                            .font(.title.bold())
                            .foregroundColor(riskColor)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(riskColor.opacity(0.15))
                            .cornerRadius(12)
                        
                        Text("This is an AI-based self-assessment. For professional diagnosis, consult a specialist through the app.")
                            .font(.footnote)
                            .foregroundColor(AppTheme.bodyText)
                            .multilineTextAlignment(.center)
                    }
                }
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : 25)
                .animation(.easeOut(duration: 0.7), value: animate)
                
                Button {
                    dismiss()
                    onFinish()   // ✅ GO TO DASHBOARD
                } label: {
                    Text("Back to Dashboard")
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            animate = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                dismiss()
                onFinish()   // ✅ AUTO GO TO DASHBOARD
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
