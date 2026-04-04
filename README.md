# Keeping Score

`Keeping Score` is an iOS SwiftUI app for tracking scores and game state across multiple game modes.

Right now the app includes:
- Simple Scoring
- Skull King scoring
- Tournament management
- Monopoly cash and property tracking

## Tech Stack

- Swift
- SwiftUI
- Xcode

## Project Structure

The main app code lives under [`KeepingScore`](/Users/joeyfaas/Documents/KeepingScore/KeepingScore).

Key folders:
- [`KeepingScore/Root`](/Users/joeyfaas/Documents/KeepingScore/KeepingScore/Root): app entry, root views, and assets
- [`KeepingScore/Models`](/Users/joeyfaas/Documents/KeepingScore/KeepingScore/Models): shared game models
- [`KeepingScore/Views/Landing`](/Users/joeyfaas/Documents/KeepingScore/KeepingScore/Views/Landing): landing and navigation UI
- [`KeepingScore/Views/SimpleScoring`](/Users/joeyfaas/Documents/KeepingScore/KeepingScore/Views/SimpleScoring): generic score tracker
- [`KeepingScore/Views/SkullKingScoring`](/Users/joeyfaas/Documents/KeepingScore/KeepingScore/Views/SkullKingScoring): Skull King flow and logic
- [`KeepingScore/Views/Tournaments`](/Users/joeyfaas/Documents/KeepingScore/KeepingScore/Views/Tournaments): tournament setup, bracket, participants, and match details
- [`KeepingScore/Views/Monopoly`](/Users/joeyfaas/Documents/KeepingScore/KeepingScore/Views/Monopoly): Monopoly setup, scoreboard, players, properties, and game logic

## App Entry

The app starts in [`KeepingScoreApp.swift`](/Users/joeyfaas/Documents/KeepingScore/KeepingScore/Root/KeepingScoreApp.swift).

It creates and injects the main shared state objects:
- `GameManager`
- `TournamentStore`
- `MonopolyGameManager`

The landing screen is [`LandingPageView.swift`](/Users/joeyfaas/Documents/KeepingScore/KeepingScore/Views/Landing/LandingPageView.swift), which routes users into each game mode.

## Current Features

### Simple Scoring
- Basic score tracking
- Lightweight scoreboard flow

### Skull King
- Player setup
- Round score entry
- Leaderboard flow

### Tournaments
- Tournament setup
- Participant management
- Match detail flow
- Bracket browsing by round

### Monopoly
- Player setup with tokens and starting cash
- Cash adds, deductions, and transfers
- Property ownership tracking
- Monopoly, house, hotel, and mortgage rules
- House and hotel bank counters
- Bankruptcy tracking and bankruptcy order
- Automatic end-of-game detection
- Final leaderboard summary with winner and stats

## Development Notes

- The project uses SwiftUI environment objects heavily for shared game state.
- Monopoly state is managed in `MonopolyGameManager`.
- Tournament state is managed in `TournamentStore`.
- There is legacy tournament code in some branches that may duplicate file names. If you hit a build error like `Multiple commands produce ... TournamentBracketView.stringsdata`, check for duplicate `TournamentBracketView.swift` files in different folders.

## Running The App

1. Open [`Keeping Score.xcodeproj`](/Users/joeyfaas/Documents/KeepingScore/Keeping%20Score.xcodeproj) in Xcode.
2. Select the `Keeping Score` scheme.
3. Choose an iOS simulator or device.
4. Build and run.

## Tests

Test targets are included:
- [`KeepingScoreTests`](/Users/joeyfaas/Documents/KeepingScore/KeepingScoreTests)
- [`KeepingScoreUITests`](/Users/joeyfaas/Documents/KeepingScore/KeepingScoreUITests)

## Known Cleanup Areas

- Remove outdated duplicate tournament prototype files if they still exist in older branches.
- Continue consolidating view naming and folder structure across branches.
- Add more automated tests around game-specific business logic, especially Monopoly rules and tournament flows.
