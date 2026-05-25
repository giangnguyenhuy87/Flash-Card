import SwiftUI

struct AppInfoDetailView: View {
    let title: String
    let content: String
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    Text(title)
                        .font(AppTheme.font(.title2, weight: .black))
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                    
                    Text(content)
                        .font(AppTheme.font(.body))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(24)
                .padding(.bottom, 150)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}



#Preview {
    NavigationStack {
        AppInfoDetailView(title: "Privacy Policy", content: "LuminaCards is committed to protecting your privacy...")
    }
}
