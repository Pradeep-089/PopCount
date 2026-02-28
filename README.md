# PopCount

A fast-paced 2D reaction game built with Flutter. Test your speed and focus by popping numbered bubbles in sequence!

---

## Business Requirements Document (BRD)
**Project Name:** PopCount
**Platform:** Mobile (Android/iOS via Flutter) & Web
**Version:** 2.0 (Updated with Bombs, Timer, and Point-Based Tier System)

### 1. Executive Summary
"PopCount" is a reaction game designed to test a user's peripheral vision, speed, and focus. Players must find and pop numbered bubbles in a randomized grid in sequential order before the timer expires.

### 2. Core Objectives
- Deliver a highly responsive, zero-latency touch experience.
- Implement a dynamically scaling difficulty system.
- Create a high-stakes gameplay loop with instant-fail "Bomb" cells.
- Reward players with ranks based on speed and accuracy.

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
- **Wrong Tap:** Resets sequence and reshuffles the grid.
- **Bomb Tap:** Immediate Game Over.
- **Time Out:** Immediate Game Over.

---

## Technical Design Document (TDD)
**Architecture Pattern:** BLoC (Business Logic Component)
**Version:** 4.0

### 1. System Architecture
- **View:** Flutter widgets dispatch events and listen to states.
- **BLoC:** Manages game loop, timer stream, and yields states.
- **FSM:** Strict state enforcement (Initial, Playing, Won, Lost).

---

## Getting Started
1. Ensure Flutter is installed.
2. Clone this repository.
3. Run `flutter pub get`.
4. Run `flutter run`.
