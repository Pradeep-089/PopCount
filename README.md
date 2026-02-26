# Number Bubble Game

A 2D mobile puzzle and reaction game built with Flutter.

---

## Business Requirements Document (BRD)
**Project Name:** Number Bubble  
**Platform:** Mobile (Android/iOS via Flutter)  
**Version:** 2.0 (Updated with Bombs, Timer, and Point-Based Tier System)

### 1. Executive Summary
"Number Bubble" is a 2D mobile puzzle and reaction game designed to test a user's peripheral vision, speed, and focus under pressure. Players must find and pop numbered bubbles in a randomized NXN grid in sequential order before a countdown timer expires.

### 2. Core Objectives
- Deliver a highly responsive, zero-latency touch experience.
- Implement a dynamically scaling difficulty system.
- Create a high-stakes gameplay loop with instant-fail "Bomb" cells.
- Reward players with gamer ranks based on a 100-point calculation system.

### 3. Functional Requirements
#### 3.1. Difficulty Selection
| Level | Grid Size | Target Sequence | Bombs | Time Limit | Base Points |
| :--- | :--- | :--- | :--- | :--- | :--- |
| ChildsPlay | 2X2 | 1 to 4 | 0 | 15 seconds | 10 pts |
| Easy | 3X3 | 1 to 9 | 0 | 30 seconds | 20 pts |
| Medium | 4X4 | 1 to 13 | 3 | 45 seconds | 30 pts |
| Hard | 5X5 | 1 to 20 | 5 | 60 seconds | 40 pts |
| Expert | 6X6 | 1 to 28 | 8 | 80 seconds | 50 pts |
| NightMare | 10X10 | 1 to 75 | 25 | 180 seconds | 60 pts |

#### 3.2. Gameplay Rules
- **Correct Tap:** Increments `expectedNumber` and pops the bubble.
- **Wrong Tap (Penalty):** Resets `expectedNumber` to 1 and reshuffles the grid.
- **Bomb Tap (Fatal):** Immediate "Loss State".
- **Time Out (Fatal):** Immediate "Loss State".

### 4. 100-Point Tier System
Rank is calculated upon Victory: **Base Points + Speed Bonus**.
- **S-Rank Speed (> 70% time left):** +40 pts
- **A-Rank Speed (> 40% time left):** +30 pts
- **B-Rank Speed (> 10% time left):** +20 pts
- **C-Rank Speed (< 10% time left):** +10 pts

**Rankings:**
- 100: Aimbot
- 90: Cracked
- 80: Sweaty
- 70: Clutch
- 60: Tryhard
- 50: Gamer
- 40: Casual
- 30: Bot
- 20: NPC
- 10: Noob

---

## Technical Design Document (TDD)
**Architecture Pattern:** BLoC (Business Logic Component) / Strict FSM  
**Version:** 4.0

### 1. System Architecture
- **The UI (View):** Flutter widgets dispatch Events to the BLoC and listen to States.
- **The BLoC (Controller):** Manages game loop, timer stream, and yields distinct States.
- **Finite State Machine (FSM):** Strict state enforcement (Initial, Playing, Won, Lost).

### 2. Core Engine (GameBloc)
- **Events:** `GameStartedEvent`, `BubbleTappedEvent`, `TimerTickedEvent`.
- **States:** `GameInitial`, `GamePlaying`, `GameWon`, `GameLost`.
- **Algorithms:** $O(N)$ Fisher-Yates shuffle for grid generation and penalty reshuffling.

### 3. UI Strategy
- **BlocBuilder:** Localized rebuilds for Grid and Timer for 60 FPS performance.
- **BlocListener:** Triggers the `ScorecardModal` overlay on Win/Loss.
- **Responsive Design:** AspectRatio-locked square grid with max-width constraints for Web/Desktop.

---

## Getting Started
1. Ensure Flutter is installed.
2. Clone this repository.
3. Run `flutter pub get`.
4. Run `flutter run`.
