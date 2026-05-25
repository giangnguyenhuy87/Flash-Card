import SwiftUI

struct EnhancedDeckCard: View {
    let deck: Deck
    @EnvironmentObject var settings: AppSettings
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: deck.colorHex).opacity(0.3),
                                Color(hex: deck.colorHex).opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)
                
                Text(deck.emoji)
                    .font(.system(size: 32))
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(deck.title)
                    .font(AppTheme.font(.headline, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                
                HStack(spacing: 12) {
                    Label("\(deck.activeCardsCount)", systemImage: "square.stack.3d.up.fill")
                    
                    if deck.dueCardsCount > 0 {
                        Label(String(format: Localization.string("deck_due_cards", lang: settings.appLanguage), deck.dueCardsCount), systemImage: "clock.fill")
                            .foregroundStyle(AppTheme.Colors.warning)
                    }
                }
                .font(AppTheme.font(.caption, weight: .medium))
                .foregroundStyle(AppTheme.Colors.textSecondary)
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.subheadline.bold())
                .foregroundStyle(AppTheme.Colors.textSecondary.opacity(0.5))
        }
        .padding(16)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.1), Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

struct FolderCard: View {
    let folder: Folder
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(folder.emoji)
                .font(.largeTitle)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(folder.name)
                    .font(AppTheme.font(.subheadline, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                
                Text("\(folder.decks.count) học phần")
                    .font(AppTheme.font(.caption2))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

struct ClassCard: View {
    let classRoom: ClassRoom
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(classRoom.name)
                    .font(AppTheme.font(.headline, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                
                Spacer()
                
                Text("Mã: \(classRoom.code)")
                    .font(AppTheme.font(.caption, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.Colors.primary.opacity(0.2))
                    .foregroundStyle(AppTheme.Colors.primary)
                    .clipShape(Capsule())
            }
            
            HStack {
                Label(classRoom.teacherName, systemImage: "person.circle.fill")
                Spacer()
                Label("\(classRoom.studentsCount) thành viên", systemImage: "person.2.fill")
            }
            .font(AppTheme.font(.caption))
            .foregroundStyle(AppTheme.Colors.textSecondary)
        }
        .padding(20)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(AppTheme.Colors.surfaceHighlight, lineWidth: 1)
        )
    }
}

struct CreateOptionRow: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(color)
                }
                
                Text(title)
                    .font(AppTheme.font(.body, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.textSecondary.opacity(0.5))
            }
            .padding(12)
            .background(AppTheme.Colors.surfaceHighlight)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

struct OptionRow: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 42, height: 42)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(color)
                }
                
                Text(title)
                    .font(AppTheme.font(.body, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.textSecondary.opacity(0.4))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(AppTheme.Colors.surfaceHighlight)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            )
        }
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let count: Int?
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                
                Spacer()
                
                if let count = count {
                    Text("\(count)")
                        .font(AppTheme.font(.caption, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(color)
                        .clipShape(Capsule())
                }
            }
            
            Text(title)
                .font(AppTheme.font(.subheadline, weight: .bold))
                .foregroundStyle(AppTheme.Colors.textPrimary)
        }
        .padding(16)
        .frame(width: 140, height: 100)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppTheme.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}


struct CompactDeckCard: View {
    let deck: Deck
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(deck.emoji)
                .font(.system(size: 24))
                .padding(12)
                .background(Color(hex: deck.colorHex).opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(deck.title)
                    .font(AppTheme.font(.subheadline, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .lineLimit(1)
                
                Text("\(deck.activeCardsCount) thẻ")
                    .font(AppTheme.font(.caption2))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
        .frame(width: 140)
        .padding(16)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(AppTheme.Colors.surfaceHighlight, lineWidth: 1)
        )
    }
}

// Global UI Component Helper
struct InstructionRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(AppTheme.Colors.primary)
                .frame(width: 32)
            
            Text(text)
                .font(AppTheme.font(.body))
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
    }
}
