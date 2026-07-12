import SwiftUI

/// Two lower-corner cannons that fire confetti and streamers up and inward at
/// ~70° for a 3-second burst, then let physics carry the pieces back down.
///
/// All tuning is expressed in *per-second* units (not per-frame) so the motion
/// looks identical at 60 Hz and 120 Hz — iPads with ProMotion run the animation
/// timeline at 120 fps, and per-frame constants would otherwise play double speed.
final class ConfettiSystem {
    enum Kind { case confetti, streamer }

    struct Particle {
        var kind: Kind
        var x: Double
        var y: Double
        var vx: Double
        var vy: Double
        var color: Color
        // confetti
        var w: Double = 0
        var h: Double = 0
        var rot: Double = 0
        var vrot: Double = 0
        var sway: Double = 0
        var swaySpeed: Double = 0
        // streamer
        var len: Double = 0
        var phase: Double = 0
        var waveAmp: Double = 0
        var waveFreq: Double = 0
        var wave: Double = 0
        var waveSpeed: Double = 0
    }

    private(set) var particles: [Particle] = []
    /// Called (on the main queue) once the last piece has left the screen.
    var onFinished: (() -> Void)?

    // Tuning — per-second units. Comments show the original per-frame value @60fps.
    private let emitDuration = 3.0
    private let launchAngle = 70.0 * .pi / 180.0
    private let gravity = 1260.0                    // 0.35 px/frame²  → ×3600
    private let dragPerSecond = pow(0.992, 60.0)    // 0.992 /frame     → ≈0.618 /s
    private let confettiPerSecondPerCannon = 260.0
    private let streamerPerSecondPerCannon = 30.0

    private let colors: [Color] = [
        Color(hex: 0xF94144), Color(hex: 0xF3722C), Color(hex: 0xF8961E),
        Color(hex: 0xF9C74F), Color(hex: 0x90BE6D), Color(hex: 0x43AA8B),
        Color(hex: 0x4D96FF), Color(hex: 0x577590), Color(hex: 0xE56399),
        Color(hex: 0x9B5DE5), Color(hex: 0x00BBF9), Color(hex: 0xF15BB5),
    ]

    private var active = false
    private var emitStart: Date?
    private var lastDate: Date?
    private var confettiAccum = 0.0
    private var streamerAccum = 0.0
    private var finishedSignaled = false

    /// Kick off a fresh celebration.
    func trigger() {
        particles.removeAll()
        active = true
        emitStart = nil
        lastDate = nil
        confettiAccum = 0
        streamerAccum = 0
        finishedSignaled = false
    }

    /// Advance the simulation to `date`. Called once per animation frame.
    func update(date: Date, size: CGSize) {
        guard active else { return }
        if emitStart == nil { emitStart = date }

        let dt: Double
        if let last = lastDate {
            dt = min(date.timeIntervalSince(last), 1.0 / 30.0) // clamp big stalls
        } else {
            dt = 0
        }
        lastDate = date

        let elapsed = date.timeIntervalSince(emitStart!)
        if elapsed < emitDuration {
            emit(dt: dt, size: size)
        }
        step(dt: dt, size: size)

        if elapsed >= emitDuration && particles.isEmpty && !finishedSignaled {
            active = false
            finishedSignaled = true
            let callback = onFinished
            DispatchQueue.main.async { callback?() }
        }
    }

    private func rand(_ a: Double, _ b: Double) -> Double { Double.random(in: a...b) }

    private func emit(dt: Double, size: CGSize) {
        confettiAccum += confettiPerSecondPerCannon * dt
        streamerAccum += streamerPerSecondPerCannon * dt
        let confettiCount = Int(confettiAccum); confettiAccum -= Double(confettiCount)
        let streamerCount = Int(streamerAccum); streamerAccum -= Double(streamerCount)

        let baseY = Double(size.height)
        let cannons: [(x: Double, dir: Double)] = [
            (0, 1),                       // bottom-left  → up and to the right
            (Double(size.width), -1),     // bottom-right → up and to the left
        ]

        for cannon in cannons {
            for _ in 0..<confettiCount {
                let angle = rand(launchAngle - 0.18, launchAngle + 0.18)
                let speed = rand(900, 1800)          // 15..30 px/frame
                particles.append(Particle(
                    kind: .confetti,
                    x: cannon.x, y: baseY,
                    vx: cannon.dir * cos(angle) * speed,
                    vy: -sin(angle) * speed,
                    color: colors.randomElement()!,
                    w: rand(6, 14), h: rand(8, 17),
                    rot: rand(0, 2 * .pi), vrot: rand(-21, 21),      // ±0.35/frame
                    sway: rand(0, 2 * .pi), swaySpeed: rand(1.8, 5.4) // 0.03..0.09/frame
                ))
            }
            for _ in 0..<streamerCount {
                let angle = rand(launchAngle - 0.15, launchAngle + 0.15)
                let speed = rand(960, 1620)          // 16..27 px/frame
                particles.append(Particle(
                    kind: .streamer,
                    x: cannon.x, y: baseY,
                    vx: cannon.dir * cos(angle) * speed,
                    vy: -sin(angle) * speed,
                    color: colors.randomElement()!,
                    len: rand(45, 105),
                    phase: rand(0, 2 * .pi),
                    waveAmp: rand(5, 12),
                    waveFreq: rand(0.1, 0.18),
                    wave: rand(0, 2 * .pi),
                    waveSpeed: rand(9, 18)           // 0.15..0.3/frame
                ))
            }
        }
    }

    private func step(dt: Double, size: CGSize) {
        guard dt > 0 else { return }
        let dragFactor = pow(dragPerSecond, dt)
        let bottom = Double(size.height)

        var i = 0
        while i < particles.count {
            var p = particles[i]
            if p.kind == .confetti {
                p.vy += gravity * dt
                p.vx *= dragFactor
                p.sway += p.swaySpeed * dt
                p.x += p.vx * dt
                p.y += p.vy * dt
                p.rot += p.vrot * dt
            } else {
                p.vy += gravity * 0.5 * dt
                p.vx *= dragFactor
                p.x += p.vx * dt
                p.y += p.vy * dt
                p.wave += p.waveSpeed * dt
            }

            let tail = p.kind == .streamer ? p.len : p.h
            if p.y - tail > bottom + 60 {
                particles.remove(at: i)   // fallen off the bottom — retire it
            } else {
                particles[i] = p
                i += 1
            }
        }
    }
}
