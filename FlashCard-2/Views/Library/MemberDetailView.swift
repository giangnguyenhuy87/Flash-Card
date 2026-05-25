import SwiftUI
import SwiftData

struct MemberDetailView: View {
    let student: Student
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var settings: AppSettings
    @Query private var allDecks: [Deck] // In a real app, we'd filter by student ID
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Profile Header
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.Colors.primary.opacity(0.1))
                                .frame(width: 100, height: 100)
                            Text(student.name.prefix(1).uppercased())
                                .font(.system(size: 40, weight: .black, design: .rounded))
                                .foregroundStyle(AppTheme.Colors.primary)
                        }
                        
                        VStack(spacing: 4) {
                            Text(student.name)
                                .font(AppTheme.font(.title3, weight: .black))
                                .foregroundStyle(AppTheme.Colors.textPrimary)
                            let joinedDate = student.joinedAt.formatted(date: .long, time: .omitted)
                            Text(String(format: Localization.string("member_joined_since", lang: settings.appLanguage), joinedDate))
                                .font(AppTheme.font(.caption))
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Contributions Section
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text(Localization.string("member_shared_decks", lang: settings.appLanguage))
                                .font(AppTheme.font(.headline, weight: .bold))
                                .foregroundStyle(AppTheme.Colors.textPrimary)
                            Spacer()
                            // Mocking count for demo
                            Text("3")
                                .font(AppTheme.font(.caption, weight: .bold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(AppTheme.Colors.primary.opacity(0.1))
                                .foregroundStyle(AppTheme.Colors.primary)
                                .clipShape(Capsule())
                        }
                        
                        // Show some decks as demonstration of "posted by member"
                        VStack(spacing: 16) {
                            ForEach(allDecks.prefix(3)) { deck in
                                NavigationLink(destination: DeckDetailView(deck: deck)) {
                                    EnhancedDeckCard(deck: deck)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 100)
            }
        }
        .navigationTitle(student.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MemberDetailView(student: Student(name: "Giang Nguyen"))
}
