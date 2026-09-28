# Mini Games

A single iOS app that bundles three small games into one structured, polished shell with real
platform features — persistent stats, a map of where you played, a stats dashboard, and daily
reminders. Built with SwiftUI for the BSc (Hons) Computing *iOS App Development* module
(BSCCOMP25.1P).

> **Note on the app name:** the bundle display name is still `Tap Frenzy` (a leftover from Week 1)
> and can be changed in the target's build settings (`INFOPLIST_KEY_CFBundleDisplayName`).

## The Games

| Game | Idea | Key mechanics |
|------|------|---------------|
| **Tap Frenzy** | Tap as fast as you can for 10 seconds | Combo multiplier, colour-changing bonus/penalty target, moving target, shrinking button |
| **Light It Up** | Whack-a-mole — tap the lit card before it fades | 4 difficulty levels inside one 60s round, growing grid, shrinking lit window |
| **Quiz Rush** | Live trivia from the Open Trivia DB | 10 questions, streak bonus, network loading/error states |

## Features

- **Four-tab shell** — Home, Stats, Map, Settings, each its own `NavigationStack`.
- **Persistent game history** — every finished round is saved as a `GameSession` in Core Data.
- **Stats dashboard** — totals, per-game personal bests, a recent-games list, and a Swift Charts
  bar chart. A game filter (chips) narrows the history to a single game.
- **Map of games** — each session records where it was played (Core Location); the Map tab drops a
  pin per session, and tapping a pin shows that round's score.
- **Daily challenge notification** — pick a time in Settings and get a repeating local reminder.
- **Share your score** — a `ShareLink` on the results screen shares a formatted brag string.
- **High-score celebration** — a confetti animation plays when you beat your best.
- **Sound & haptics** — looping background music in the two action games, plus haptic feedback on
  taps, results, and tab switches — both toggleable in Settings.
- **Safe exit** — leaving a game mid-round asks for confirmation and stops the timer/music.
- **Reset** — a destructive "reset all stats" action (with confirmation) clears both the Core Data
  sessions and the stored high scores.

## Architecture

The project follows an **MVVM** structure with a thin service layer, using the SwiftUI environment
for dependency injection and Apple's Observation framework (`@Observable`) for state.

```
iOS_Demo/
├── App/
│   └── iOS_DemoApp.swift          App entry; builds services and injects them into the environment
├── Models/
│   ├── GameMode.swift             The three games as one enum (title, icon, colour, storage key)
│   ├── GameSession.swift          Value type the UI reads (maps out of Core Data)
│   ├── TapMode.swift              Tap Frenzy bonus/penalty state
│   ├── LightItUpBoard.swift       Card + Level model for Light It Up
│   └── TriviaModels.swift         Open Trivia DB decoding + HTML entity decoding
├── Services/
│   ├── PersistenceController.swift Core Data stack (programmatic model + GameSessionMO)
│   ├── SessionStore.swift         @Observable wrapper: record / fetch / delete sessions
│   ├── LocationService.swift      CLLocationManager wrapper (permission + last coordinate)
│   ├── NotificationService.swift  UNUserNotificationCenter wrapper (daily reminder)
│   ├── AudioService.swift         AVAudioPlayer background-music loop
│   └── TriviaService.swift        Async trivia fetch
├── ViewModels/
│   ├── TapFrenzyViewModel.swift
│   ├── LightItUpViewModel.swift
│   ├── QuizRushViewModel.swift
│   └── StatsViewModel.swift        Aggregates sessions into totals / bests / recent
└── Views/
    ├── RootTabView.swift           The TabView shell
    ├── TapGameView.swift
    ├── LightItUpView.swift
    ├── QuizRushView.swift
    ├── Tabs/                        HomeTab, StatsTab, MapTab, SettingsTab
    └── Shared/                      GameCard, GameResultsView, ConfettiView
```

**Key decisions**

- **Persistence: Core Data, local only.** Game sessions are stored in Core Data with the model
  defined *programmatically* (`PersistenceController.model`) rather than in a `.xcdatamodeld` file,
  so the whole stack is readable Swift. All attributes are optional or defaulted, keeping it
  **CloudKit-ready** — switching to `NSPersistentCloudKitContainer` later needs only the iCloud
  capability (see limitations).
- **Settings: `@AppStorage`.** Simple flags (music, haptics, reminder on/off and time) live in
  UserDefaults via `@AppStorage`, separate from game data.
- **Dependency injection: the SwiftUI environment.** Services are created once in `iOS_DemoApp` and
  read anywhere with `@Environment(SomeService.self)`. Previews inject in-memory instances so they
  never touch real data.
- **State: `@Observable`.** Newer view models and services use the Observation framework; Quiz Rush
  keeps the older `ObservableObject` / Combine style.

## Tech Stack

SwiftUI · Core Data · Core Location + MapKit · Swift Charts · UserNotifications · AVFoundation ·
async/await · Observation (`@Observable`). Deployment target iOS 26.4.

## Running the Project

1. Open `iOS_Demo/iOS_Demo.xcodeproj` in Xcode.
2. Select an iPhone simulator or device and run.
3. For the Map tab in the **simulator**, set a location via **Features → Location → Apple** (the
   simulator has no real GPS).
4. Background music requires an audio file named `background_music.mp3` in the app target (already
   included).

## Known Limitations

- **No iCloud sync.** Persistence is local-only; CloudKit needs a paid Apple Developer account to
  enable the iCloud capability, so it was left off. The data model is designed to make the switch
  simple later.
- **Location caveats.** The simulator needs a location set manually, and any game finished before
  location permission is granted (or while denied) is saved without a pin.
- **Music ignores the silent switch.** The audio session uses the `.playback` category so music is
  audible even when the phone is muted; the in-app music toggle is the intended off-switch.
- **Notifications.** The permission prompt appears once — if denied during testing, re-enable it in
  the iOS Settings app. Notifications are not presented as banners while the app is in the
  foreground.
- **Quiz needs a network.** Quiz Rush fetches live questions from the Open Trivia DB and shows an
  error/retry state offline; there is no offline cache.
- **No automated tests yet.** The view models are structured to be testable, but unit tests haven't
  been added.

## Reflection

Coming from an Android background, the biggest shift was learning to *describe* the UI declaratively
and let state drive it, instead of imperatively wiring up views and adapters. SwiftUI's `@State` and
`@Observable` felt like the equivalent of `StateFlow` + Compose recomposition, and the SwiftUI
environment turned out to be a lightweight version of the dependency injection I'd have reached to
Hilt for on Android.

Structuring the app into `Models` / `ViewModels` / `Services` / `Views` before adding the Week 4
platform features made a real difference — once `GameSession` and `SessionStore` existed, the Stats,
Map, and reset features all read from the same source of truth without special-casing. The trickiest
bugs were subtle SwiftUI timing issues: a confetti animation that rendered at its *end* state because
I flipped the animation flag in the same frame the views were created, and a "best score" that
survived a reset because high scores lived in `@AppStorage` while sessions lived in Core Data — a
good reminder that "clear all data" has to clear *every* store, not just the obvious one.

If I continued the project I'd add unit tests for the view models, a home-screen widget backed by the
same store, and Game Center leaderboards.
