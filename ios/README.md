# RingTimer — native SwiftUI app

A native iOS/iPadOS version of the ring countdown timer, including the
two-corner 70° confetti + streamer celebration. Built with SwiftUI's `Canvas`
and `TimelineView` for the particle animation.

`RingTimer.swiftpm` is a **Swift Playgrounds App Playground**, so you can build
and run it two ways.

## Option A — on your iPad (no Mac needed) 👈 easiest

1. Install the free **Swift Playgrounds** app from the App Store (iPadOS 16+).
2. Get the `RingTimer.swiftpm` folder onto the iPad — easiest routes:
   - **iCloud Drive / Files:** copy the folder into Files, then open it.
   - **GitHub:** in the Files app, or after downloading the repo, tap
     `RingTimer.swiftpm`.
3. It opens in Swift Playgrounds. Tap **▶ Run** to build and launch it live,
   or **Share → Save to Files / Add to Home Screen** style build to keep it.

## Option B — on a Mac with Xcode

1. Open `RingTimer.swiftpm` in **Xcode 14 or later** (double-click it).
2. Pick your iPad (or an iPad Simulator) as the run destination.
3. Press **⌘R**.

## What's inside

| File | Role |
|------|------|
| `Package.swift` | App Playground manifest (iOS 16+, iPad + iPhone) |
| `MyApp.swift` | `@main` app entry point |
| `ContentView.swift` | Layout: business card, ring, button |
| `CountdownModel.swift` | The 1-second countdown timer |
| `ConfettiSystem.swift` | The particle engine (per-second physics) |
| `ConfettiView.swift` | Canvas renderer, driven by an animation timeline |
| `Color+Hex.swift` | `Color(hex:)` helper |
| `Resources/james.jpg` | Avatar image |

## Note on the physics

The tuning constants are expressed in **per-second** units rather than
per-frame. iPads with ProMotion displays run the animation at 120 fps, so
per-frame values (as used in the web version) would play back at double speed.
Each step multiplies by the real elapsed time `dt`, so the motion looks the same
at 60 Hz and 120 Hz.
