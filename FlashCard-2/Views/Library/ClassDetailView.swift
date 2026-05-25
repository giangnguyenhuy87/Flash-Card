import SwiftUI
import SwiftData

struct ClassDetailView: View {
    let classRoom: ClassRoom
    @EnvironmentObject var settings: AppSettings
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var navManager: NavigationManager
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Header Card
                    headerSection
                        .padding(.horizontal, 24)
                    
                    // Assigned Decks Section
                    decksSection
                        .padding(.horizontal, 24)
                    
                    // Members Section
                    membersSection
                        .padding(.horizontal, 24)
                }
                .padding(.top, 20)
                .padding(.bottom, 100)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(Localization.string("class_detail_title", lang: settings.appLanguage))
                    .font(AppTheme.font(.headline, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
            }
        }
        .onAppear {
            withAnimation(.spring()) {
                navManager.isTabBarHidden = true
            }
        }
        .onDisappear {
            withAnimation(.spring()) {
                navManager.isTabBarHidden = false
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.primary.opacity(0.1))
                    .frame(width: 80, height: 80)
                Text(classRoom.name.prefix(1).uppercased())
                    .font(AppTheme.font(.largeTitle, weight: .black))
                    .foregroundStyle(AppTheme.Colors.primary)
            }
            
            VStack(spacing: 8) {
                Text(classRoom.name)
                    .font(AppTheme.font(.title2, weight: .black))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                
                HStack(spacing: 12) {
                    Label(classRoom.teacherName, systemImage: "person.fill")
                    Text("•")
                    let codeText = String(format: Localization.string("class_code_label", lang: settings.appLanguage), classRoom.code)
                    Text(codeText)
                }
                .font(AppTheme.font(.subheadline, weight: .semibold))
                .foregroundStyle(AppTheme.Colors.textSecondary)
            }
            
            HStack(spacing: 40) {
                statItem(value: "\(classRoom.assignedDecks.count)", label: Localization.string("lib_tab_decks", lang: settings.appLanguage))
                statItem(value: "\(classRoom.studentsCount)", label: classRoom.studentsCount > 1 ? Localization.string("common_members", lang: settings.appLanguage) : Localization.string("common_member", lang: settings.appLanguage))
            }
            .padding(.top, 8)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(AppTheme.Colors.surfaceHighlight, lineWidth: 1)
        )
    }
    
    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(AppTheme.font(.title3, weight: .black))
                .foregroundStyle(AppTheme.Colors.textPrimary)
            Text(label)
                .font(AppTheme.font(.caption2, weight: .bold))
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .textCase(.uppercase)
        }
    }
    
    private var decksSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text(Localization.string("class_decks_title", lang: settings.appLanguage))
                    .font(AppTheme.font(.headline, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Spacer()
                Text("\(classRoom.assignedDecks.count)")
                    .font(AppTheme.font(.caption, weight: .bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppTheme.Colors.primary.opacity(0.1))
                    .foregroundStyle(AppTheme.Colors.primary)
                    .clipShape(Capsule())
            }
            
            if classRoom.assignedDecks.isEmpty {
                Text(Localization.string("class_no_decks", lang: settings.appLanguage))
                    .font(AppTheme.font(.subheadline))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
                    .background(AppTheme.Colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
            } else {
                VStack(spacing: 16) {
                    ForEach(classRoom.assignedDecks) { deck in
                        NavigationLink(destination: DeckDetailView(deck: deck)) {
                            ClassDeckRow(deck: deck)
                        }
                    }
                }
            }
        }
    }
    
    private var membersSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            let membersTitle = String(format: Localization.string("class_members_title", lang: settings.appLanguage), classRoom.studentsCount)
            Text(membersTitle)
                .font(AppTheme.font(.headline, weight: .bold))
                .foregroundStyle(AppTheme.Colors.textPrimary)
            
            VStack(spacing: 12) {
                // For demonstration, include the teacher as the first member
                MemberRow(name: classRoom.teacherName, role: Localization.string("class_role_teacher", lang: settings.appLanguage), isAdmin: true)
                
                ForEach(classRoom.students) { student in
                    NavigationLink(destination: MemberDetailView(student: student)) {
                        MemberRow(name: student.name, role: Localization.string("class_role_student", lang: settings.appLanguage), isAdmin: false)
                    }
                }
            }
        }
    }
}

struct ClassDeckRow: View {
    @EnvironmentObject var settings: AppSettings
    let deck: Deck
    
    var body: some View {
        HStack(spacing: 16) {
            Text(deck.emoji)
                .font(.title2)
                .frame(width: 56, height: 56)
                .background(Color(hex: deck.colorHex).opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(deck.title)
                    .font(AppTheme.font(.body, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                
                HStack(spacing: 8) {
                    Image(systemName: "person.circle.fill")
                        .font(.caption)
                    Text("Giang Nguyen") // Placeholder for uploader
                    Text("•")
                    Text(deck.createdAt, style: .date)
                }
                .font(AppTheme.font(.caption2))
                .foregroundStyle(AppTheme.Colors.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(AppTheme.Colors.textSecondary.opacity(0.3))
        }
        .padding(16)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppTheme.Colors.surfaceHighlight, lineWidth: 1)
        )
    }
}

struct MemberRow: View {
    let name: String
    let role: String
    let isAdmin: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(isAdmin ? AppTheme.Colors.primary.opacity(0.1) : AppTheme.Colors.surfaceHighlight)
                    .frame(width: 48, height: 48)
                Text(name.prefix(1).uppercased())
                    .font(AppTheme.font(.headline, weight: .bold))
                    .foregroundStyle(isAdmin ? AppTheme.Colors.primary : AppTheme.Colors.textSecondary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(AppTheme.font(.body, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Text(role)
                    .font(AppTheme.font(.caption2))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
            
            Spacer()
            
            if isAdmin {
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundStyle(AppTheme.Colors.accentYellow)
                    .padding(6)
                    .background(AppTheme.Colors.accentYellow.opacity(0.1))
                    .clipShape(Circle())
            }
            
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(AppTheme.Colors.textSecondary.opacity(0.3))
        }
        .padding(12)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
