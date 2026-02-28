# PopCount 🎈

An accessible, ad-free cognitive development tool designed for early childhood. PopCount helps children ages 3–6 learn sequential counting and improve fine motor skills through positive reinforcement and interactive gameplay.

---

## 🌟 EdTech Philosophy
PopCount is built on the principles of **Gentle Learning**:
- **Zero Anxiety:** No countdown timers. The game uses an ascending stopwatch to track progress without pressure.
- **Positive Reinforcement:** High-quality animations, sparkles, and a friendly mascot ("Bubble Buddy") encourage the child.
- **Oopsie Meter:** Instead of "Game Over," children have 3 hearts. Making a mistake is part of learning!
- **Visual Hints:** Subtle pulsing animations guide the child if they get stuck for more than 5 seconds.

---

## 🎮 Gameplay Features
- **3 Difficulty Levels:** 
  - 🟢 **Little Learner:** Numbers 1–9 (3x3 Grid)
  - 🟡 **Growing Star:** Numbers 1–16 (4x4 Grid)
  - 🔵 **Super Counter:** Numbers 1–25 (5x5 Grid)
- **Interactive Mascot:** Tap our friendly mascot for encouraging messages!
- **3D Toy-Like UI:** Bubbles feel like soft physical buttons with 3D gradients and inner highlights.
- **Celebration:** Win a level to see a 3-star rating and a confetti burst!

---

## 🛠 Technical Stack
- **Framework:** Flutter (Web, Android, iOS)
- **State Management:** BLoC (Business Logic Component)
- **Persistence:** SharedPreferences (Saves sound and accessibility preferences)
- **Animations:** Custom implicit and explicit animations for a "living" UI.
- **CI/CD:** Automated GitHub Actions for Web deployment and icon generation.

---

## 🚀 Getting Started
1. **Prerequisites:** Install [Flutter SDK](https://docs.flutter.dev/get-started/install).
2. **Clone:** `git clone https://github.com/Pradeep-089/PopCount.git`
3. **Setup:** 
   ```bash
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```
4. **Run:** `flutter run -d chrome` (or your preferred device)

---

## 🏗 System Architecture
PopCount follows a strict **Finite State Machine (FSM)** using BLoC:
- **GameInitial:** Level selection and preparation.
- **GamePlaying:** Active counting with mistake tracking and hint timers.
- **GameWon:** Celebration state with performance metrics.
- **GameLost:** Gentle "Try Again" state with Oopsie Meter resolution.

---

## 📄 License
This project is for educational and cognitive development purposes.
