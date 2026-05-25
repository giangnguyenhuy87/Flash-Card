import SwiftUI

struct OnboardingView: View {
    @Binding var isOnboardingComplete: Bool
    @State private var currentPage = 0
    @State private var offset: CGFloat = 0
    @EnvironmentObject var settings: AppSettings
    
    var pages: [OnboardingPage] {
        [
            OnboardingPage(
                image: "brain.head.profile",
                title: Localization.string("onboarding_title_1", lang: settings.appLanguage),
                description: Localization.string("onboarding_desc_1", lang: settings.appLanguage),
                gradient: [Color(hex: "8B5CF6"), Color(hex: "6D28D9")]
            ),
            OnboardingPage(
                image: "flame.fill",
                title: Localization.string("onboarding_title_2", lang: settings.appLanguage),
                description: Localization.string("onboarding_desc_2", lang: settings.appLanguage),
                gradient: [Color(hex: "F59E0B"), Color(hex: "EF4444")]
            ),
            OnboardingPage(
                image: "chart.line.uptrend.xyaxis",
                title: Localization.string("onboarding_title_3", lang: settings.appLanguage),
                description: Localization.string("onboarding_desc_3", lang: settings.appLanguage),
                gradient: [Color(hex: "14B8A6"), Color(hex: "06B6D4")]
            )
        ]
    }
    
    var body: some View {
        ZStack {
            // Dynamic Background
            AnimatedBackground(currentPage: currentPage)
            
            VStack(spacing: 0) {
                Spacer()
                
                // Page Content with Parallax
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index], isActive: currentPage == index)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: 500)
                
                Spacer()
                
                // Page Indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(currentPage == index ? Color.white : Color.white.opacity(0.3))
                            .frame(width: currentPage == index ? 32 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 30)
                
                // Action Button
                Button(action: {
                    AppTheme.haptic(.medium)
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        if currentPage < pages.count - 1 {
                            currentPage += 1
                        } else {
                            isOnboardingComplete = true
                        }
                    }
                }) {
                    HStack {
                        Text(currentPage == pages.count - 1 ? Localization.string("onboarding_start", lang: settings.appLanguage) : Localization.string("onboarding_next", lang: settings.appLanguage))
                            .font(AppTheme.font(.headline, weight: .bold))
                        
                        if currentPage == pages.count - 1 {
                            Image(systemName: "arrow.right")
                                .font(.headline.bold())
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: pages[currentPage].gradient,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: pages[currentPage].gradient[0].opacity(0.5), radius: 20, x: 0, y: 10)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Subviews

struct OnboardingPageView: View {
    let page: OnboardingPage
    let isActive: Bool
    
    var body: some View {
        VStack(spacing: 40) {
            // Icon with Glow Effect
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: page.gradient.map { $0.opacity(0.3) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 160, height: 160)
                    .blur(radius: 30)
                
                Image(systemName: page.image)
                    .font(.system(size: 60, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: page.gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolEffect(.bounce, value: isActive)
            }
            .scaleEffect(isActive ? 1.0 : 0.8)
            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isActive)
            
            // Text Content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(AppTheme.font(.largeTitle, weight: .black))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(AppTheme.font(.body, weight: .medium))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)
            }
            .opacity(isActive ? 1.0 : 0.5)
            .offset(y: isActive ? 0 : 20)
            .animation(.easeOut(duration: 0.4), value: isActive)
        }
    }
}

struct AnimatedBackground: View {
    let currentPage: Int
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()
            
            // Animated Blobs
            Circle()
                .fill(Color(hex: "8B5CF6").opacity(0.15))
                .frame(width: 350, height: 350)
                .blur(radius: 80)
                .offset(x: currentPage == 0 ? -120 : -80, y: currentPage == 1 ? -250 : -200)
                .animation(.easeInOut(duration: 1.5), value: currentPage)
            
            Circle()
                .fill(Color(hex: "EC4899").opacity(0.15))
                .frame(width: 300, height: 300)
                .blur(radius: 70)
                .offset(x: currentPage == 2 ? 100 : 130, y: currentPage == 0 ? 200 : 150)
                .animation(.easeInOut(duration: 1.5), value: currentPage)
            
            Circle()
                .fill(Color(hex: "14B8A6").opacity(0.1))
                .frame(width: 250, height: 250)
                .blur(radius: 60)
                .offset(x: currentPage == 1 ? -100 : 0, y: currentPage == 2 ? 300 : 250)
                .animation(.easeInOut(duration: 1.5), value: currentPage)
        }
    }
}

struct OnboardingPage {
    let image: String
    let title: String
    let description: String
    let gradient: [Color]
}
