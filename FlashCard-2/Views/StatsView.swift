import SwiftUI
import SwiftData

struct StatsView: View {
    @Query private var decks: [Deck]
    @EnvironmentObject var settings: AppSettings
    @State private var animateChart = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        // Header Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text(Localization.string("stats_title", lang: settings.appLanguage))
                                .font(AppTheme.font(.title, weight: .black))
                                .foregroundStyle(AppTheme.Colors.textPrimary)
                            Text(Localization.string("stats_subtitle", lang: settings.appLanguage))
                                .font(AppTheme.font(.subheadline))
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        
                        // Main Stats Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            statCard(title: Localization.string("lib_tab_decks", lang: settings.appLanguage), value: "\(decks.count)", icon: "book.closed.fill", color: AppTheme.Colors.primaryGradient)
                            statCard(title: Localization.string("stats_total_time", lang: settings.appLanguage), value: "12.5", unit: Localization.string("stats_total_time_unit", lang: settings.appLanguage), icon: "timer", color: .orange.gradient)
                            statCard(title: Localization.string("home_mastered", lang: settings.appLanguage), value: "482", icon: "checkmark.seal.fill", color: .green.gradient)
                            statCard(title: Localization.string("stats_accuracy", lang: settings.appLanguage), value: "88", unit: "%", icon: "target", color: .blue.gradient)
                        }
                        .padding(.horizontal, 24)
                        
                        // Mastery Circular Progress
                        masterySection
                            .padding(.horizontal, 24)
                        
                        // Weekly Activity Chart
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Text(Localization.string("stats_activity_7days", lang: settings.appLanguage))
                                    .font(AppTheme.font(.headline, weight: .bold))
                                    .foregroundStyle(AppTheme.Colors.textPrimary)
                                Spacer()
                                Text("\(Localization.string("stats_activity_total", lang: settings.appLanguage)): 4.2h")
                                    .font(AppTheme.font(.caption, weight: .bold))
                                    .foregroundStyle(AppTheme.Colors.primary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(AppTheme.Colors.primary.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                            
                            activityChart
                        }
                        .padding(.horizontal, 24)
                        
                        // Performance Breakdown
                        VStack(alignment: .leading, spacing: 16) {
                            Text(Localization.string("stats_top_decks", lang: settings.appLanguage))
                                .font(AppTheme.font(.headline, weight: .bold))
                                .foregroundStyle(AppTheme.Colors.textPrimary)
                            
                            VStack(spacing: 12) {
                                ForEach(decks.prefix(3)) { deck in
                                    PerformanceRow(deck: deck)
                                }
                                
                                if decks.isEmpty {
                                    Text(Localization.string("stats_empty_msg", lang: settings.appLanguage))
                                        .font(AppTheme.font(.caption))
                                        .foregroundStyle(AppTheme.Colors.textSecondary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 20)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 150)
                    }
                    .padding(.top, 20)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                animateChart = true
            }
        }
    }
    
    private func statCard(title: String, value: String, unit: String? = nil, icon: String, color: some ShapeStyle) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.system(size: 18, weight: .bold))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(value)
                        .font(AppTheme.font(.title, weight: .black))
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                    if let unit = unit {
                        Text(unit)
                            .font(AppTheme.font(.caption, weight: .bold))
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }
                }
                Text(title)
                    .font(AppTheme.font(.caption2, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .textCase(.uppercase)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(AppTheme.Colors.surfaceHighlight, lineWidth: 1)
        )
    }
    
    private var masterySection: some View {
        HStack(spacing: 24) {
            ZStack {
                Circle()
                    .stroke(AppTheme.Colors.surfaceHighlight, lineWidth: 12)
                Circle()
                    .trim(from: 0, to: animateChart ? 0.65 : 0)
                    .stroke(
                        AppTheme.Colors.primaryGradient,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 0) {
                    Text("65%")
                        .font(AppTheme.font(.title, weight: .black))
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                    Text(Localization.string("home_mastered", lang: settings.appLanguage))
                        .font(AppTheme.font(.caption2, weight: .bold))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }
            .frame(width: 120, height: 120)
            
            VStack(alignment: .leading, spacing: 12) {
                Text(Localization.string("stats_mastery_level", lang: settings.appLanguage))
                    .font(AppTheme.font(.headline, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Text(Localization.string("stats_mastery_desc", lang: settings.appLanguage))
                    .font(AppTheme.font(.caption))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .lineSpacing(4)
                
                HStack(spacing: 12) {
                    Label(Localization.string("stats_mastery_tier", lang: settings.appLanguage), systemImage: "trophy.fill")
                        .font(AppTheme.font(.caption, weight: .bold))
                        .foregroundStyle(AppTheme.Colors.accentYellow)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AppTheme.Colors.accentYellow.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(24)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(AppTheme.Colors.surfaceHighlight, lineWidth: 1)
        )
    }
    
    private var activityChart: some View {
        HStack(alignment: .bottom, spacing: 12) {
            let data: [CGFloat] = [0.4, 0.7, 0.9, 0.5, 1.0, 0.6, 0.8]
            let days = [
                Localization.string("stats_day_mon", lang: settings.appLanguage),
                Localization.string("stats_day_tue", lang: settings.appLanguage),
                Localization.string("stats_day_wed", lang: settings.appLanguage),
                Localization.string("stats_day_thu", lang: settings.appLanguage),
                Localization.string("stats_day_fri", lang: settings.appLanguage),
                Localization.string("stats_day_sat", lang: settings.appLanguage),
                Localization.string("stats_day_sun", lang: settings.appLanguage)
            ]
            
            ForEach(0..<7) { index in
                VStack(spacing: 12) {
                    Spacer()
                    
                    ZStack(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(AppTheme.Colors.surfaceHighlight.opacity(0.3))
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(index == 4 ? AppTheme.Colors.primaryGradient : LinearGradient(colors: [AppTheme.Colors.textSecondary.opacity(0.2)], startPoint: .top, endPoint: .bottom))
                            .frame(height: animateChart ? (data[index] * 160) : 0)
                    }
                    .frame(height: 160)
                    
                    Text(days[index])
                        .font(AppTheme.font(.caption2, weight: .bold))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(24)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(AppTheme.Colors.surfaceHighlight, lineWidth: 1)
        )
    }
}

struct PerformanceRow: View {
    let deck: Deck
    
    var body: some View {
        HStack(spacing: 16) {
            Text(deck.emoji)
                .font(.title3)
                .frame(width: 48, height: 48)
                .background(Color(hex: deck.colorHex).opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(deck.title)
                    .font(AppTheme.font(.body, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                
                ProgressView(value: 0.85)
                    .tint(Color(hex: deck.colorHex))
                    .background(Color(hex: deck.colorHex).opacity(0.1))
                    .clipShape(Capsule())
                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
            }
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("85%")
                    .font(AppTheme.font(.subheadline, weight: .black))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Text(Localization.string("home_mastered", lang: AppSettings.shared.appLanguage))
                    .font(AppTheme.font(.caption2))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
        .padding(16)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    StatsView()
        .environmentObject(AppSettings.shared)
}
