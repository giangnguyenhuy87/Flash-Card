import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case vietnamese = "vi"
    case english = "en"
    case japanese = "ja"
    case korean = "ko"
    case chinese = "zh"
    case thai = "th"
    
    var id: String { self.rawValue }
    
    var name: String {
        switch self {
        case .vietnamese: return "Tiếng Việt"
        case .english: return "English"
        case .japanese: return "日本語"
        case .korean: return "한국어"
        case .chinese: return "简体中文"
        case .thai: return "ไทย"
        }
    }
    
    var flag: String {
        switch self {
        case .vietnamese: return "🇻🇳"
        case .english: return "🇺🇸"
        case .japanese: return "🇯🇵"
        case .korean: return "🇰🇷"
        case .chinese: return "🇨🇳"
        case .thai: return "🇹🇭"
        }
    }
}

struct Localization {
    private static let translations: [String: [String: String]] = [
            // MARK: - Navigation Tabs
            "tab_home": ["vi": "Trang chủ", "en": "Home", "ja": "ホーム", "ko": "홈", "zh": "首页", "th": "หน้าแรก"],
            "tab_library": ["vi": "Thư viện", "en": "Library", "ja": "ライブラリ", "ko": "라이브러리", "zh": "库", "th": "ห้องสมุด"],
            "tab_stats": ["vi": "Thống kê", "en": "Stats", "ja": "統計", "ko": "통계", "zh": "统计", "th": "สถิติ"],
            "tab_profile": ["vi": "Cá nhân", "en": "Profile", "ja": "プロフィール", "ko": "프로필", "zh": "个人资料", "th": "โปรไฟล์"],
            "nav_choose_other": ["vi": "Chọn bộ thẻ khác", "en": "Choose other deck", "ja": "別のセットを選択", "ko": "다른 세트 선택", "zh": "选择其他学习集", "th": "เลือกชุดการเรียนอื่น"],
            "common_back": ["vi": "Quay lại", "en": "Back", "ja": "戻る", "ko": "뒤로", "zh": "返回", "th": "ย้อนกลับ"],
            "common_new": ["vi": "MỚI", "en": "NEW", "ja": "新機能", "ko": "신규", "zh": "新", "th": "ใหม่"],
            "onboarding_title_1": ["vi": "Hacking Não", "en": "Brain Hacking", "ja": "ブレインハッキング", "ko": "브레인 해킹", "zh": "大脑黑客", "th": "แฮ็กสมอง"],
            "onboarding_desc_1": ["vi": "Làm chủ ngôn ngữ với thuật toán lặp lại ngắt quãng AI. Học thông minh hơn, không cần chăm chỉ hơn.", "en": "Master languages with AI-powered spaced repetition. Learn smarter, not harder.", "ja": "AIを活用した間隔反復で言語を習得。よりスマートに学びましょう。", "ko": "AI 기반 간격 반복으로 언어를 마스터하세요. 더 똑똑하게 배우세요.", "zh": "利用 AI 支持的间隔重复掌握语言。更聪明地学习，而不是更努力地学习。", "th": "เชี่ยวชาญภาษาด้วยการทำซ้ำแบบเว้นระยะที่ขับเคลื่อนด้วย AI เรียนรู้อย่างชาญฉลาดขึ้น ไม่ใช่ยากขึ้น"],
            "onboarding_title_2": ["vi": "Giữ Lửa", "en": "Keep the Streak", "ja": "ストリークを維持", "ko": "스트릭 유지", "zh": "保持连续学习", "th": "รักษาต่อเนื่อง"],
            "onboarding_desc_2": ["vi": "Mục tiêu hàng ngày phù hợp với phong cách của bạn. Xây dựng thói quen bền vững. Đừng để đứt chuỗi nhé!", "en": "Daily goals that fit your vibe. Build habits that stick. Don't break the chain!", "ja": "あなたに合った毎日の目標。習慣を身につけましょう。連鎖を断ち切らないでください！", "ko": "당신에게 맞는 일일 목표. 습관을 기르세요. 체인을 끊지 마세요!", "zh": "适合您风格的每日目标。养成持久的习惯。不要中断连胜！", "th": "เป้าหมายรายวันที่เข้ากับสไตล์ของคุณ สร้างนิสัยที่ติดตัว อย่าทำลายสถิติต่อเนื่อง!"],
            "onboarding_title_3": ["vi": "Theo Dõi Tiến Độ", "en": "Track Progress", "ja": "進捗を追跡", "ko": "진행 상황 추적", "zh": "跟踪进度", "th": "ติดตามความคืบหน้า"],
            "onboarding_desc_3": ["vi": "Số liệu thống kê và thông tin chi tiết đẹp mắt. Xem bản thân thăng cấp mỗi ngày.", "en": "Beautiful stats and insights. Watch yourself level up every single day.", "ja": "美しい統計と洞察。毎日レベルアップする自分を観察してください。", "ko": "아름다운 통계와 통찰력. 매일 레벨업하는 자신을 지켜보세요.", "zh": "精美的统计数据和见解。看着自己每天都在进步。", "th": "สถิติและข้อมูลเชิงลึกที่สวยงาม ดูตัวเองเลเวลอัพในทุกๆ วัน"],
            "onboarding_next": ["vi": "Tiếp theo", "en": "Next", "ja": "次へ", "ko": "다음", "zh": "下一步", "th": "ถัดไป"],
            "onboarding_start": ["vi": "Bắt đầu ngay", "en": "Get Started", "ja": "始める", "ko": "시작하기", "zh": "开始使用", "th": "เริ่มต้นใช้งาน"],
            "common_copy": ["vi": "Bản sao", "en": "Copy", "ja": "コピー", "ko": "사본", "zh": "副本", "th": "สำเนา"],
            "common_members": ["vi": "Thành viên", "en": "Members", "ja": "メンバー", "ko": "멤버", "zh": "成员", "th": "สมาชิก"],
            "common_member": ["vi": "Thành viên", "en": "Member", "ja": "メンバー", "ko": "멤버", "zh": "成员", "th": "สมาชิก"],
            "common_save_changes": ["vi": "Lưu thay đổi", "en": "Save Changes", "ja": "変更を保存", "ko": "변경 사항 저장", "zh": "保存更改", "th": "บันทึกการเปลี่ยนแปลง"],
            "common_close": ["vi": "Đóng", "en": "Close", "ja": "閉じる", "ko": "닫기", "zh": "关闭", "th": "ปิด"],
            
            // MARK: - Home View
            "home_greeting_morning": ["vi": "Chào buổi sáng", "en": "Good Morning", "ja": "おはよう", "ko": "좋은 아침", "zh": "早上好", "th": "อรุณสวัสดิ์"],
            "home_greeting_afternoon": ["vi": "Chào buổi chiều", "en": "Good Afternoon", "ja": "こんにちは", "ko": "안녕하세요", "zh": "下午好", "th": "สวัสดีตอนบ่าย"],
            "home_greeting_evening": ["vi": "Chào buổi tối", "en": "Good Evening", "ja": "こんばんは", "ko": "안녕하세요", "zh": "晚上好", "th": "สวัสดีตอนเย็น"],
            "home_streak": ["vi": "Ngày học", "en": "Streak", "ja": "継続日数", "ko": "스트릭", "zh": "续学", "th": "สถิติการเรียน"],
            "home_mastered": ["vi": "Đã thuộc", "en": "Mastered", "ja": "学習済み", "ko": "마스터", "zh": "已掌握", "th": "เชี่ยวชาญแล้ว"],
            "home_day": ["vi": "ngày", "en": "days", "ja": "日", "ko": "일", "zh": "天", "th": "วัน"],
            "home_card": ["vi": "thẻ", "en": "cards", "ja": "カード", "ko": "카드", "zh": "张", "th": "การ์ด"],
            "home_quick_actions": ["vi": "Hành động nhanh", "en": "Quick Actions", "ja": "クイック", "ko": "작업", "zh": "快捷", "th": "ด่วน"],
            "home_review": ["vi": "Ôn tập", "en": "Review", "ja": "復習", "ko": "복습", "zh": "复习", "th": "ทบทวน"],
            "home_learn": ["vi": "Học mới", "en": "Learn", "ja": "学習", "ko": "신규", "zh": "学习", "th": "เรียนใหม่"],
            "home_quiz": ["vi": "Quiz", "en": "Quiz", "ja": "クイズ", "ko": "퀴즈", "zh": "测试", "th": "ควิซ"],
            "home_continue": ["vi": "Học tiếp", "en": "Continue", "ja": "継続", "ko": "계속", "zh": "继续", "th": "ต่อ"],
            "home_recent": ["vi": "Gần đây", "en": "Recent", "ja": "最近", "ko": "최근", "zh": "最近", "th": "ล่าสุด"],
            "home_empty_decks": ["vi": "Chưa có học phần nào", "en": "No decks yet", "ja": "セットがありません", "ko": "세트가 없습니다", "zh": "暂无学习集", "th": "ยังไม่มีชุดการเรียน"],
            "home_classes": ["vi": "Lớp của bạn", "en": "My Classes", "ja": "クラス", "ko": "클래스", "zh": "班级", "th": "ชั้นเรียน"],
            "home_empty_in_progress": ["vi": "Chưa có học phần nào đang học", "en": "No decks being learned yet", "ja": "学習中のセットはありません", "ko": "학습 중인 세트가 없습니다", "zh": "还没有正在学习的学习集", "th": "ยังไม่มีชุดการเรียนที่กำลังเรียน"],
            "home_create_first_deck": ["vi": "Tạo học phần đầu tiên", "en": "Create first deck", "ja": "最初のセットを作成", "ko": "첫 번째 세트 생성", "zh": "创建第一个学习集", "th": "สร้างชุดการเรียนแรก"],
            "home_empty_classes": ["vi": "Chưa tham gia lớp nào", "en": "No classes joined", "ja": "クラスに参加していません", "ko": "가입한 클래스가 없습니다", "zh": "未参加任何班级", "th": "ยังไม่ได้เข้าร่วมชั้นเรียนใดๆ"],
            "home_join_class_msg": ["vi": "Nhập mã lớp để tham gia", "en": "Enter class code to join", "ja": "参加コードを入力", "ko": "참여 코드를 입력하세요", "zh": "输入班级代码加入", "th": "ใส่รหัสชั้นเรียนเพื่อเข้าร่วม"],
            "home_items_unit": ["vi": "mục", "en": "items", "ja": "アイテム", "ko": "항목", "zh": "个项目", "th": "รายการ"],
            "home_class_code_prefix": ["vi": "Mã: %@", "en": "Code: %@", "ja": "コード: %@", "ko": "코드: %@", "zh": "代码: %@", "th": "รหัส: %@"],
            
            // MARK: - Library View
            "lib_search": ["vi": "Tìm kiếm bộ thẻ, thư mục...", "en": "Search decks, folders...", "ja": "検索...", "ko": "검색...", "zh": "搜索...", "th": "ค้นหา..."],
            "lib_tab_decks": ["vi": "Học phần", "en": "Decks", "ja": "セット", "ko": "세트", "zh": "学习集", "th": "ชุดการเรียน"],
            "lib_tab_tests": ["vi": "Kiểm tra", "en": "Tests", "ja": "テスト", "ko": "テスト", "zh": "测试", "th": "แบบทดสอบ"],
            "lib_tab_classes": ["vi": "Lớp học", "en": "Classes", "ja": "クラス", "ko": "클래스", "zh": "班级", "th": "ชั้นเรียน"],
            "lib_tab_folders": ["vi": "Thư mục", "en": "Folders", "ja": "フォルダ", "ko": "폴더", "zh": "文件夹", "th": "โฟลเดอร์"],
            "lib_empty_decks": ["vi": "Chưa có bộ thẻ nào", "en": "No decks yet", "ja": "セットがありません", "ko": "세트가 없습니다", "zh": "暂无学习集", "th": "ยังไม่มีชุดการเรียน"],
            
            // MARK: - Stats View
            "stats_title": ["vi": "Thống kê học tập", "en": "Learning Stats", "ja": "学習統計", "ko": "학습 통계", "zh": "学习统计", "th": "สถิติการเรียน"],
            "stats_subtitle": ["vi": "Dữ liệu phân tích quá trình của bạn", "en": "Detailed analysis of your progress", "ja": "あなたの進捗状況の詳細な分析", "ko": "진도에 대한 상세 분석", "zh": "进度详细分析", "th": "วิเคราะห์ความคืบหน้าของคุณ"],
            "stats_total_time": ["vi": "Tổng thời gian", "en": "Total Time", "ja": "合計時間", "ko": "총 시간", "zh": "总时长", "th": "เวลารวม"],
            "stats_total_time_unit": ["vi": "giờ", "en": "hrs", "ja": "時間", "ko": "시간", "zh": "小时", "th": "ชม."],
            "stats_accuracy": ["vi": "Độ chính xác", "en": "Accuracy", "ja": "正解率", "ko": "정확도", "zh": "准确率", "th": "ความแม่นยำ"],
            "stats_activity_7days": ["vi": "Hoạt động 7 ngày qua", "en": "7-Day Activity", "ja": "過去7日間のアクティビティ", "ko": "최근 7일간의 활동", "zh": "过去7天活动", "th": "กิจกรรมใน 7 วันที่ผ่านมา"],
            "stats_activity_total": ["vi": "Tổng", "en": "Total", "ja": "合計", "ko": "합계", "zh": "总计", "th": "รวม"],
            "stats_day_mon": ["vi": "T2", "en": "Mon", "ja": "月", "ko": "월", "zh": "一", "th": "จ."],
            "stats_day_tue": ["vi": "T3", "en": "Tue", "ja": "火", "ko": "화", "zh": "二", "th": "อ."],
            "stats_day_wed": ["vi": "T4", "en": "Wed", "ja": "水", "ko": "수", "zh": "三", "th": "พ."],
            "stats_day_thu": ["vi": "T5", "en": "Thu", "ja": "木", "ko": "목", "zh": "四", "th": "พฤ."],
            "stats_day_fri": ["vi": "T6", "en": "Fri", "ja": "金", "ko": "금", "zh": "五", "th": "ศ."],
            "stats_day_sat": ["vi": "T7", "en": "Sat", "ja": "土", "ko": "토", "zh": "六", "th": "ส."],
            "stats_day_sun": ["vi": "CN", "en": "Sun", "ja": "日", "ko": "일", "zh": "日", "th": "อา."],
            "stats_top_decks": ["vi": "Học phần dẫn đầu", "en": "Top Decks", "ja": "トップセット", "ko": "주요 세트", "zh": "热门学习集", "th": "ชุดการเรียนยอดนิยม"],
            "stats_empty_msg": ["vi": "Bắt đầu học để xem phân tích", "en": "Start studying to see analytics", "ja": "分析を表示するには学習を開始してください", "ko": "분석을 보려면 학습을 시작하세요", "zh": "开始学习以查看分析", "th": "เริ่มเรียนเพื่อดูการวิเคราะห์"],
            "stats_mastery_level": ["vi": "Cấp độ thông thạo", "en": "Mastery Level", "ja": "習熟度レベル", "ko": "숙달 수준", "zh": "掌握程度", "th": "ระดับความเชี่ยวชาญ"],
            "stats_mastery_desc": ["vi": "Bạn đã đạt được những bước tiến lớn! Chỉ còn 35% nữa để hoàn thành mục tiêu.", "en": "You've made great progress! Only 35% more to reach your goal.", "ja": "素晴らしい進歩です！目標達成まであと35％です。", "ko": "놀라운 진전입니다! 목표 달성까지 35% 남았습니다.", "zh": "取得了巨大的进步！距离达到目标仅剩 35%。", "th": "คุณก้าวหน้าไปมาก! อีกเพียง 35% ก็จะถึงเป้าหมายแล้ว"],
            "stats_mastery_tier": ["vi": "Hạng vàng", "en": "Gold Tier", "ja": "ゴールドティア", "ko": "골드 티어", "zh": "黄金等级", "th": "ระดับทอง"],
            "stats_mastery_msg": ["vi": "Tiếp tục cố gắng nhé!", "en": "Keep it up!", "ja": "その調子で頑張りましょう！", "ko": "계속 힘내세요!", "zh": "继续努力！", "th": "พยายามต่อไปนะ!"],
            "stats_cards_learned": ["vi": "Thẻ đã học", "en": "Cards Learned", "ja": "学習カード", "ko": "학습한 카드", "zh": "学习张数", "th": "การ์ดที่เรียนแล้ว"],
            
            // MARK: - Profile & Settings
            "profile_account": ["vi": "Tài khoản & Bảo mật", "en": "Account & Security", "ja": "アカウントとセキュリティ", "ko": "계정 및 보안", "zh": "账户与安全", "th": "บัญชีและความปลอดภัย"],
            "profile_app": ["vi": "Ứng dụng", "en": "App Settings", "ja": "アプリ設定", "ko": "앱 설정", "zh": "应用设置", "th": "ตั้งค่าแอป"],
            "profile_support": ["vi": "Hỗ trợ & Thông tin", "en": "Support & Info", "ja": "サポートと情報", "ko": "지원 및 정보", "zh": "支持与信息", "th": "ความช่วยเหลือ và ข้อมูล"],
            "profile_logout": ["vi": "Đăng xuất", "en": "Logout", "ja": "ログアウト", "ko": "로그아웃", "zh": "退出登录", "th": "ออกจากระบบ"],
            "profile_personal_info": ["vi": "Thông tin cá nhân", "en": "Personal Info", "ja": "個人情報", "ko": "개인 정보", "zh": "个人信息", "th": "ข้อมูลส่วนตัว"],
            "profile_email": ["vi": "Email", "en": "Email", "ja": "メール", "ko": "이메일", "zh": "电子邮件", "th": "อีเมล"],
            "profile_change_password": ["vi": "Đổi mật khẩu", "en": "Change Password", "ja": "パスワード変更", "ko": "비밀번호 변경", "zh": "修改密码", "th": "เปลี่ยนรหัสผ่าน"],
            "profile_privacy": ["vi": "Quyền riêng tư", "en": "Privacy Policy", "ja": "プライバシーポリシー", "ko": "개인정보 보호정책", "zh": "隐私政策", "th": "นโยบายความเป็นส่วนตัว"],
            "profile_terms": ["vi": "Điều khoản sử dụng", "en": "Terms of Service", "ja": "利用規約", "ko": "이용 약관", "zh": "服务条款", "th": "ข้อ khoảnการใช้งาน"],
            "profile_about": ["vi": "Về LuminaCards", "en": "About LuminaCards", "ja": "LuminaCardsについて", "ko": "LuminaCards 정보", "zh": "关于 LuminaCards", "th": "เกี่ยวกับ LuminaCards"],
            "profile_join_date": ["vi": "Gia nhập từ %@", "en": "Joined %@", "ja": "%@に加入", "ko": "%@에 가입", "zh": "%@加入", "th": "เข้าร่วมเมื่อ %@"],
            "profile_achievements": ["vi": "Thành tựu & Hoạt động", "en": "Achievements & Activity", "ja": "アチーブメント", "ko": "업적", "zh": "成就与活动", "th": "ความสำเร็จ"],
            "profile_membership": ["vi": "Gói thành viên", "en": "Membership Plan", "ja": "メンバーシップ", "ko": "멤버십", "zh": "会员计划", "th": "แผนสมาชิก"],
            "profile_plus_member": ["vi": "Thành viên Lumina Plus", "en": "Lumina Plus Member", "ja": "Lumina Plus メンバー", "ko": "Lumina Plus 멤버", "zh": "Lumina Plus 会员", "th": "สมาชิก Lumina Plus"],
            "profile_upgrade_plus": ["vi": "Nâng cấp Lumina Plus", "en": "Upgrade to Plus", "ja": "Plusにアップグレード", "ko": "Plus로 업그레이드", "zh": "升级 Plus", "th": "อัปเกรดเป็น Plus"],
            "profile_annual_plan": ["vi": "Gói năm • Sẽ gia hạn %@", "en": "Annual Plan • Renews %@", "ja": "年額プラン • 更新日 %@", "ko": "1년 플랜 • 갱신일 %@", "zh": "年费计划 • 续费日期 %@", "th": "แผนรายปี • ต่ออายุ %@"],
            "profile_unlimited_study": ["vi": "Học không giới hạn, không quảng cáo", "en": "Unlimited study, no ads", "ja": "制限なし、広告なし", "ko": "무제한 학습, 광고 없음", "zh": "学习无限制，无广告", "th": "เรียนไม่จำกัด ไม่มีโฆษณา"],
            
            "settings_language": ["vi": "Ngôn ngữ", "en": "Language", "ja": "言語", "ko": "언어", "zh": "语言", "th": "ภาษา"],
            "settings_theme": ["vi": "Giao diện & Chủ đề", "en": "Appearance & Theme", "ja": "外観とテーマ", "ko": "테마 및 스킨", "zh": "外观与主题", "th": "ธีมและรูปลักษณ์"],
            "settings_notif": ["vi": "Thông báo & Nhắc nhở", "en": "Notifications & Reminders", "ja": "通知とリマインダー", "ko": "알림 및 미리알림", "zh": "通知与提醒", "th": "การแจ้งเตือน và เตือนความจำ"],
            "settings_feedback": ["vi": "Góp ý & Phản hồi", "en": "Feedback & Support", "ja": "フィードバック", "ko": "피드백", "zh": "意见反馈", "th": "ความคิดเห็น"],
            
            "profile_basic_info": ["vi": "Thông tin cơ bản", "en": "Basic Information", "ja": "基本情報", "ko": "기본 정보", "zh": "基本信息", "th": "ข้อมูลพื้นฐาน"],
            "profile_full_name": ["vi": "Họ và tên", "en": "Full Name", "ja": "氏名", "ko": "이름", "zh": "全名", "th": "ชื่อ-นามสกุล"],
            "profile_birthday": ["vi": "Ngày sinh", "en": "Birthday", "ja": "生年月日", "ko": "생년월일", "zh": "生日", "th": "วันเกิด"],
            "profile_bio": ["vi": "Giới thiệu", "en": "Bio", "ja": "自己紹介", "ko": "소개", "zh": "简介", "th": "แนะนำตัว"],
            
            "profile_display_mode": ["vi": "Chế độ hiển thị", "en": "Display Mode", "ja": "表示モード", "ko": "표시 모드", "zh": "显示模式", "th": "โหมดการแสดงผล"],
            "profile_theme_dark": ["vi": "Tối", "en": "Dark", "ja": "ダーク", "ko": "어둡게", "zh": "深色", "th": "มืด"],
            "profile_theme_light": ["vi": "Sáng", "en": "Light", "ja": "ライト", "ko": "밝게", "zh": "浅色", "th": "สว่าง"],
            "profile_theme_auto": ["vi": "Tự động", "en": "Auto", "ja": "自動", "ko": "자동", "zh": "自动", "th": "อัตโนมัติ"],
            "profile_personalize": ["vi": "Cá nhân hóa", "en": "Personalization", "ja": "パーソナライズ", "ko": "개인화", "zh": "个性化", "th": "การปรับแต่ง"],
            "profile_premium_colors": ["vi": "Màu thẻ cao cấp", "en": "Premium Card Colors", "ja": "プレミアムカードの色", "ko": "프리미엄 카드 색상", "zh": "高级卡片颜色", "th": "สีการ์ดพรีเมียม"],
            "profile_premium_colors_desc": ["vi": "Sử dụng gradient và hiệu ứng phát sáng", "en": "Use gradients and glow effects", "ja": "グラデーションと発光効果を使用する", "ko": "그라데이션 및 발광 효과 사용", "zh": "使用渐变和发光效果", "th": "ใช้ไล่ระดับสีและเอฟเฟกต์เรืองแสง"],
            "profile_font_size": ["vi": "Kích cỡ chữ", "en": "Font Size", "ja": "フォントサイズ", "ko": "글꼴 크기", "zh": "字体大小", "th": "ขนาดตัวอักษร"],
            "profile_appearance_desc": ["vi": "Tùy chỉnh phong cách học tập của riêng bạn", "en": "Customize your own learning style", "ja": "自分の学習スタイルをカスタマイズする", "ko": "나만의 학습 스타일 맞춤 설정", "zh": "自定义您自己的学习风格", "th": "ปรับแต่งสไตล์การเรียนรู้ในแบบของคุณ"],
            "profile_appearance_preview_text": ["vi": "Đây là cách văn bản sẽ hiển thị trong ứng dụng của bạn.", "en": "This is how text will appear in your app.", "ja": "これはアプリでのテキストの表示方法です。", "ko": "앱에서 텍스트가 표시되는 방식입니다.", "zh": "这是文本在应用中的显示方式。", "th": "นี่คือลักษณะที่ข้อความจะปรากฏในแอปของคุณ"],

            "profile_plus_upgrade": ["vi": "Nâng cấp Lumina Plus", "en": "Upgrade Lumina Plus", "ja": "Lumina Plusにアップグレード", "ko": "Lumina Plus 업그레이드", "zh": "升级 Lumina Plus", "th": "อัปเกรด Lumina Plus"],
            "profile_plus_tagline": ["vi": "Mở khóa toàn bộ tiềm năng học tập của bạn", "en": "Unlock your full learning potential", "ja": "学習の可能性を最大限に引き出す", "ko": "학습 잠재력을 최대한 발휘하세요", "zh": "释放您的全部学习潜力", "th": "ปลดล็อกศักยภาพการเรียนรู้ของคุณให้เต็มที่"],
            "profile_benefit_unlimited_title": ["vi": "Không giới hạn học phần", "en": "Unlimited Decks", "ja": "セット数無制限", "ko": "무제한 세트", "zh": "无限学习集", "th": "ชุดการเรียนไม่จำกัด"],
            "profile_benefit_unlimited_desc": ["vi": "Tạo và lưu trữ hàng nghìn thẻ ghi nhớ.", "en": "Create and store thousands of flashcards.", "ja": "何千もの単語カードを作成して保存します。", "ko": "수천 개의 플래시카드를 만들고 저장하세요.", "zh": "创建并存储数千张单词卡。", "th": "สร้างและเก็บรักษาการ์ดหน่วยความจำหลายพันใบ"],
            "profile_benefit_ads_title": ["vi": "Không quảng cáo", "en": "No Ads", "ja": "広告なし", "ko": "광고 없음", "zh": "无广告", "th": "ไม่มีโฆษณา"],
            "profile_benefit_ads_desc": ["vi": "Tập trung hoàn toàn vào việc học, không bị làm phiền.", "en": "Focus entirely on learning, without interruptions.", "ja": "中断することなく、学習に完全に集中できます。", "ko": "방해 없이 학습에만 집중하세요.", "zh": "完全专注于学习，不受干扰。", "th": "โฟกัสกับการเรียนได้อย่างเต็มที่โดยไม่มีสิ่งรบกวน"],
            "profile_benefit_srs_title": ["vi": "Chế độ học thông minh", "en": "Smart Learning Mode", "ja": "スマート学習モード", "ko": "스마트 학습 모드", "zh": "智能学习模式", "th": "โหมดการเรียนรู้อัจฉริยะ"],
            "profile_benefit_srs_desc": ["vi": "Sử dụng thuật toán SRS nâng cao để ghi nhớ lâu hơn.", "en": "Use advanced SRS algorithms for longer retention.", "ja": "高度なSRSアルゴリズムを使用して、より長く記憶に定着させます。", "ko": "더 오랜 암기를 위해 고급 SRS 알고리즘을 사용하세요.", "zh": "使用先进的 SRS 算法实现更长时间的记忆。", "th": "ใช้อัลกอริทึม SRS ขั้นสูงเพื่อการจดจำที่ยาวนานขึ้น"],
            "profile_benefit_offline_title": ["vi": "Học ngoại tuyến", "en": "Offline Learning", "ja": "オフライン学習", "ko": "오프라인 학습", "zh": "离线学习", "th": "การเรียนรู้ออฟไลน์"],
            "profile_benefit_offline_desc": ["vi": "Tải về và học bất cứ khi nào, ngay cả khi không có mạng.", "en": "Download and study anytime, even without internet.", "ja": "インターネットがなくても、いつでもダウンロードして学習できます。", "ko": "인터넷이 없어도 언제 어디서나 다운로드하여 학습하세요.", "zh": "随时随地下载学习，即使没有网络。", "th": "ดาวน์โหลดและเรียนรู้ได้ทุกเมื่อ แม้ไม่มีอินเทอร์เน็ต"],
            "profile_benefit_media_title": ["vi": "Thêm hình ảnh & âm thanh", "en": "Add Images & Audio", "ja": "画像と音声の追加", "ko": "이미지 및 오디오 추가", "zh": "添加图像和音频", "th": "เพิ่มรูปภาพและเสียง"],
            "profile_benefit_media_desc": ["vi": "Đính kèm phương tiện vào thẻ để học trực quan hơn.", "en": "Attach media to cards for more visual learning.", "ja": "カードにメディアを添付して、より視覚的に学習できます。", "ko": "보다 시각적인 학습을 위해 카드에 미디어를 첨부하세요.", "zh": "在卡片中附加多媒体，实现更直观的学习。", "th": "แนบสื่อลงในการ์ดเพื่อการเรียนรู้ด้วยภาพที่ชัดเจนยิ่งขึ้น"],
            "profile_plan_monthly": ["vi": "Hàng tháng", "en": "Monthly", "ja": "月額", "ko": "월간", "zh": "每月", "th": "รายเดือน"],
            "profile_plan_yearly": ["vi": "Hàng năm", "en": "Yearly", "ja": "年額", "ko": "연간", "zh": "每年", "th": "รายปี"],
            "profile_plan_save": ["vi": "Tiết kiệm %@", "en": "Save %@", "ja": "%@ 節約", "ko": "%@ 절약", "zh": "节省 %@", "th": "ประหยัด %@"],
            "profile_trial_start": ["vi": "Bắt đầu dùng thử 7 ngày miễn phí", "en": "Start 7-day free trial", "ja": "7日間の無料トライアルを開始", "ko": "7일 무료 체험 시작", "zh": "开始 7 天免费试用", "th": "เริ่มทดลองใช้ฟรี 7 วัน"],
            "profile_subscribe": ["vi": "Đăng ký ngay", "en": "Subscribe Now", "ja": "今すぐ購読", "ko": "지금 구독", "zh": "立即订阅", "th": "สมัครสมาชิกตอนนี้"],
            "profile_subscription_disclaimer": ["vi": "Gia hạn tự động. Hủy bất kỳ lúc nào.", "en": "Auto-renews. Cancel anytime.", "ja": "自動更新。いつでもキャンセル可能。", "ko": "자동 갱신. 언제든지 취소 가능.", "zh": "自动续订。随时取消。", "th": "ต่ออายุอัตโนมัติ ยกเลิกเมื่อไหร่ก็ได้"],

            "profile_current_password": ["vi": "Mật khẩu hiện tại", "en": "Current Password", "ja": "現在のパスワード", "ko": "현재 비밀번호", "zh": "当前密码", "th": "รหัสผ่านปัจจุบัน"],
            "profile_new_password": ["vi": "Mật khẩu mới", "en": "New Password", "ja": "新しいパスワード", "ko": "새 비밀번호", "zh": "新密码", "th": "รหัสผ่านใหม่"],
            "profile_confirm_password": ["vi": "Xác nhận mật khẩu mới", "en": "Confirm New Password", "ja": "新しいパスワードを再入力", "ko": "새 비밀번호 확인", "zh": "确认新密码", "th": "ยืนยันรหัสผ่านใหม่"],
            "profile_pwd_8_chars": ["vi": "Ít nhất 8 ký tự", "en": "At least 8 characters", "ja": "少なくとも8文字", "ko": "최소 8자", "zh": "至少 8 个字符", "th": "อย่างน้อย 8 ตัวอักษร"],
            "profile_pwd_letters_numbers": ["vi": "Bao gồm chữ cái và số", "en": "Include letters and numbers", "ja": "文字と数字を含める", "ko": "문자와 숫자 포함", "zh": "包含字母和数字", "th": "ประกอบด้วยตัวอักษรและตัวเลข"],
            "profile_pwd_match": ["vi": "Khớp với xác nhận", "en": "Matches confirmation", "ja": "確認用と一致", "ko": "확인과 일치", "zh": "与确认匹配", "th": "ตรงกับการยืนยัน"],
            "profile_pwd_update": ["vi": "Cập nhật mật khẩu", "en": "Update Password", "ja": "パスワードを更新", "ko": "비밀번호 업데이트", "zh": "更新密码", "th": "อัปเดตรหัสผ่าน"],

            "notif_study_reminder": ["vi": "Nhắc nhở học tập", "en": "Study Reminders", "ja": "学習リマインダー", "ko": "학습 알림", "zh": "学习提醒", "th": "เตือนการเรียน"],
            "notif_study_reminder_desc": ["vi": "Nhắc bạn ôn tập thẻ hàng ngày", "en": "Remind you to review cards daily", "ja": "毎日カードを復習するように促します", "ko": "매일 카드 복습을 상기시켜 줍니다", "zh": "提醒您每天复习卡片", "th": "เตือนให้คุณทบทวนการ์ดทุกวัน"],
            "notif_reminder_time": ["vi": "Giờ nhắc nhở", "en": "Reminder Time", "ja": "リマインダー時間", "ko": "알림 시간", "zh": "提醒时间", "th": "เวลาเตือน"],
            "notif_streak_reminder": ["vi": "Nhắc nhở chuỗi học", "en": "Streak Reminders", "ja": "ストリークリマインダー", "ko": "스트릭 알림", "zh": "连续学习提醒", "th": "เตือนสถิติต่อเนื่อง"],
            "notif_streak_reminder_desc": ["vi": "Thông báo khi bạn sắp mất streak", "en": "Notify when you're about to lose your streak", "ja": "ストリークが途切れそうなときに通知します", "ko": "스트릭을 잃기 직전에 알림", "zh": "在您即将中断连续学习时通知您", "th": "แจ้งเตือนเมื่อคุณกำลังจะเสียสถิติต่อเนื่อง"],
            "notif_other_updates": ["vi": "Cập nhật khác", "en": "Other Updates", "ja": "その他の更新", "ko": "기타 업데이트", "zh": "其他更新", "th": "การอัปเดตอื่นๆ"],
            "notif_new_content": ["vi": "Nội dung mới", "en": "New Content", "ja": "新しいコンテンツ", "ko": "새로운 콘텐츠", "zh": "新内容", "th": "เนื้อหาใหม่"],
            "notif_new_content_desc": ["vi": "Thông báo khi có bộ thẻ mới hay", "en": "Notify when there are interesting new decks", "ja": "興味深い新しいセットがあるときに通知します", "ko": "흥미로운 새 세트가 있을 때 알림", "zh": "有有趣的新学习集时通知您", "th": "แจ้งเตือนเมื่อมีชุดการเรียนใหม่ที่น่าสนใจ"],
            "notif_class_activity": ["vi": "Hoạt động lớp học", "en": "Class Activity", "ja": "クラスのアクティビティ", "ko": "클래스 활동", "zh": "班级活动", "th": "กิจกรรมในชั้นเรียน"],
            "notif_class_activity_desc": ["vi": "Thông báo từ giáo viên và bạn học", "en": "Notifications from teachers and classmates", "ja": "教師やクラスメートからの通知", "ko": "교사 및 급우의 알림", "zh": "来自教师和同学的通知", "th": "การแจ้งเตือนจากอาจารย์และเพื่อนร่วมชั้น"],
            "notif_header_desc": ["vi": "Quản lý cách Lumina tương tác với bạn", "en": "Manage how Lumina interacts with you", "ja": "Luminaとのやり取りを管理する", "ko": "Lumina가 사용자와 상호 작용하는 방식 관리", "zh": "管理 Lumina 与您的交互方式", "th": "จัดการวิธีที่ Lumina โต้ตอบกับคุณ"],

            "feedback_bug": ["vi": "Báo lỗi", "en": "Bug Report", "ja": "バグ報告", "ko": "버그 제보", "zh": "错误报告", "th": "รายงานข้อผิดพลาด"],
            "feedback_feature": ["vi": "Yêu cầu tính năng", "en": "Feature Request", "ja": "機能のリクエスト", "ko": "기능 요청", "zh": "功能请求", "th": "ขอคุณสมบัติใหม่"],
            "feedback_general": ["vi": "Góp ý chung", "en": "General Feedback", "ja": "一般的なフィードバック", "ko": "일반 피드백", "zh": "一般反馈", "th": "ข้อเสนอแนะทั่วไป"],
            "feedback_layout": ["vi": "Giao diện", "en": "Layout/Design", "ja": "レイアウト/デザイン", "ko": "레이아웃/디자인", "zh": "布局/设计", "th": "เลย์เอาต์/การออกแบบ"],
            "feedback_rating_question": ["vi": "Bạn đánh giá ứng dụng thế nào?", "en": "How do you rate the app?", "ja": "アプリをどのように評価しますか？", "ko": "앱을 어떻게 평가하시나요?", "zh": "您如何评价此应用？", "th": "คุณให้คะแนนแอปนี้อย่างไร?"],
            "feedback_topic_label": ["vi": "CHỦ ĐỀ", "en": "TOPIC", "ja": "トピック", "ko": "주제", "zh": "主题", "th": "หัวข้อ"],
            "feedback_placeholder": ["vi": "Bạn có góp ý gì cho LuminaCards không? Hãy chia sẻ tại đây nhé...", "en": "Do you have any feedback for LuminaCards? Share it here...", "ja": "LuminaCardsへのフィードバックはありますか？こちらで共有してください...", "ko": "LuminaCards에 대한 피드백이 있나요? 여기서 공유해 주세요...", "zh": "您对 LuminaCards 有什么建议吗？请在此分享...", "th": "คุณมีข้อเสนอแนะสำหรับ LuminaCards ไหม? แบ่งปันได้ที่นี่เลย..."],
            "feedback_submit": ["vi": "Gửi phản hồi", "en": "Submit Feedback", "ja": "フィードバックを送信", "ko": "피드백 제출", "zh": "提交反馈", "th": "ส่งข้อเสนอแนะ"],
            "feedback_thanks": ["vi": "Cảm ơn bạn!", "en": "Thank you!", "ja": "ありがとうございます！", "ko": "감사합니다!", "zh": "谢谢！", "th": "ขอบคุณ!"],
            "feedback_success_msg": ["vi": "LuminaCards đã nhận được góp ý của bạn. Chúng mình sẽ sớm phản hồi qua email nếu cần thiết.", "en": "LuminaCards has received your feedback. We'll respond via email if necessary.", "ja": "LuminaCardsはフィードバックを受け取りました。必要に応じてメールで返信いたします。", "ko": "LuminaCards가 피드백을 받았습니다. 필요한 경우 이메일을 통해 답변해 드리겠습니다.", "zh": "LuminaCards 已收到您的反馈。如有必要，我们将通过电子邮件回复。", "th": "LuminaCards ได้รับข้อเสนอแนะของคุณแล้ว เราจะตอบกลับทางอีเมลหากจำเป็น"],
            "feedback_title": ["vi": "Phản hồi", "en": "Feedback", "ja": "フィードバック", "ko": "피드백", "zh": "反馈", "th": "ข้อเสนอแนะ"],
            "settings_language_desc": ["vi": "Chọn ngôn ngữ hiển thị phù hợp với bạn.", "en": "Choose the language that fits you best.", "ja": "最適な表示言語を選択してください。", "ko": "본인에게 가장 적합한 표시 언어를 선택하세요.", "zh": "选择最适合您的显示语言。", "th": "เลือกภาษาที่แสดงที่เหมาะกับคุณที่สุด"],
            
            "quick_double_tap": ["vi": "Chạm đúp để lật", "en": "Double Tap to Flip", "ja": "ダブルタップで裏返す", "ko": "두 번 탭하여 뒤집기", "zh": "双击翻转", "th": "แตะสองครั้งเพื่อพลิก"],
            "quick_double_tap_desc": ["vi": "Lật thẻ nhanh bằng cách chạm 2 lần", "en": "Quickly flip cards by double-tapping", "ja": "2回タップして素早くカードを裏返します", "ko": "두 번 탭하여 카드를 빠르게 뒤집습니다", "zh": "双击即可快速翻转卡片", "th": "พลิกการ์ดอย่างรวดเร็วโดยการแตะ 2 ครั้ง"],
            "quick_swipe": ["vi": "Vuốt để chuyển thẻ", "en": "Swipe to Navigate", "ja": "スワイプで移動", "ko": "스와이프하여 탐색", "zh": "滑动导航", "th": "ปัดเพื่อนำทาง"],
            "quick_swipe_desc": ["vi": "Sử dụng cử chỉ vuốt để học", "en": "Use swipe gestures to study", "ja": "スワイプジェスチャーを使用して学習します", "ko": "스와이프 제스처를 사용하여 학습", "zh": "使用滑动手势进行学习", "th": "ใช้ท่าทางการปัดเพื่อเรียนรู้"],
            "quick_haptic": ["vi": "Phản hồi rung", "en": "Haptic Feedback", "ja": "触覚フィードバック", "ko": "햅틱 피드백", "zh": "触感反馈", "th": "การตอบสนองแบบสัมผัส"],
            "quick_haptic_desc": ["vi": "Rung nhẹ khi thực hiện hành động", "en": "Light vibration on actions", "ja": "操作時に軽く振動します", "ko": "동작 시 가벼운 진동", "zh": "操作时轻微震动", "th": "สั่นเบาๆ เมื่อทำรายการ"],
            "quick_shake": ["vi": "Lắc để báo lỗi", "en": "Shake to Report", "ja": "シェイクで報告", "ko": "흔들어서 보고", "zh": "摇一摇报告", "th": "เขย่าเพื่อรายงาน"],
            "quick_shake_desc": ["vi": "Lắc thiết bị khi gặp lỗi nội dung", "en": "Shake device to report content errors", "ja": "コンテンツのエラーを報告するにはデバイスをシェイクしてください", "ko": "콘텐츠 오류를 보고하려면 기기를 흔드세요", "zh": "摇动设备以报告内容错误", "th": "เขย่าอุปกรณ์เพื่อรายงานข้อผิดพลาดของเนื้อหา"],
            "quick_header_desc": ["vi": "Tối ưu hóa thao tác học tập của bạn", "en": "Optimize your learning interactions", "ja": "学習のやり取りを最適化する", "ko": "학습 상호 작용 최적화", "zh": "优化您的学习交互", "th": "เพิ่มประสิทธิภาพการโต้ตอบการเรียนรู้ของคุณ"],
            "quick_info_text": ["vi": "Các cài đặt này giúp bạn tương tác với Lumina nhanh và tự nhiên hơn trong quá trình học tập.", "en": "These settings help you interact with Lumina faster and more naturally while studying.", "ja": "これらの設定により、学習中にLuminaとより速く自然にやり取りできるようになります。", "ko": "이러한 설정은 학습하는 동안 Lumina와 더 빠르고 자연스럽게 상호 작용하는 데 도움이 됩니다.", "zh": "这些设置可帮助您在学习时更快速、更自然地与 Lumina 互动。", "th": "การตั้งค่าเหล่านี้ช่วยให้คุณโต้ตอบกับ Lumina ได้รวดเร็วและเป็นธรรมชาติยิ่งขึ้นขณะเรียน"],
            "common_advanced": ["vi": "Nâng cao", "en": "Advanced", "ja": "詳細設定", "ko": "고급", "zh": "高级", "th": "ขั้นสูง"],
            
            "info_privacy_title": ["vi": "Quyền riêng tư", "en": "Privacy Policy", "ja": "プライバシーポリシー", "ko": "개인정보 처리방침", "zh": "隐私政策", "th": "นโยบายความเป็นส่วนตัว"],
            "info_privacy_content": [
                "vi": "LuminaCards cam kết bảo vệ quyền riêng tư của bạn một cách tuyệt đối. Chúng tôi hiểu rằng dữ liệu học tập và thông tin cá nhân của bạn là vô cùng quý giá.\n\n1. Thu thập dữ liệu: Chúng tôi chỉ thu thập các thông tin cần thiết như tên, email và tiến trình học tập để cung cấp trải nghiệm học tập cá nhân hóa.\n\n2. Sử dụng thông tin: Dữ liệu của bạn được sử dụng để đồng bộ hóa học phần trên các thiết bị, đề xuất lộ trình ôn tập dựa trên thuật toán SRS và cải thiện chất lượng ứng dụng.\n\n3. Chia sẻ với bên thứ ba: Chúng tôi KHÔNG BAO GIỜ bán dữ liệu của bạn cho bất kỳ bên thứ ba nào.\n\n4. Bảo mật: Mọi thông tin đều được mã hóa bằng công nghệ SSL/TLS hiện đại nhất.",
                "en": "LuminaCards is committed to protecting your privacy. We understand that your learning data and personal information are precious.\n\n1. Data Collection: We only collect necessary information such as name, email, and learning progress to provide a personalized experience.\n\n2. Information Usage: Your data is used to sync decks across devices, suggest review schedules based on SRS algorithms, and improve app quality.\n\n3. Third-party Sharing: We NEVER sell your data to any third party.\n\n4. Security: All information is encrypted using state-of-the-art SSL/TLS technology.",
                "ja": "LuminaCardsはプライバシー保護に全力で取り組んでいます。学習データや個人情報は非常に重要であると認識しています。\n\n1. データ収集：パーソナライズされた学習体験を提供するため、氏名、メールアドレス、学習進捗などの必要な情報のみを収集します。\n\n2. 情報の使用：データはデバイス間での共有、SRSアルゴリズムに基づく復習スケジュールの提案、アプリの品質向上に使用されます。\n\n3. 第三者との共有：お客様のデータを第三者に販売することは決してありません。\n\n4. セキュリティ：すべての情報は最新のSSL/TLS技術を使用して暗号化されています。",
                "ko": "LuminaCards는 귀하의 개인정보를 보호하기 위해 최선을 다하고 있습니다. 귀하의 학습 데이터와 개인 정보가 소중하다는 것을 잘 알고 있습니다.\n\n1. 데이터 수집: 개인화된 학습 경험을 제공하기 위해 이름, 이메일, 학습 진행 상황과 같은 필요한 정보만 수집합니다.\n\n2. 정보 사용: 귀하의 데이터는 장치 간 세트 동기화, SRS 알고리즘에 기반한 복습 일정 제안 및 앱 품질 개선에 사용됩니다.\n\n3. 제3자 공유: 저희는 귀하의 데이터를 제3자에게 절대 판매하지 않습니다.\n\n4. 보안: 모든 정보는 최신 SSL/TLS 기술을 사용하여 암호화됩니다.",
                "zh": "LuminaCards 致力于保护您的隐私。我们深知您的学习数据和个人信息弥足珍贵。\n\n1. 数据收集：我们仅收集姓名、电子邮件和学习进度等必要信息，以提供个性化的学习体验。\n\n2. 信息使用：您的数据用于跨设备同步学习集、根据 SRS 算法建议复习计划以及提高应用质量。\n\n3. 第三方共享：我们绝不会将您的数据出售给任何第三方。\n\n4. 安全性：所有信息均使用最先进的 SSL/TLS 技术进行加密。",
                "th": "LuminaCards มุ่งมั่นที่จะปกป้องความเป็นส่วนตัวของคุณ เราเข้าใจดีว่าข้อมูลการเรียนรู้และข้อมูลส่วนบุคคลของคุณมีค่าอย่างยิ่ง\n\n1. การเก็บรวบรวมข้อมูล: เราเก็บรวบรวมเฉพาะข้อมูลที่จำเป็น เช่น ชื่อ อีเมล และความคืบหน้าในการเรียนรู้ เพื่อมอบประสบการณ์การเรียนรู้ที่ปรับตามบุคคล\n\n2. การใช้ข้อมูล: ข้อมูลของคุณจะถูกใช้เพื่อซิงค์ชุดการเรียนรู้ข้ามอุปกรณ์ แนะนำตารางการทบทวนตามอัลกอริทึม SRS และปรับปรุงคุณภาพของแอป\n\n3. การแบ่งปันกับบุคคลที่สาม: เราจะไม่ขายข้อมูลของคุณให้กับบุคคลที่สามอย่างแน่นอน\n\n4. ความปลอดภัย: ข้อมูลทั้งหมดถูกเข้ารหัสโดยใช้เทคโนโลยี SSL/TLS ล่าสุด"
            ],
            "info_terms_title": ["vi": "Điều khoản sử dụng", "en": "Terms of Service", "ja": "利用規約", "ko": "이용약관", "zh": "服务条款", "th": "ข้อกำหนดการใช้งาน"],
            "info_terms_content": [
                "vi": "Bằng việc sử dụng LuminaCards, bạn đồng ý tuân thủ các điều khoản sau đây:\n\n1. Chấp nhận điều khoản: Bạn phải tuân thủ mọi quy định và chính sách được nêu trong văn bản này.\n\n2. Tài khoản người dùng: Bạn chịu trách nhiệm bảo mật mật khẩu và mọi hoạt động dưới tài khoản của mình.\n\n3. Nội dung người dùng: Bạn sở hữu các học phần bạn tạo ra, nhưng cấp cho chúng tôi quyền hiển thị chúng nếu bạn đặt ở chế độ công khai.\n\n4. Gói đăng ký: Các thanh toán cho gói Lumina Plus được thực hiện qua Apple ID. Việc hủy gói cần được thực hiện ít nhất 24 giờ trước ngày gia hạn.",
                "en": "By using LuminaCards, you agree to comply with the following terms:\n\n1. Acceptance of Terms: You must comply with all regulations and policies outlined in this document.\n\n2. User Account: You are responsible for maintaining the security of your password and all activities under your account.\n\n3. User Content: You own the decks you create, but grant us the right to display them if set to public.\n\n4. Subscriptions: Payments for Lumina Plus are made via Apple ID. Cancellations must be made at least 24 hours before the renewal date.",
                "ja": "LuminaCardsを使用することにより、以下の条件に同意したものとみなされます。\n\n1. 規約の承諾：この文書に記載されているすべての規定およびポリシーを遵守する必要があります。\n\n2. ユーザーアカウント：パスワードのセキュリティおよびアカウント下でのすべての活動についてはユーザーが責任を負います。\n\n3. ユーザーコンテンツ：作成した学習セットはユーザーに帰属しますが、公開設定にした場合は弊社に表示権限を付与するものとします。\n\n4. サブスクリプション：Lumina Plusの支払いはApple ID経由で行われます。解約は更新日の24時間前までに行う必要があります。",
                "ko": "LuminaCards를 사용함으로써 다음 약관을 준수하는 데 동의하게 됩니다.\n\n1. 약관 수락: 이 문서에 명시된 모든 규정 및 정책을 준수해야 합니다.\n\n2. 사용자 계정: 비밀번호의 보안 및 귀하의 계정에서 발생하는 모든 활동에 대한 책임은 귀하에게 있습니다.\n\n3. 사용자 콘텐츠: 귀하가 생성한 세트의 소유권은 귀하에게 있지만, 공개로 설정할 경우 저희에게 표시할 권리를 부여합니다.\n\n4. 구독: Lumina Plus 구독 결제는 Apple ID를 통해 이루어집니다. 취소는 갱신일 최소 24시간 전에 이루어져야 합니다.",
                "zh": "通过使用 LuminaCards，您同意遵守以下条款：\n\n1. 接受条款：您必须遵守本文档中列出的所有法规和政策。\n\n2. 用户帐户：您负责维护密码安全，并对自己帐户下的所有活动负责。\n\n3. 用户内容：您拥有自己创建的学习集，但如果设置为公开，则授予我们显示的权利。\n\n4. 订阅：Lumina Plus 的付款通过 Apple ID 进行。取消必须在续订日期前至少 24 小时进行。",
                "th": "โดยการใช้ LuminaCards คุณตกลงที่จะปฏิบัติตามข้อกำหนดดังต่อไปนี้:\n\n1. การยอมรับข้อกำหนด: คุณต้องปฏิบัติตามกฎระเบียบและนโยบายทั้งหมดที่ระบุไว้ในเอกสารนี้\n\n2. บัญชีผู้ใช้: คุณมีหน้าที่รับผิดชอบในการรักษาความปลอดภัยของรหัสผ่านและกิจกรรมทั้งหมดภายใต้บัญชีของคุณ\n\n3. เนื้อหาของผู้ใช้: คุณเป็นเจ้าของชุดการเรียนรู้ที่คุณสร้างขึ้น แต่ให้สิทธิ์เราในการแสดงเนื้อหาเหล่านั้นหากตั้งค่าเป็นสาธารณะ\n\n4. การสมัครสมาชิก: การชำระเงินสำหรับ Lumina Plus จะทำผ่าน Apple ID การยกเลิกต้องทำอย่างน้อย 24 ชั่วโมงก่อนวันต่ออายุ"
            ],
            "info_about_title": ["vi": "Giới thiệu LuminaCards", "en": "About LuminaCards", "ja": "LuminaCardsについて", "ko": "LuminaCards 정보", "zh": "关于 LuminaCards", "th": "เกี่ยวกับ LuminaCards"],
            "info_about_content": [
                "vi": "LuminaCards được ra đời với sứ mệnh mang lại trải nghiệm học tập ngoại ngữ và kiến thức hiệu quả nhất cho thế hệ Gen Z.\n\nKết hợp giữa thiết kế hiện đại và các phương pháp khoa học nã bộ như Lặp lại ngắt quãng (SRS), chúng tôi tin rằng ai cũng có thể làm chủ kiến thức một cách dễ dàng.\n\nPhiên bản: 2.0.4\n© 2024 Lumina Team",
                "en": "LuminaCards was created with the mission to provide the most effective language and knowledge learning experience for Gen Z.\n\nCombining modern design with brain science methods like Spaced Repetition System (SRS), we believe anyone can master knowledge easily.\n\nVersion: 2.0.4\n© 2024 Lumina Team",
                "ja": "LuminaCardsは、Z世代に最も効果的な語学および知識学習体験を提供することを使命として誕生しました。\n\nモダンなデザインと、分散学習システム（SRS）などの脳科学の手法を組み合わせることで、誰でも簡単に知識を習得できると信じています。\n\nバージョン：2.0.4\n© 2024 Lumina Team",
                "ko": "LuminaCards는 Z세대에게 가장 효과적인 언어 및 지식 학습 경험을 제공한다는 사명으로 탄생했습니다.\n\n현대적인 디자인과 간격 반복 시스템(SRS)과 같은 뇌 과학적 방법을 결합하여, 누구나 지식을 쉽게 습득할 수 있다고 믿습니다.\n\n버전: 2.0.4\n© 2024 Lumina Team",
                "zh": "LuminaCards 的使命是为 Gen Z 提供最有效的语言和知识学习体验。\n\n结合现代设计与间隔重复系统 (SRS) 等脑科学方法，我们相信任何人都能轻松掌握知识。\n\n版本：2.0.4\n© 2024 Lumina Team",
                "th": "LuminaCards ถูกสร้างขึ้นด้วยภารกิจเพื่อมอบประสบการณ์การเรียนรู้ภาษาและความรู้ที่มีประสิทธิภาพที่สุดสำหรับ Gen Z\n\nด้วยการผสมผสานระหว่างการออกแบบที่ทันสมัยและวิธีการทางวิทยาศาสตร์ทางสมอง เช่น ระบบการทำซ้ำแบบเว้นระยะ (SRS) เราเชื่อว่าทุกคนสามารถเป็นเจ้าของความรู้ได้อย่างง่ายดาย\n\nเวอร์ชัน: 2.0.4\n© 2024 Lumina Team"
            ],
            
            // MARK: - Deck Detail View
            "deck_due": ["vi": "Đến hạn", "en": "Due", "ja": "期限", "ko": "만료됨", "zh": "到期", "th": "ครบกำหนด"],
            "deck_due_cards": ["vi": "%d thẻ đến hạn", "en": "%d cards due", "ja": "%d 枚のカードが期限", "ko": "%d 개의 카드 만료", "zh": "%d 张卡片到期", "th": "%d การ์ดครบกำหนด"],
            "deck_study_this": ["vi": "Học bộ học phần này", "en": "Study this deck", "ja": "このセットを学習", "ko": "이 세트 학습", "zh": "学习此学习集", "th": "เรียนชุดการเรียนนี้"],
            "deck_choose_mode": ["vi": "Chọn chế độ học", "en": "Select study mode", "ja": "学習モードを選択", "ko": "학습 모드 선택", "zh": "选择学习模式", "th": "เลือกโหมดการเรียน"],
            "deck_flashcards": ["vi": "Thẻ ghi nhớ", "en": "Flashcards", "ja": "単語カード", "ko": "플래시카드", "zh": "单词卡", "th": "แฟลชการ์ด"],
            "deck_quiz_mode": ["vi": "Chế độ kiểm tra", "en": "Quiz Mode", "ja": "テストモード", "ko": "테스트 모드", "zh": "测试模式", "th": "โหมดควิซ"],
            "deck_matching": ["vi": "Nối thẻ", "en": "Matching", "ja": "マッチング", "ko": "매칭", "zh": "配对", "th": "จับคู่"],
            "deck_blast": ["vi": "Chơi Blast", "en": "Play Blast", "ja": "ブラスト", "ko": "블래스트", "zh": "Blast 游戏", "th": "เล่น Blast"],
            "deck_block": ["vi": "Chơi Khối thẻ", "en": "Play Block", "ja": "ブロック", "ko": "블록", "zh": "方块游戏", "th": "เล่นบล็อก"],
            "deck_no_cards": ["vi": "Chưa có thẻ nào. Thêm thẻ ngay!", "en": "No cards yet. Add cards now!", "ja": "カードがありません。今すぐ追加！", "ko": "카드가 없습니다. 지금 추가하세요!", "zh": "暂无卡片。立即添加！", "th": "ยังไม่มีการ์ด เพิ่มการ์ดเลย!"],
            "deck_terms": ["vi": "thuật ngữ", "en": "terms", "ja": "用語", "ko": "용어", "zh": "个术语", "th": "คำศัพท์"],
            "deck_flashcard_desc": ["vi": "Học với chế độ lật và vuốt", "en": "Learn with flip and swipe mode", "ja": "フリップとスワイプで学習", "ko": "플립 및 스와이프 모드로 학습", "zh": "通过翻转和滑动模式学习", "th": "เรียนด้วยโหมดพลิกและปัด"],
            "deck_quiz_options": ["vi": "Lựa chọn câu hỏi ôn tập", "en": "Learning options", "ja": "学習オプション", "ko": "학습 옵션", "zh": "学习选项", "th": "ตัวเลือกการเรียน"],
            "deck_quiz_desc": ["vi": "Tùy chọn mục tiêu học tập", "en": "Custom learning objectives", "ja": "カスタム学習目標", "ko": "맞춤 학습 목표", "zh": "自定义学习目标", "th": "เป้าหมายการเรียนที่กำหนดเอง"],
            "deck_games_section": ["vi": "Trò chơi & Kỹ năng", "en": "Games & Skills", "ja": "ゲームとスキル", "ko": "게임 및 스킬", "zh": "游戏与技能", "th": "เกมและทักษะ"],
            "deck_matching_title": ["vi": "Ghi nhớ (Nối thẻ)", "en": "Memory (Matching)", "ja": "記憶（マッチング）", "ko": "기억력 (매칭)", "zh": "记忆（配对）", "th": "ความจำ (จับคู่)"],
            "deck_matching_desc": ["vi": "Kết nối 2 thẻ tương ứng", "en": "Connect corresponding cards", "ja": "対応するカードを接続", "ko": "해당 카드 연결", "zh": "连接对应的卡片", "th": "เชื่อมต่อการ์ดที่ตรงกัน"],
            "deck_blast_desc": ["vi": "Phá hủy các khối từ vựng", "en": "Blast through words", "ja": "単語を破壊", "ko": "단어 폭파", "zh": "爆破单词", "th": "ระเบิดคำศัพท์"],
            "deck_block_desc": ["vi": "Xây dựng tháp từ vựng", "en": "Build word towers", "ja": "単語タワーを構築", "ko": "단어 타워 쌓기", "zh": "建立单词塔", "th": "สร้างหอคอยคำศัพท์"],
            "deck_terms_in_set": ["vi": "Thuật ngữ trong học phần này (%d)", "en": "Terms in this set (%d)", "ja": "このセットの用語 (%d)", "ko": "이 세트의 용어 (%d)", "zh": "此学习集中的术语 (%d)", "th": "คำศัพท์ในชุดนี้ (%d)"],
            "deck_author": ["vi": "Người dùng", "en": "User", "ja": "ユーザー", "ko": "사용자", "zh": "用户", "th": "ผู้ใช้"],
            "deck_card_front": ["vi": "Hỏi", "en": "Question", "ja": "問題", "ko": "질문", "zh": "问题", "th": "คำถาม"],
            "deck_card_back": ["vi": "Trả lời", "en": "Answer", "ja": "答え", "ko": "정답", "zh": "答案", "th": "คำตอบ"],
            "deck_quiz_method": ["vi": "Lựa chọn phương pháp học", "en": "Choose learning method", "ja": "学習方法を選択", "ko": "학습 방식 선택", "zh": "选择学习方式", "th": "เลือกวิธีการเรียน"],
            "deck_quiz_cram": ["vi": "Nhồi nhét (Học cấp tốc)", "en": "Cram Mode", "ja": "詰め込みモード", "ko": "벼락치기 모드", "zh": "冲刺模式", "th": "โหมดเร่งด่วน"],
            "deck_quiz_cram_desc": ["vi": "Làm trắc nghiệm, đảo câu hỏi", "en": "Multiple choice, scrambled", "ja": "四択クイズ", "ko": "다지선다 퀴즈", "zh": "选择题模式", "th": "แบบเลือกตอบ"],
            "deck_quiz_longterm": ["vi": "Ghi nhớ lâu dài (SRS)", "en": "Long-term Memory (SRS)", "ja": "長期記憶（SRS）", "ko": "장기 기억 (SRS)", "zh": "长期记忆 (SRS)", "th": "ความจำระยะยาว (SRS)"],
            "deck_quiz_longterm_desc": ["vi": "Tự luận, viết nghĩa chính xác", "en": "Open-ended, precise definitions", "ja": "記述式、正確な定義", "ko": "주관식, 정확한 정의", "zh": "简答题模式", "th": "แบบเติมคำ"],
            
            "deck_options_title": ["vi": "Tùy chọn học phần", "en": "Deck Options", "ja": "オプション", "ko": "옵션", "zh": "选项", "th": "ตัวเลือก"],
            "deck_options_edit": ["vi": "Sửa học phần", "en": "Edit Deck", "ja": "編集", "ko": "편집", "zh": "编辑", "th": "แก้ไข"],
            "deck_options_add_to_class": ["vi": "Thêm vào lớp học", "en": "Add to Class", "ja": "クラスに追加", "ko": "クラスに追加", "zh": "添加到班级", "th": "เพิ่มในชั้นเรียน"],
            "deck_options_add_to_folder": ["vi": "Thêm vào thư mục", "en": "Add to Folder", "ja": "フォルダに追加", "ko": "폴더에 추가", "zh": "添加到文件夹", "th": "เพิ่มในโฟลเดอร์"],
            "deck_options_duplicate": ["vi": "Tạo một bản sao", "en": "Duplicate Deck", "ja": "セットを複製", "ko": "세트 복제", "zh": "复制学习集", "th": "ทำสำเนา"],
            "deck_options_share": ["vi": "Chia sẻ", "en": "Share", "ja": "共有", "ko": "공유", "zh": "分享", "th": "แชร์"],
            "deck_options_info": ["vi": "Thông tin học phần", "en": "Deck Info", "ja": "情報", "ko": "정보", "zh": "信息", "th": "ข้อมูล"],
            "deck_options_delete": ["vi": "Xóa học phần", "en": "Delete Deck", "ja": "セットを削除", "ko": "세트 삭제", "zh": "删除学习集", "th": "ลบชุดการเรียน"],
            
            // MARK: - Deck Management & Actions
            "deck_edit_title": ["vi": "Sửa học phần", "en": "Edit Deck", "ja": "編集", "ko": "편집", "zh": "编辑", "th": "แก้ไข"],
            "deck_edit_title_label": ["vi": "TIÊU ĐỀ", "en": "TITLE", "ja": "タイトル", "ko": "제목", "zh": "标题", "th": "หัวข้อ"],
            "deck_edit_title_ph": ["vi": "Nhập tiêu đề học phần...", "en": "Enter deck title...", "ja": "学びにセット名を入力...", "ko": "세트 제목 입력...", "zh": "输入学习集标题...", "th": "ใส่หัวข้อชุดการเรียน..."],
            "deck_edit_cards_label": ["vi": "THẺ TRONG HỌC PHẦN (%d)", "en": "CARDS IN SET (%d)", "ja": "セット内のカード (%d)", "ko": "세트 내 카드 (%d)", "zh": "学习集中的卡片 (%d)", "th": "การ์ดในชุด (%d)"],
            "deck_edit_add_card": ["vi": "Thêm thẻ", "en": "Add Card", "ja": "カードを追加", "ko": "카드 추가", "zh": "添加卡片", "th": "เพิ่มการ์ด"],
            "deck_edit_image": ["vi": "Ảnh", "en": "Image", "ja": "画像", "ko": "이미지", "zh": "图片", "th": "รูปภาพ"],
            "deck_create_name_label": ["vi": "TÊN HỌC PHẦN", "en": "DECK NAME", "ja": "セット名", "ko": "세트 이름", "zh": "学习集名称", "th": "ชื่อชุดการเรียน"],
            "deck_create_name_ph": ["vi": "VD: Từ vựng N5", "en": "e.g., N5 Vocabulary", "ja": "例: N5単語", "ko": "예: N5 어휘", "zh": "例如：N5 词汇", "th": "ตัวอย่าง: คำศัพท์ N5"],
            "deck_create_language_label": ["vi": "NGÔN NGỮ", "en": "LANGUAGE", "ja": "言語", "ko": "언어", "zh": "语言", "th": "ภาษา"],
            "deck_create_term_lang": ["vi": "Ngôn ngữ (Mặt trước)", "en": "Language (Front)", "ja": "言語 (表面)", "ko": "언어 (앞면)", "zh": "语言 (正面)", "th": "ภาษา (ด้านหน้า)"],
            "deck_create_def_lang": ["vi": "Ngôn ngữ (Mặt sau)", "en": "Language (Back)", "ja": "言語 (裏面)", "ko": "언어 (뒷면)", "zh": "语言 (反面)", "th": "ภาษา (ด้านหลัง)"],
            "deck_create_icon_label": ["vi": "BIỂU TƯỢNG", "en": "ICON", "ja": "アイコン", "ko": "아이콘", "zh": "图标", "th": "ไอคอน"],
            "deck_create_color_label": ["vi": "MÀU SẮC", "en": "COLOR", "ja": "色", "ko": "색상", "zh": "颜色", "th": "สี"],
            "deck_create_button": ["vi": "Tạo học phần", "en": "Create Deck", "ja": "セットを作成", "ko": "세트 생성", "zh": "创建学习集", "th": "สร้างชุดการเรียน"],
            "deck_create_preview": ["vi": "Xem trước", "en": "Preview", "ja": "プレビュー", "ko": "미리보기", "zh": "预览", "th": "ตัวอย่าง"],
            "deck_create_new_title": ["vi": "Học phần mới", "en": "New Deck", "ja": "新しいセット", "ko": "새 세트", "zh": "新学习集", "th": "ชุดการเรียนใหม่"],
            
            "deck_settings_title": ["vi": "Cài đặt học phần", "en": "Deck Settings", "ja": "セットの設定", "ko": "세트 설정", "zh": "学习集设置", "th": "ตั้งค่าชุดการเรียน"],
            
            // MARK: - Import Vocabulary
            "deck_import_title": ["vi": "Nhập từ vựng", "en": "Import Vocabulary", "ja": "用語のインポート", "ko": "용어 가져오기", "zh": "导入词汇", "th": "นำเข้าคำศัพท์"],
            "deck_import_text": ["vi": "Nhập văn bản", "en": "Text Import", "ja": "テキスト入力", "ko": "텍스트 입력", "zh": "文本导入", "th": "นำเข้าข้อความ"],
            "deck_import_file": ["vi": "Tải lên tệp", "en": "File Upload", "ja": "ファイルアップロード", "ko": "파일 업로드", "zh": "文件上传", "th": "อัปโหลดไฟล์"],
            "deck_import_image": ["vi": "Quét hình ảnh", "en": "Scan Image", "ja": "画像をスキャン", "ko": "이미지 스캔", "zh": "扫描图像", "th": "สแกนรูปภาพ"],
            "deck_import_text_ph": ["vi": "Nhập theo định dạng: Thuật ngữ - Định nghĩa (mỗi cặp một dòng)", "en": "Format: Term - Definition (one pair per line)", "ja": "形式: 用語 - 定義 (1行に1ペア)", "ko": "형식: 용어 - 정의 (한 줄에 한 쌍)", "zh": "格式：术语 - 定义（每行一个）", "th": "รูปแบบ: คำศัพท์ - คำจำกัดความ (หนึ่งคู่ต่อบรรทัด)"],
            "deck_import_image_desc": ["vi": "Sử dụng camera hoặc chọn ảnh để trích xuất văn bản", "en": "Use camera or photo library to extract text", "ja": "カメラまたは写真を使用してテキストを抽出します", "ko": "카메라 또는 사진을 사용하여 텍스트 추출", "zh": "使用相机或照片库提取文本", "th": "ใช้กล้องหรือไลบรารีรูปภาพเพื่อแยกข้อความ"],
            "deck_import_file_desc": ["vi": "Hỗ trợ file CSV hoặc tệp văn bản", "en": "Supports CSV or text files", "ja": "CSVまたはテキストファイルをサポート", "ko": "CSV 또는 텍스트 파일 지원", "zh": "支持 CSV 或文本文件", "th": "รองรับไฟล์ CSV หรือไฟล์ข้อความ"],
            "deck_import_confirm": ["vi": "Thêm %d thẻ", "en": "Add %d cards", "ja": "%d 枚のカードを追加", "ko": "카드 %d개 추가", "zh": "添加 %d 张卡片", "th": "เพิ่ม %d การ์ด"],
            "deck_import_format_guide": ["vi": "Hướng dẫn định dạng", "en": "Format Guide", "ja": "フォーマットガイド", "ko": "형식 가이드", "zh": "格式指南", "th": "คู่มือรูปแบบ"],
            "deck_import_format_desc": ["vi": "Mỗi dòng là một thẻ. Sử dụng ký tự phân cách để chia thuật ngữ và định nghĩa.", "en": "Each line is a card. Use a separator to split term and definition.", "ja": "各行はカードです。区切り文字を使用して用語と定義を分割します。", "ko": "각 줄은 카드입니다. 구분 기호를 사용하여 용어와 정의를 나눕니다.", "zh": "每一行是一张卡片。使用分隔符分隔术语和定义。", "th": "แต่ละบรรทัดคือการ์ด ใช้ตัวคั่นเพื่อแบ่งคำศัพท์ vàคำจำกัดความ"],
            "deck_import_separator_label": ["vi": "Ký tự phân cách:", "en": "Separator:", "ja": "구분 기호：", "ko": "구분 기호:", "zh": "分隔符：", "th": "ตัวคั่น:"],
            "deck_add_manual": ["vi": "Thêm thủ công", "en": "Manual Add", "ja": "手動追加", "ko": "수동 추가", "zh": "手动添加", "th": "เพิ่มด้วยตนเอง"],
            "deck_smart_import": ["vi": "Nhập thông minh", "en": "Smart Import", "ja": "スマートインポート", "ko": "스마트 임포트", "zh": "智能导入", "th": "นำเข้าอัจฉริยะ"],
            "deck_import_preview_label": ["vi": "Bản xem trước (%d thẻ)", "en": "Preview (%d cards)", "ja": "プレビュー (%d 枚)", "ko": "미리보기 (카드 %d개)", "zh": "预览 (%d 张卡片)", "th": "ตัวอย่าง (%d การ์ด)"],
            "deck_import_empty_warn": ["vi": "Chưa tìm thấy thẻ nào từ dữ liệu nhập.", "en": "No cards found from input data.", "ja": "入力データからカードが見つかりません。", "ko": "입력 데이터에서 카드를 찾을 수 없습니다.", "zh": "未从输入数据中找到卡片。", "th": "ไม่พบการ์ดจากข้อมูลที่นำเข้า"],
            "deck_settings_lang_section": ["vi": "NGÔN NGỮ", "en": "LANGUAGE", "ja": "言語", "ko": "언어", "zh": "语言", "th": "ภาษา"],
            "deck_settings_term_lang": ["vi": "Ngôn ngữ (Mặt trước)", "en": "Language (Front)", "ja": "言語 (表面)", "ko": "언어 (앞면)", "zh": "语言 (正面)", "th": "ภาษา (ด้านหน้า)"],
            "deck_settings_def_lang": ["vi": "Ngôn ngữ Định nghĩa", "en": "Definition Language", "ja": "定義の言語", "ko": "정의 언어", "zh": "定义语言", "th": "ภาษาของคำจำกัดความ"],
            "deck_settings_privacy_section": ["vi": "QUYỀN RIÊNG TƯ", "en": "PRIVACY", "ja": "プライバシー", "ko": "개인정보 보호", "zh": "隐私", "th": "ความเป็นส่วนตัว"],
            "deck_settings_who_can_view": ["vi": "Ai có thể xem?", "en": "Visible to", "ja": "閲覧可能な人", "ko": "볼 수 있는 사람", "zh": "谁可以看？", "th": "ใครเห็นได้บ้าง?"],
            "deck_settings_public": ["vi": "Mọi người", "en": "Everyone", "ja": "全員", "ko": "모든 사람", "zh": "所有人", "th": "ทุกคน"],
            "deck_settings_private": ["vi": "Chỉ mình tôi", "en": "Just me", "ja": "自分のみ", "ko": "나만", "zh": "仅限自己", "th": "เฉพาะฉัน"],
            "deck_settings_who_can_edit": ["vi": "Ai có thể sửa?", "en": "Editable by", "ja": "編集可能な人", "ko": "편집할 수 있는 사람", "zh": "谁可以编辑？", "th": "ใครแก้ไขได้บ้าง?"],
            
            "deck_add_to_class_title": ["vi": "Thêm vào lớp học", "en": "Add to Class", "ja": "クラスに追加", "ko": "클래스에 추가", "zh": "添加到班级", "th": "เพิ่มในชั้นเรียน"],
            "deck_add_to_class_empty": ["vi": "Chưa có lớp học nào", "en": "No classes yet", "ja": "クラスがありません", "ko": "클래스가 없습니다", "zh": "暂无班级", "th": "ยังไม่มีชั้นเรียน"],
            "deck_add_to_folder_title": ["vi": "Thêm vào thư mục", "en": "Add to Folder", "ja": "フォルダに追加", "ko": "폴더에 추가", "zh": "添加到文件夹", "th": "เพิ่มในโฟลเดอร์"],
            "deck_add_to_folder_empty": ["vi": "Chưa có thư mục nào", "en": "No folders yet", "ja": "フォルダがありません", "ko": "폴더가 없습니다", "zh": "暂无文件夹", "th": "ยังไม่มีโฟลเดอร์"],
            
            "deck_info_title": ["vi": "Thông tin học phần", "en": "Deck Info", "ja": "セットの情報", "ko": "세트 정보", "zh": "学习集信息", "th": "ข้อมูลชุดการเรียน"],
            "deck_info_created_at": ["vi": "Ngày tạo", "en": "Created on", "ja": "作成日", "ko": "생성일", "zh": "创建日期", "th": "วันที่สร้าง"],
            "deck_info_card_count": ["vi": "Số lượng thẻ", "en": "Card count", "ja": "カード数", "ko": "카드 수", "zh": "卡片数量", "th": "จำนวนการ์ด"],
            "deck_info_language": ["vi": "Ngôn ngữ", "en": "Language", "ja": "言語", "ko": "언어", "zh": "语言", "th": "ภาษา"],
            "deck_info_id": ["vi": "ID Học phần", "en": "Deck ID", "ja": "セットID", "ko": "세트 ID", "zh": "学习集 ID", "th": "ไอดีชุดการเรียน"],
            "deck_info_cards_unit": ["vi": "thẻ", "en": "cards", "ja": "個のカード", "ko": "개의 카드", "zh": "张卡片", "th": "การ์ด"],
            
            // MARK: - Quick Actions Screens
            "quick_review_empty_title": ["vi": "Tuyệt vời!", "en": "Excellent!", "ja": "素晴らしい！", "ko": "최고예요!", "zh": "棒极了！", "th": "ยอดเยี่ยม!"],
            "quick_review_empty_msg": ["vi": "Không có thẻ nào cần ôn hôm nay", "en": "No cards to review today", "ja": "今日復習するカードはありません", "ko": "오늘 복습할 카드가 없습니다", "zh": "今天没有需要复习的卡片", "th": "ไม่มีการ์ดที่ต้องทบทวนในวันนี้"],
            "quick_review_start": ["vi": "Bắt đầu ôn tập", "en": "Start Review", "ja": "復習を開始", "ko": "복습 시작", "zh": "开始复习", "th": "เริ่มทบทวน"],
            "quick_learn_empty_title": ["vi": "Chưa có thẻ mới", "en": "No new cards", "ja": "新しいカードはありません", "ko": "새 카드가 없습니다", "zh": "没有新卡片", "th": "ยังไม่มีการ์ดใหม่"],
            "quick_learn_empty_msg": ["vi": "Thêm từ vựng mới vào bộ thẻ", "en": "Add new words to your deck", "ja": "新しい単語をセットに追加してください", "ko": "세트에 새로운 단어를 추가하세요", "zh": "将新单词添加到学习集中", "th": "เพิ่มคำศัพท์ใหม่ลงในชุดการเรียน"],
            "quick_learn_start": ["vi": "Bắt đầu học", "en": "Start Learning", "ja": "学習を開始", "ko": "학습 시작", "zh": "开始学习", "th": "เริ่มเรียน"],
            "quick_quiz_desc": ["vi": "Chọn bộ thẻ để kiểm tra kiến thức", "en": "Select a deck to test your knowledge", "ja": "ナレッジテストのセットを選択", "ko": "지식 테스트를 위한 세트를 선택하세요", "zh": "选择一个学习集来测试您的知识", "th": "เลือกชุดการเรียนเพื่อทดสอบความรู้"],
            
            // MARK: - Library & Classes
            "lib_browser_access": ["vi": "Truy cập các bài kiểm tra trên trình duyệt.", "en": "Access tests via your web browser.", "ja": "ブラウザからテストにアクセスします。", "ko": "웹 브라우저를 통해 테스트에 접속합니다.", "zh": "通过 Web 浏览器访问测试。", "th": "เข้าถึงการทดสอบผ่านเว็บเบราว์เซอร์ของคุณ"],
            "lib_open_browser": ["vi": "Mở trình duyệt", "en": "Open Browser", "ja": "ブラウザを開く", "ko": "브라우저 열기", "zh": "打开浏览器", "th": "เปิดเบราว์เซอร์"],
            "lib_create_class": ["vi": "Tạo lớp học", "en": "Create Class", "ja": "クラスを作成", "ko": "클래스 생성", "zh": "创建班级", "th": "สร้างชั้นเรียน"],
            "lib_join_with_code": ["vi": "Tham gia bằng mã", "en": "Join with code", "ja": "コードで参加", "ko": "코드로 참여", "zh": "使用代码加入", "th": "เข้าร่วมด้วยรหัส"],
            "class_create_new_title": ["vi": "Lớp học mới", "en": "New Class", "ja": "新しいクラス", "ko": "새 클래스", "zh": "新班级", "th": "ชั้นเรียนใหม่"],
            "class_create_name_label": ["vi": "TÊN LỚP HỌC", "en": "CLASS NAME", "ja": "クラス名", "ko": "클래스 이름", "zh": "班级名称", "th": "ชื่อชั้นเรียน"],
            "class_create_name_ph": ["vi": "VD: Lớp 12A1 - Toán nâng cao", "en": "e.g., Math Advanced", "ja": "例: 数学アドバンス", "ko": "예: 심화 수학", "zh": "例如：高级数学", "th": "ตัวอย่าง: คณิตศาสตร์ขั้นสูง"],
            "class_create_teacher_label": ["vi": "TÊN GIÁO VIÊN", "en": "TEACHER NAME", "ja": "教師名", "ko": "교사 이름", "zh": "教师姓名", "th": "ชื่ออาจารย์"],
            "class_create_teacher_ph": ["vi": "VD: Thầy Nguyễn Văn A", "en": "e.g., Mr. Smith", "ja": "例: スミス先生", "ko": "예: 스미스 선생님", "zh": "例如：史密斯先生", "th": "ตัวอย่าง: อาจารย์สมชาย"],
            "class_create_auto_code_msg": ["vi": "Mã lớp sẽ được hệ thống tạo tự động để học sinh tham gia sau khi hoàn thành.", "en": "Class code will be auto-generated for students to join after completion.", "ja": "完了後、学生が参加するためのクラスコードが自動生成されます。", "ko": "완료 후 학생들이 참여할 수 있는 클래스 코드가 자동 생성됩니다.", "zh": "班级代码将在完成后自动生成，供学生加入。", "th": "รหัสชั้นเรียนจะถูกสร้างขึ้นโดยอัตโนมัติเพื่อให้โปรแกรมนักเรียนเข้าร่วม"],
            "class_create_button": ["vi": "Tạo lớp học", "en": "Create Class", "ja": "クラスを作成", "ko": "클래스 생성", "zh": "创建班级", "th": "สร้างชั้นเรียน"],
            "member_joined_since": ["vi": "Tham gia từ %@", "en": "Joined since %@", "ja": "%@から参加", "ko": "%@부터 가입됨", "zh": "自%@起加入", "th": "เข้าร่วมตั้งแต่ %@"],
            "member_shared_decks": ["vi": "Học phần đã đăng", "en": "Shared Decks", "ja": "共有セット", "ko": "공유된 세트", "zh": "共享的学习集", "th": "ชุดการเรียนที่แบ่งปัน"],
            "folder_create_new_title": ["vi": "Thư mục mới", "en": "New Folder", "ja": "新しいフォルダ", "ko": "새 폴더", "zh": "新文件夹", "th": "โฟลเดอร์ใหม่"],
            "folder_create_name_label": ["vi": "TÊN THƯ MỤC", "en": "FOLDER NAME", "ja": "フォルダ名", "ko": "폴더 이름", "zh": "文件夹名称", "th": "ชื่อโฟลเดอร์"],
            "folder_create_name_ph": ["vi": "VD: Học kỳ 1", "en": "e.g., Semester 1", "ja": "例: 第1学期", "ko": "예: 1학기", "zh": "例如：第一学期", "th": "ตัวอย่าง: ภาคเรียนที่ 1"],
            "folder_create_button": ["vi": "Tạo thư mục", "en": "Create Folder", "ja": "フォルダを作成", "ko": "폴더 생성", "zh": "创建文件夹", "th": "สร้างโฟลเดอร์"],
            "folder_create_preview_ph": ["vi": "Tên thư mục", "en": "Folder Name", "ja": "フォルダ名", "ko": "폴더 이름", "zh": "文件夹名称", "th": "ชื่อโฟลเดอร์"],
            "deck_add_card": ["vi": "Thêm thẻ mới", "en": "Add new card", "ja": "カードを追加", "ko": "카드 추가", "zh": "添加卡片", "th": "เพิ่มการ์ด"],
            
            "folder_subfolders_title": ["vi": "Thư mục con", "en": "Subfolders", "ja": "サブフォルダ", "ko": "하위 폴더", "zh": "子文件夹", "th": "โฟลเดอร์ย่อย"],
            "folder_empty_msg": ["vi": "Chưa có học phần nào trong thư mục này", "en": "No decks in this folder yet", "ja": "このフォルダにはセットがありません", "ko": "이 폴더에는 세트がありません", "zh": "此文件夹中暂无个学习集", "th": "ยังไม่มีชุดการเรียนในโฟลเดอร์นี้"],
            "folder_empty_title": ["vi": "Thư mục trống", "en": "Empty Folder", "ja": "空のフォルダ", "ko": "빈 폴더", "zh": "空文件夹", "th": "โฟลเดอร์ว่าง"],
            "folder_add_to": ["vi": "Thêm vào %@", "en": "Add to %@", "ja": "%@に追加", "ko": "%@に追加", "zh": "添加到 %@", "th": "เพิ่มใน %@"],
            "folder_new_deck": ["vi": "Học phần mới", "en": "New Deck", "ja": "新しいセット", "ko": "새 세트", "zh": "新学习集", "th": "ชุดการเรียนใหม่"],
            "folder_new_subfolder": ["vi": "Thư mục con mới", "en": "New Subfolder", "ja": "新しいサブフォルダ", "ko": "새 하위 폴더", "zh": "新子文件夹", "th": "โฟลเดอร์ย่อยใหม่"],
            
            "class_detail_title": ["vi": "Chi tiết lớp học", "en": "Class Details", "ja": "クラスの詳細", "ko": "클래스 상세", "zh": "班级详情", "th": "รายละเอียดชั้นเรียน"],
            "class_code_label": ["vi": "Mã: %@", "en": "Code: %@", "ja": "コード: %@", "ko": "コード: %@", "zh": "代码: %@", "th": "รหัส: %@"],
            "class_decks_title": ["vi": "Học phần trong lớp", "en": "Class Decks", "ja": "クラスのセット", "ko": "클래스 세트", "zh": "班级学习集", "th": "ชุดการเรียนในชั้นเรียน"],
            "class_members_title": ["vi": "Thành viên (%d)", "en": "Members (%d)", "ja": "メンバー (%d)", "ko": "멤버 (%d)", "zh": "成员 (%d)", "th": "สมาชิก (%d)"],
            "class_no_decks": ["vi": "Chưa có học phần nào được chia sẻ trong lớp này.", "en": "No decks shared in this class yet.", "ja": "このクラスには共有されたセットがありません。", "ko": "이 클래스에는 공유된 세트가 없습니다.", "zh": "此班级中暂无共享的学习集。", "th": "ยังไม่มีชุดการเรียนที่แชร์ในชั้นเรียนนี้"],
            "class_role_teacher": ["vi": "Giáo viên", "en": "Teacher", "ja": "教師", "ko": "교사", "zh": "教师", "th": "อาจารย์"],
            "class_role_student": ["vi": "Học sinh", "en": "Student", "ja": "学生", "ko": "학생", "zh": "学生", "th": "นักเรียน"],
            
            // MARK: - Study Session
            "study_empty_msg": ["vi": "Không có thẻ nào!", "en": "No cards available!", "ja": "カードがありません！", "ko": "카드가 없습니다!", "zh": "没有卡片！", "th": "ไม่มีการ์ด!"],
            "study_session_complete": ["vi": "Hoàn thành buổi học!", "en": "Study session complete!", "ja": "学習セッション完了！", "ko": "학습 세션 완료!", "zh": "学习阶段完成！", "th": "จบเซสชันการเรียนแล้ว!"],
            "study_complete_msg": ["vi": "Bạn đã hoàn thành xuất sắc các thẻ cần ôn hôm nay.", "en": "You've successfully completed all due cards for today.", "ja": "今日の復習カードをすべて完了しました。", "ko": "오늘의 복습 카드를 모두 완료했습니다.", "zh": "您已成功完成今天的复习任务。", "th": "คุณทบทวนการ์ดที่ต้องทำในวันนี้เสร็จเรียบร้อยแล้ว"],
            "study_restart": ["vi": "Học lại từ đầu", "en": "Restart from beginning", "ja": "最初からやり直す", "ko": "처음부터 다시 시작", "zh": "重新开始", "th": "เริ่มใหม่ตั้งแต่ต้น"],
            "study_challenge": ["vi": "Thách đấu bạn bè", "en": "Challenge Friends", "ja": "友達に挑戦", "ko": "친구에게 도전", "zh": "挑战朋友", "th": "ท้าทายเพื่อน"],
            "study_back_home": ["vi": "Quay về Trang chủ", "en": "Back to Home", "ja": "ホームに戻る", "ko": "홈으로 돌아가기", "zh": "返回首页", "th": "กลับหน้าแรก"],
            "study_again": ["vi": "Quên", "en": "Again", "ja": "もう一度", "ko": "다시", "zh": "再次", "th": "อีกครั้ง"],
            "study_hard": ["vi": "Khó", "en": "Hard", "ja": "難しい", "ko": "어려움", "zh": "困难", "th": "ยาก"],
            "study_good": ["vi": "Dễ", "en": "Good", "ja": "普通", "ko": "좋음", "zh": "良好", "th": "ดี"],
            "study_easy": ["vi": "Rất dễ", "en": "Easy", "ja": "簡単", "ko": "쉬움", "zh": "简单", "th": "ง่ายมาก"],
            "study_tap_to_flip": ["vi": "Chạm để lật", "en": "Tap to flip", "ja": "タップして裏返す", "ko": "탭하여 뒤집기", "zh": "点击翻转", "th": "แตะเพื่อพลิก"],
            "study_share_msg": ["vi": "Tôi vừa hoàn thành việc ôn tập học phần '%@' trên LuminaCards! 📚✨ Cùng học với tôi nhé!\nTải app ngay!", "en": "I just finished reviewing '%@' on LuminaCards! 📚✨ Join me in studying!\nDownload the app now!", "ja": "LuminaCardsでセット「%@」を復習しました！ 📚✨ 一緒に勉強しましょう！\nアプリをダウンロード！", "ko": "LuminaCards에서 '%@' 세트를 복습했습니다! 📚✨ 함께 공부해요!\n앱을 다운로드하세요!", "zh": "我刚刚在 LuminaCards 上复习了 '%@'！ 📚✨ 一起学习吧！\n立即下载应用！", "th": "ฉันเพิ่งทบทวนชุดการเรียน '%@' บน LuminaCards เสร็จ! 📚✨ มาเรียนด้วยกันนะ!\nดาวน์โหลดแอปเลย!"],
            
            // MARK: - Block Game
            "game_block_title": ["vi": "Xây Tháp Từ Vựng", "en": "Vocab Tower", "ja": "単語タワー建設", "ko": "단어 타워 건설", "zh": "词汇塔建设", "th": "สร้างหอคอยคำศัพท์"],
            "game_block_intro1": ["vi": "Chọn định nghĩa chính xác để thêm tầng cho tháp.", "en": "Select correct definitions to add floors to your tower.", "ja": "正しい定義を選択してタワーに階層を追加します。", "ko": "올바른 정의를 선택하여 타워에 층을 추가하세요.", "zh": "选择正确的定义以为塔增加楼层。", "th": "เลือกคำจำกัดความที่ถูกต้องเพื่อเพิ่มชั้นให้กับหอคอย"],
            "game_block_intro2": ["vi": "Mỗi câu trả lời sai sẽ làm tháp lung lay và sụp đổ.", "en": "Wrong answers make the tower unstable and collapse.", "ja": "間違った回答をするとタワーが不安定になり、倒壊します。", "ko": "오답을 선택하면 타워가 흔들리고 무너집니다.", "zh": "错误的答案会使塔变得不稳定并坍塌。", "th": "คำตอบที่ผิดจะทำให้หอคอยสั่นคลอนและพังทลาย"],
            "game_block_intro3": ["vi": "Cố gắng xây tháp cao nhất có thể!", "en": "Try to build the tallest tower possible!", "ja": "できるだけ高いタワーを建てましょう！", "ko": "가능한 한 높은 타워를 건설해 보세요!", "zh": "尝试建造尽可能高的塔！", "th": "พยายามสร้างหอคอยให้สูงที่สุดเท่าที่จะทำได้!"],
            "game_block_start": ["vi": "Bắt đầu xây dựng", "en": "Start Building", "ja": "建設を開始", "ko": "건설 시작", "zh": "开始建造", "th": "เริ่มก่อสร้าง"],
            "game_height": ["vi": "CHIỀU CAO", "en": "HEIGHT", "ja": "高さ", "ko": "높이", "zh": "高度", "th": "ความสูง"],
            "game_floors": ["vi": "%d Tầng", "en": "%d Floors", "ja": "%d 階", "ko": "%d 층", "zh": "%d 层", "th": "ชั้น"],
            "game_record": ["vi": "KỶ LỤC", "en": "BEST", "ja": "ベスト", "ko": "최고 기록", "zh": "最高纪录", "th": "สถิติ"],
            "game_block_collapsed": ["vi": "Tháp đã đổ!", "en": "Tower collapsed!", "ja": "タワーが倒れました！", "ko": "타워が崩壊しました！", "zh": "塔坍塌了！", "th": "หอคอยพังแล้ว!"],
            "game_new_record": ["vi": "🏗 KỶ LỤC CÔNG TRÌNH 🏗", "en": "🏗 CONSTRUCTION RECORD 🏗", "ja": "🏗 建設の新記録 🏗", "ko": "🏗 새로운 건설 기록 🏗", "zh": "🏗 建筑新纪录 🏗", "th": "🏗 สถิติการก่อสร้างใหม่ 🏗"],
            "game_floors_achieved": ["vi": "Tầng đã đạt được", "en": "Floors achieved", "ja": "到達した階数", "ko": "달성한 층수", "zh": "达到的楼层", "th": "ชั้นที่ทำได้"],
            "game_progress": ["vi": "Tiến độ", "en": "Progress", "ja": "進捗", "ko": "진행률", "zh": "进度", "th": "ความคืบหน้า"],
            "game_new_record_title": ["vi": "🎉 KỶ LỤC MỚI 🎉", "en": "🎉 NEW RECORD 🎉", "ja": "🎉 新記録 🎉", "ko": "🎉 최고 기록 🎉", "zh": "🎉 新纪录 🎉", "th": "🎉 สถิติใหม่ 🎉"],
            "game_excellent": ["vi": "Bạn thật xuất sắc!", "en": "You're excellent!", "ja": "素晴らしい！", "ko": "정말 훌륭합니다!", "zh": "你太棒了！", "th": "คุณยอดเยี่ยมมาก!"],
            "game_wonderful": ["vi": "Tuyệt vời!", "en": "Wonderful!", "ja": "すごい！", "ko": "대단합니다!", "zh": "太棒了！", "th": "มหัศจรรย์!"],
            "game_block_restart": ["vi": "Xây tháp mới", "en": "Build New Tower", "ja": "新しいタワーを建てる", "ko": "새 타워 건설", "zh": "建造新塔", "th": "สร้างหอคอยใหม่"],
            "game_block_share_msg": ["vi": "Tôi vừa xây được tháp từ vựng cao %1$d tầng trong học phần '%2$@'! Bạn có đủ kiến thức để xây cao hơn không? 🏗🔥\nTải LuminaCards ngay!", "en": "I just built a %1$d-floor vocab tower in '%2$@'! Can you build it higher? 🏗🔥\nDownload LuminaCards now!", "ja": "LuminaCardsの「%2$@」で %1$d 階建てのタワーを建てました！もっと高く建てられますか？ 🏗🔥\n今すぐアプリをダウンロード！", "ko": "LuminaCards의 '%2$@'에서 %1$d층 단어 타워를 건설했습니다! 더 높이 쌓을 수 있을까요? 🏗🔥\n지금 앱을 다운로드하세요!", "zh": "我刚刚在 LuminaCards 的 “%2$@” 中建造了一座 %1$d 层的词汇塔！你能建得更高吗？ 🏗🔥\n立即下载应用！", "th": "ฉันเพิ่งสร้างหอคอยคำศัพท์ได้ %1$d ชั้นในชุดการเรียน '%2$@'! คุณจะสร้างได้สูงกว่านี้ไหม? 🏗🔥\nดาวน์โหลด LuminaCards เลย!"],
            
            // MARK: - Matching Game
            "game_match_title": ["vi": "Ghi nhớ (Nối thẻ)", "en": "Memory Match", "ja": "マッチングゲーム", "ko": "카드 맞추기", "zh": "配对游戏", "th": "จับคู่การ์ด"],
            "game_match_intro1": ["vi": "Nhấn vào các cặp thẻ tương ứng (Thuật ngữ & Định nghĩa).", "en": "Tap the corresponding card pairs (Term & Definition).", "ja": "対応するカードのペア（用語と定義）をタップします。", "ko": "해당하는 카드 쌍(용어 및 정의)을 탭하세요.", "zh": "点击对应的卡片对（术语和定义）。", "th": "แตะคู่การ์ดที่ตรงกัน (คำศัพท์และคำจำกัดความ)"],
            "game_match_intro2": ["vi": "Cố gắng hoàn thành trong thời gian ngắn nhất có thể.", "en": "Try to finish in the shortest time possible.", "ja": "できるだけ短時間で完了できるようにしましょう。", "ko": "가능한 한 빨리 완료해 보세요.", "zh": "尝试在尽可能短的时间内完成。", "th": "พยายามทำเวลาให้สั้นที่สุดเท่าที่จะทำได้"],
            "game_match_intro3": ["vi": "Các cặp thẻ đúng sẽ biến mất khỏi màn hình.", "en": "Correct pairs will disappear from the screen.", "ja": "正しいペアは画面から消えます。", "ko": "올바른 쌍은 화면에서 사라집니다。", "zh": "正确的配对将从屏幕上消失。", "th": "คู่ที่ถูกต้องจะหายไปจากหน้าจอ"],
            "game_match_start": ["vi": "Bắt đầu chơi", "en": "Start Game", "ja": "ゲームを開始", "ko": "게임 시작", "zh": "开始游戏", "th": "เริ่มเกม"],
            "game_match_time": ["vi": "THỜI GIAN", "en": "TIME", "ja": "時間", "ko": "時間", "zh": "时间", "th": "เวลา"],
            "game_match_best": ["vi": "KỶ LỤC TỐT NHẤT", "en": "BEST TIME", "ja": "ベストタイム", "ko": "최고 기록", "zh": "最佳时间", "th": "เวลาที่ดีที่สุด"],
            "game_match_finished": ["vi": "Hoàn thành!", "en": "Success!", "ja": "完了！", "ko": "완료!", "zh": "成功！", "th": "สำเร็จ!"],
            "game_match_play_again": ["vi": "Chơi lại", "en": "Play Again", "ja": "もう一度プレイ", "ko": "다시 플레이", "zh": "再玩一次", "th": "เล่นอีกครั้ง"],
            "game_match_share_msg": ["vi": "Tôi vừa hoàn thành trò chơi nối thẻ trong học phần '%1$@' với thời gian %2$@! Bạn có thể làm nhanh hơn không? ⚡️🔥\nTải LuminaCards ngay!", "en": "I just finished the matching game in '%1$@' in %2$@! Can you beat my time? ⚡️🔥\nDownload LuminaCards now!", "ja": "LuminaCardsの「%1$@」のマッチングゲームを %2$@ でクリアしました！私の記録を破れますか？ ⚡️🔥\n今すぐアプリをダウンロード！", "ko": "LuminaCards의 '%1$@'에서 카드 맞추기 게임을 %2$@만에 완료했습니다! 제 기록을 깰 수 있을까요? ⚡️🔥\n지금 앱을 다운로드하세요!", "zh": "我刚刚在 LuminaCards 的 “%1$@” 中以 %2$@ 的成绩完成了配对游戏！你能打破我的记录吗？ ⚡️🔥\n立即下载应用！", "th": "ฉันเพิ่งเล่นเกมจับคู่ในชุดการเรียน '%1$@' เสร็จในเวลา %2$@! คุณจะทำเวลาได้ดีกว่าฉันไหม? ⚡️🔥\nดาวน์โหลด LuminaCards เลย!"],
            
            // MARK: - Blast Game
            "game_blast_title": ["vi": "Tiêu Diệt Quái Vật", "en": "Monster Hunter", "ja": "モンスターハンター", "ko": "몬스터 사냥꾼", "zh": "怪物猎人", "th": "นักล่ามอนสเตอร์"],
            "game_blast_intro1": ["vi": "Tìm đúng nghĩa của từ vựng hiện trên súng.", "en": "Find the correct definition of the word on the gun.", "ja": "銃に表示されている単語の正しい定義を見つけます。", "ko": "총에 표시된 단어의 올바른 정의를 찾으세요.", "zh": "找到枪上显示的单词的正确定义。", "th": "ค้นหาคำจำกัดความที่ถูกต้องของคำที่ปรากฏบนปืน"],
            "game_blast_intro2": ["vi": "Chạm vào những con quái vật mang nghĩa đúng.", "en": "Tap the monsters carrying the correct meaning.", "ja": "正しい意味を持っているモンスターをタップします。", "ko": "올바른 의미를 가진 몬스터를 탭하세요.", "zh": "点击带有正确含义的怪物。", "th": "แตะมอนสเตอร์ที่มีคำที่ถูกต้อง"],
            "game_blast_intro3": ["vi": "Đừng để quái vật lừa bạn! Chọn sai sẽ bị mất mạng.", "en": "Don't let monsters trick you! Wrong choices cost lives.", "ja": "モンスターに騙されないで！間違った選択をするとライフが減ります。", "ko": "몬스터에게 속지 마세요! 잘못 선택하면 생명을 잃습니다.", "zh": "不要让怪物欺骗你！选错会扣除生命值。", "th": "อย่าให้มอนสเตอร์หลอกคุณ! เลือกผิดจะเสียชีวิต"],
            "game_blast_start": ["vi": "Sẵn Sàng Chiến Đấu", "en": "Ready to Fight", "ja": "戦闘準備完了", "ko": "전투 준비", "zh": "准备战斗", "th": "พร้อมต่อสู้"],
            "game_blast_countdown_ready": ["vi": "NHẬP CUỘC!", "en": "HUNT!", "ja": "狩り開始！", "ko": "사냥 시작!", "zh": "开始追猎！", "th": "ล่า!"],
            "game_blast_current_target": ["vi": "MỤC TIÊU HIỆN TẠI", "en": "CURRENT TARGET", "ja": "現在のターゲット", "ko": "현재 목표", "zh": "当前目标", "th": "เป้าหมายปัจจุบัน"],
            "game_blast_mission_complete": ["vi": "Nhiệm vụ hoàn tất!", "en": "Mission Complete!", "ja": "ミッション完了！", "ko": "임무 완료!", "zh": "任务完成！", "th": "ภารกิจเสร็จสิ้น!"],
            "game_blast_failed": ["vi": "Thất bại!", "en": "Failed!", "ja": "失敗！", "ko": "실패!", "zh": "失败！", "th": "ล้มเหลว!"],
            "game_blast_current_score": ["vi": "ĐIỂM HIỆN TẠI", "en": "CURRENT SCORE", "ja": "現在のスコア", "ko": "현재 점수", "zh": "当前得分", "th": "คะแนนปัจจุบัน"],
            "game_blast_retry": ["vi": "Tái đấu", "en": "Rematch", "ja": "再試合", "ko": "재대결", "zh": "再试一次", "th": "ท้าดวลใหม่"],
            "game_blast_share_msg": ["vi": "Tôi vừa đạt %1$d điểm trong thử thách tiêu diệt quái vật từ vựng '%2$@'! 👾 Ai dám thách đấu đây? 🔥\n#LuminaCards #MonsterHunt", "en": "I just scored %1$d in the '%2$@' vocab monster hunt! 👾 Who dares to challenge me? 🔥\n#LuminaCards #MonsterHunt", "ja": "LuminaCardsの「%2$@」で %1$d 点を記録しました！ 👾 私に挑戦する人はいますか？ 🔥\n#LuminaCards #MonsterHunt", "ko": "LuminaCards의 '%2$@'에서 %1$d점을 획득했습니다! 👾 저에게 도전할 사람이 있나요? 🔥\n#LuminaCards #MonsterHunt", "zh": "我刚刚在 LuminaCards 的 “%2$@” 中获得了 %1$d 分！ 👾 谁敢来挑战我？ 🔥\n#LuminaCards #MonsterHunt", "th": "ฉันเพิ่งทำได้ %1$d คะแนนในการล่ามอนสเตอร์คำศัพท์ '%2$@'! 👾 ใครจะกล้าท้าทายฉันไหม? 🔥\n#LuminaCards #MonsterHunt"],
            "game_blast_warrior_record": ["vi": "🏅 KỶ LỤC CHIẾN BINH 🏅", "en": "🏅 WARRIOR RECORD 🏅", "ja": "🏅 戦士の記録 🏅", "ko": "🏅 전사의 기록 🏅", "zh": "🏅 战士纪录 🏅", "th": "🏅 สถิตินักรบ 🏅"],

            // MARK: - Word List
            "word_list_filter_all": ["vi": "Tất cả", "en": "All", "ja": "すべて", "ko": "전체", "zh": "全部", "th": "ทั้งหมด"],
            "word_list_filter_new": ["vi": "Mới", "en": "New", "ja": "新規", "ko": "신규", "zh": "新", "th": "ใหม่"],
            "word_list_filter_learning": ["vi": "Đang học", "en": "Learning", "ja": "学習中", "ko": "학습 중", "zh": "正在学习", "th": "กำลังเรียน"],
            "word_list_filter_mastered": ["vi": "Đã thuộc", "en": "Mastered", "ja": "習得済み", "ko": "마스터", "zh": "已掌握", "th": "เรียนรู้แล้ว"],
            "word_list_sort_again": ["vi": "Quên nhiều", "en": "Again first", "ja": "「もう一度」を優先", "ko": "'다시' 우선", "zh": "“再次”优先", "th": "ทบทวนซ้ำก่อน"],
            "word_list_sort_hard": ["vi": "Khó nhiều", "en": "Hard first", "ja": "「難しい」を優先", "ko": "'어려움' 우선", "zh": "“困难”优先", "th": "คำยากก่อน"],
            "word_list_sort_easy": ["vi": "Dễ nhiều", "en": "Easy first", "ja": "「簡単」を優先", "ko": "'쉬움' 우선", "zh": "“简单”优先", "th": "คำง่ายก่อน"],
            "word_list_sort_alphabetical": ["vi": "A-Z", "en": "Alphabetical", "ja": "アルファベット順", "ko": "알파벳순", "zh": "按字母顺序", "th": "ตามลำดับอักษร"],
            "word_list_sort_title": ["vi": "Sắp xếp từ vựng", "en": "Sort Vocabulary", "ja": "単語の並べ替え", "ko": "단어 정렬", "zh": "词汇排序", "th": "จัดเรียงคำศัพท์"],
            "word_list_search_placeholder": ["vi": "Tìm từ vựng...", "en": "Search vocabulary...", "ja": "単語を検索...", "ko": "단어 검색...", "zh": "搜索词汇...", "th": "ค้นหาคำศัพท์..."],
            "word_list_empty_title": ["vi": "Chưa có từ vựng", "en": "No vocabulary yet", "ja": "単語がありません", "ko": "単語がありません", "zh": "暂无词汇", "th": "ยังไม่มีคำศัพท์"],
            "word_list_empty_msg": ["vi": "Thêm từ vựng đầu tiên", "en": "Add your first word", "ja": "最初の単語を追加", "ko": "첫 번째 단어 추가", "zh": "添加第一个词汇", "th": "เพิ่มคำศัพท์คำแรก"],
            "word_list_not_found_title": ["vi": "Không tìm thấy", "en": "Not found", "ja": "見つかりません", "ko": "찾을 수 없음", "zh": "未找到", "th": "ไม่พบ"],
            "word_list_not_found_msg": ["vi": "Thử từ khóa khác", "en": "Try a different keyword", "ja": "別のキーワードをお試しください", "ko": "다른 키워드를 시도해 보세요", "zh": "尝试不同的关键词", "th": "ลองคำค้นหาอื่น"],
            "word_list_stat_total": ["vi": "Tổng", "en": "Total", "ja": "合計", "ko": "합계", "zh": "总计", "th": "รวม"],
            
            // MARK: - Add Word
            "add_word_title": ["vi": "Thêm từ mới", "en": "Add New Word", "ja": "新しい単語を追加", "ko": "새 단어 추가", "zh": "添加新单词", "th": "เพิ่มคำใหม่"],
            "add_word_front_label": ["vi": "Từ vựng", "en": "Term", "ja": "用語", "ko": "용어", "zh": "术语", "th": "คำศัพท์"],
            "add_word_front_ph": ["vi": "VD: Hello", "en": "e.g., Hello", "ja": "例: Hello", "ko": "예: Hello", "zh": "例如：Hello", "th": "ตัวอย่าง: Hello"],
            "add_word_back_label": ["vi": "Nghĩa", "en": "Definition", "ja": "定義", "ko": "정의", "zh": "定义", "th": "คำจำกัดความ"],
            "add_word_back_ph": ["vi": "VD: Xin chào", "en": "e.g., Hello", "ja": "例: こんにちは", "ko": "예: 안녕하세요", "zh": "例如：你好", "th": "ตัวอย่าง: สวัสดี"],
            "add_word_pron_label": ["vi": "Phát âm (tùy chọn)", "en": "Pronunciation (optional)", "ja": "発音（任意）", "ko": "발음 (선택 사항)", "zh": "发音（可选）", "th": "การออกเสียง (ระบุหรือไม่ก็ได้)"],
            "add_word_pron_ph": ["vi": "VD: /həˈloʊ/", "en": "e.g., /həˈloʊ/", "ja": "例: /həˈloʊ/", "ko": "예: /həˈloʊ/", "zh": "例如：/həˈloʊ/", "th": "ตัวอย่าง: /həˈloʊ/"],
            "add_word_ex_label": ["vi": "Câu ví dụ (tùy chọn)", "en": "Example (optional)", "ja": "例文（任意）", "ko": "예문 (선택 사항)", "zh": "例句（可选）", "th": "ตัวอย่างประโยค (ระบุหรือไม่ก็ได้)"],
            "add_word_notes_label": ["vi": "Ghi chú (tùy chọn)", "en": "Notes (optional)", "ja": "メモ（任意）", "ko": "메모 (선택 사항)", "zh": "笔记（可选）", "th": "บันทึก (ระบุหรือไม่ก็ได้)"],
            "add_word_notes_ph": ["vi": "Ghi chú cá nhân...", "en": "Personal notes...", "ja": "個人的なメモ...", "ko": "개인 메모...", "zh": "个人笔记...", "th": "บันทึกส่วนตัว..."],
            "add_word_action": ["vi": "Thêm từ vựng", "en": "Add Word", "ja": "単語を追加", "ko": "단어 추가", "zh": "添加单词", "th": "เพิ่มคำศัพท์"],
            "add_word_preview": ["vi": "Xem trước", "en": "Preview", "ja": "プレビュー", "ko": "미리보기", "zh": "预览", "th": "ตัวอย่าง"],
            "add_word_ai_title": ["vi": "Gợi ý từ AI", "en": "AI Suggestions", "ja": "AIの提案", "ko": "AI 제안", "zh": "AI 建议", "th": "คำแนะนำจาก AI"],

            // MARK: - Common Actions
            "common_done": ["vi": "Hoàn tất", "en": "Done", "ja": "完了", "ko": "완료", "zh": "完成", "th": "เสร็จสิ้น"],
            "common_cancel": ["vi": "Hủy", "en": "Cancel", "ja": "キャンセル", "ko": "취소", "zh": "取消", "th": "ยกเลิก"],
            "common_save": ["vi": "Lưu", "en": "Save", "ja": "保存", "ko": "저장", "zh": "保存", "th": "บันทึก"],
            "common_see_all": ["vi": "Xem tất cả", "en": "See All", "ja": "すべて表示", "ko": "모두 보기", "zh": "查看全部", "th": "ดูทั้งหมด"],
            "common_create_new": ["vi": "Tạo mới", "en": "Create New", "ja": "新規作成", "ko": "새로 만들기", "zh": "新建", "th": "สร้างใหม่"],
            "common_delete": ["vi": "Xóa", "en": "Delete", "ja": "削除", "ko": "삭제", "zh": "删除", "th": "ลบ"],
            "deck_delete_title": ["vi": "Xóa học phần?", "en": "Delete Deck?", "ja": "セットを削除しますか？", "ko": "세트를 삭제하시겠습니까?", "zh": "删除学习集？", "th": "ลบชุดการเรียน?"],
            "deck_delete_msg": ["vi": "Hành động này không thể hoàn tác. Bạn có chắc chắn muốn xóa học phần này không?", "en": "This action cannot be undone. Are you sure you want to delete this deck?", "ja": "この操作は元に戻せません。本当にこのセットを削除しますか？", "ko": "이 작업은 되돌릴 수 없습니다. 이 세트를 정말로 삭제하시겠습니까?", "zh": "此操作无法撤销。您确定要删除此学习集吗？", "th": "ไม่สามารถเปลี่ยนย้อนกลับได้ คุณแน่ใจหรือไม่ว่าต้องการลบชุดการเรียนนี้?"],
            "deck_share_text": ["vi": "Học cùng tôi học phần: %@ trên LuminaCards! 🔥", "en": "Join me in studying %@ on LuminaCards! 🔥", "ja": "LuminaCardsで%@を一緒に勉強しましょう！ 🔥", "ko": "LuminaCards에서 %@를 함께 공부해요! 🔥", "zh": "在 LuminaCards 上和我一起学习 %@ 吧！ 🔥", "th": "มาร่วมเรียนรู้ %@ บน LuminaCards กับฉัน! 🔥"]
        ]
    
    static func string(_ key: String, lang: String) -> String {
        return translations[key]?[lang] ?? key
    }
}
