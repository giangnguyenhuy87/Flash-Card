import SwiftUI

struct NotificationSettingsView: View {
    @State private var studyReminders = true
    @State private var reminderTime = Calendar.current.date(from: DateComponents(hour: 20, minute: 0)) ?? Date()
    @State private var newContentAlerts = true
    @State private var classUpdates = true
    @State private var streakReminders = true
    
    @EnvironmentObject var settings: AppSettings
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    VStack(alignment: .leading, spacing: 24) {
                        headerSection
                        
                        // Main Toggle Group
                        VStack(spacing: 0) {
                            ToggleRow(title: Localization.string("notif_study_reminder", lang: settings.appLanguage), subtitle: Localization.string("notif_study_reminder_desc", lang: settings.appLanguage), isOn: $studyReminders, icon: "clock.fill", color: .orange)
                            
                            if studyReminders {
                                Divider().background(AppTheme.Colors.surfaceHighlight).padding(.leading, 56)
                                DatePickerRow(title: Localization.string("notif_reminder_time", lang: settings.appLanguage), selection: $reminderTime)
                            }
                            
                            Divider().background(AppTheme.Colors.surfaceHighlight).padding(.leading, 56)
                            ToggleRow(title: Localization.string("notif_streak_reminder", lang: settings.appLanguage), subtitle: Localization.string("notif_streak_reminder_desc", lang: settings.appLanguage), isOn: $streakReminders, icon: "flame.fill", color: .red)

                        }
                        .background(AppTheme.Colors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        
                        sectionLabel(Localization.string("notif_other_updates", lang: settings.appLanguage))
                        
                        VStack(spacing: 0) {
                            ToggleRow(title: Localization.string("notif_new_content", lang: settings.appLanguage), subtitle: Localization.string("notif_new_content_desc", lang: settings.appLanguage), isOn: $newContentAlerts, icon: "sparkles", color: .purple)
                            Divider().background(AppTheme.Colors.surfaceHighlight).padding(.leading, 56)
                            ToggleRow(title: Localization.string("notif_class_activity", lang: settings.appLanguage), subtitle: Localization.string("notif_class_activity_desc", lang: settings.appLanguage), isOn: $classUpdates, icon: "person.3.fill", color: .blue)
                        }
                        .background(AppTheme.Colors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.top, 20)
            }
        }
        .navigationTitle(Localization.string("settings_notif", lang: settings.appLanguage))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Localization.string("settings_notif", lang: settings.appLanguage))
                .font(AppTheme.font(.title, weight: .black))
                .foregroundStyle(AppTheme.Colors.textPrimary)
            Text(Localization.string("notif_header_desc", lang: settings.appLanguage))
                .font(AppTheme.font(.subheadline))
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
    }
    
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(AppTheme.font(.subheadline, weight: .bold))
            .foregroundStyle(AppTheme.Colors.textSecondary)
    }
}

struct ToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.1))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.system(size: 16, weight: .bold))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTheme.font(.body, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Text(subtitle)
                    .font(AppTheme.font(.caption))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(AppTheme.Colors.primary)
        }
        .padding(16)
    }
}

struct DatePickerRow: View {
    let title: String
    @Binding var selection: Date
    
    var body: some View {
        HStack {
            Text(title)
                .font(AppTheme.font(.body, weight: .medium))
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .padding(.leading, 56)
            
            Spacer()
            
            DatePicker("", selection: $selection, displayedComponents: .hourAndMinute)
                .labelsHidden()
        }
        .padding(16)
    }
}

#Preview {
    NavigationStack {
        NotificationSettingsView()
    }
}
