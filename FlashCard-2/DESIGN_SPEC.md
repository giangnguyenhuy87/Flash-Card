# LuminaCards - iOS UI/UX Design Specification 🎨

## Design Philosophy: "Gen Z Premium"
- **Style**: Modern Minimalist, Dark Mode First (OLED Black).
- **Vibe**: Energetic, Fluid, Gamified.
- **Typography**: SF Pro Rounded (Friendly, Approachable).
- **Colors**:
  - **Background**: `#000000` (True Black) & `#1C1C1E` (Dark Grey Surface).
  - **Primary**: Electric Purple (`#6D28D9`) to Violet Gradient.
  - **Accents**: Hot Pink (`#EC4899`), Teal (`#14B8A6`), Amber (`#FBBF24`).
- **Shapes**: Super-rounded corners (32pt for cards, 16pt for buttons).
- **Feedback**: Heavy use of Haptics and Micro-interactions.

---

## 1. Onboarding & Authentication

### 1.1 Welcome / Splash Screen
- **Purpose**: immediate brand impression.
- **Layout**:
  - Centered animated logo (pulsing glow).
  - Bottom: "LuminaCards" text in large heavy font.
  - Slogan fading in: "Master Languages. Fast."
- **Interaction**: Auto-transition after 2s or tap to start.

### 1.2 Onboarding Flow
- **Layout**:
  - **Top**: Large 3D-style illustration (Parallax effect on swipe).
  - **Middle**: Bold Title (e.g., "Brain Hacking 🧠") + short subtitle.
  - **Bottom**: Page indicator (worm style) + "Next" button (Floating capsule).
- **Animation**: Elements slide up and scale; background blobs shift colors.

### 1.3 Language & Goal Setup
- **Layout**:
  - **Header**: "What are you learning?"
  - **Grid**: 2-column grid of Language Pills (Flags + Name). Selected state adds a neon border.
  - **Slider**: "Daily Goal: 10 Words". Dragging the slider changes the emoji reaction (😐 -> 🙂 -> 🔥).
- **Main Component**: `LanguageSelectionGrid`, `GoalSlider`.

---

## 2. Home Dashboard 🏠

### Breakdown
- **Header**:
  - Left: "Good Evening, [Name]" (Fade in).
  - Right: Profile Avatar (Circular, with progress ring border).
- **Hero Section (Streak)**:
  - A visual "Fire" visualization.
  - Text: "7 Day Streak! Keep it up."
  - Background: Subtle animated gradient mesh.
- **Quick Actions (Horizontal Scroll)**:
  - "Review (12)" - Red badge.
  - "Learn New (5)" - Blue badge.
  - "Quick Quiz" - Purple badge.
- **Recent Decks (Vertical List)**:
  - **Card Item**:
    - Left: Large Emoji/Icon on frosted glass background.
    - Center: Deck Title + Progress Bar (thin line).
    - Right: "Start" icon.
- **Navigation**: Custom "Dock" floating at bottom (Home, Browse, Stats, Profile).

---

## 3. Deck Management 📚

### 3.1 Deck List Screen
- **Layout**:
  - **Top**: Search Bar (Capsule shape, sticky).
  - **Filter Chips**: "All", "Japanese", "French", "Coding".
  - **Grid/List Toggle**: Users can switch view modes.
- **Interaction**:
  - **Long Press** on deck: Context menu (Edit, Share, Delete).
  - **Pull to Refresh**: standard iOS behavior.

### 3.2 Create/Edit Deck
- **Layout**: Form-sheet presentation.
  - **Cover**: Large square area to pick color/emoji/image.
  - **Input**: "Deck Name" (Large text).
  - **Settings**: "Daily New Cards" stepper.
- **Animation**: The "Save" button floats above the keyboard.

---

## 4. Vocabulary Management 📝

### 4.1 Word List Screen
- **Layout**:
  - **Sectioned List**: Grouped by "New", "Learning", "Mastered".
  - **Row**:
    - Term (Bold).
    - Meaning (Grey).
    - Status Dot (Green/Yellow/Red).
- **Interaction**: Swiping row left reveals "Edit" and "Delete".

### 4.2 Add/Edit Word
- **Layout**:
  - **Input Fields**: Floating label style.
  - **Auto-Suggest**: As user types, show AI suggestions in a bubble row below.
  - **Media**: Buttons to "Record Audio" (Mic icon) and "Add Image".

---

## 5. Flashcard Learning Mode (The Core) ⚡️

### Layout
- **Fullscreen Immersive**: No tab bar, minimal nav bar.
- **The Card**:
  - Occupies 80% of screen.
  - **Front**: Huge Text centered.
  - **Back**: Meaning + Example Sentence + Audio Button.
- **Controls**:
  - **Hidden Initialy**: Tap card to flip.
  - **Revealed**: 4-Button Row (Again, Hard, Good, Easy) OR Swipe Gestures.

### Interactions
- **Swipe Right**: "Good" (Green stick overaly, Haptic Success).
- **Swipe Left**: "Again" (Red tint overlay, Haptic Warning).
- **Flip**: 3D Rotation (X-axis).

---

## 6. Quiz Mode 🎯

### Layout
- **Top**: Progress Bar (Segmented).
- **Center**: Question (Card style).
- **Bottom**:
  - **Multiple Choice**: 4 large buttons stacked.
  - **Typing**: Keyboard moves content up.
- **Feedback**:
  - **Correct**: Confetti rain, button turns green.
  - **Wrong**: Shake animation, button turns red, correct answer slides up.

---

## 7. Statistics & AI 📊

### 7.1 Stats Dashboard
- **Layout**:
  - **Heatmap**: GitHub-style activity grid (Green blocks).
  - **Line Chart**: "Words Learned" over time.
  - **Radar Chart**: "Skill Balance" (Reading, Listening, Writing).

### 7.2 AI Assistant
- **Layout**: Chat-interface style.
- **Bubbles**: "I found 3 weak words in 'Japanese N5'. Want to review?"
- **Action Buttons**: "Review Now", "Show Examples".

---

## 8. Profile & Settings ⚙️
- **Layout**: Standard List grouped style but with custom cells.
- **Header**: Large circular avatar, editable.
- **Gamification**: Badges showcase (Grid of earned medals).
- **Preferences**: Toggles for "Haptics", "Sound Effects", "Dark Mode".

---

## Navigation Flow
1. **Launch** -> Onboarding (First time) -> **Home**.
2. **Home** -> Deck Detail -> **Study Mode**.
3. **Study Mode** -> Summary Screen -> **Home**.
4. **Dock** -> Switch between Home, Search, Stats, Profile.
