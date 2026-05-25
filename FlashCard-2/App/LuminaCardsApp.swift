import SwiftUI
import SwiftData

@main
struct LuminaCardsApp: App {
    @AppStorage("isOnboardingComplete") private var isOnboardingComplete = false
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Folder.self,
            ClassRoom.self,
            Student.self,
            Deck.self,
            Card.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @StateObject private var navManager = NavigationManager()
    @StateObject private var settings = AppSettings.shared

    var body: some Scene {
        WindowGroup {
            Group {
                if isOnboardingComplete {
                    MainTabView()
                        .environmentObject(navManager)
                        .transition(.opacity)
                } else {
                    OnboardingView(isOnboardingComplete: $isOnboardingComplete)
                        .transition(.opacity)
                }
            }
            .environmentObject(settings)
            .preferredColorScheme(settings.colorScheme)
        }
        .modelContainer(sharedModelContainer)
    }
}
