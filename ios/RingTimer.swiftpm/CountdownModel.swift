import SwiftUI

@MainActor
final class CountdownModel: ObservableObject {
    @Published var remaining = 0
    @Published var total = 0
    @Published var isRunning = false
    /// Increments each time a countdown reaches zero, so the view can fire
    /// a fresh celebration even on repeated runs.
    @Published var finishCount = 0

    private var timer: Timer?

    func start(seconds: Int) {
        timer?.invalidate()
        total = seconds
        remaining = seconds
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
    }

    private func tick() {
        remaining -= 1
        if remaining <= 0 {
            remaining = 0
            timer?.invalidate()
            timer = nil
            isRunning = false
            finishCount += 1
        }
    }
}
