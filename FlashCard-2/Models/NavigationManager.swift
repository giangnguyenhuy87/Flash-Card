import SwiftUI
import Combine

class NavigationManager: ObservableObject {
    @Published var showingCreateMenu = false
    @Published var selectedDeckForOptions: Deck? = nil
    @Published var showingDeckOptions = false
    @Published var isTabBarHidden = false
    
    // Global Tab Selection
    @Published var selectedMainTab: Int = 0
    @Published var libraryInitialTab: Int = 0 // 0: Học phần, 1: Kiểm tra thử, 2: Lớp học, 3: Thư mục
}
