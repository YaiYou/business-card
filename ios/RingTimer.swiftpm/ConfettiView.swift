import SwiftUI

/// Draws the confetti system on a full-screen Canvas, driven by an animation
/// timeline. The timeline is paused when no celebration is running so it costs
/// nothing at rest.
struct ConfettiView: View {
    let system: ConfettiSystem
    @Binding var celebrating: Bool

    var body: some View {
        TimelineView(.animation(paused: !celebrating)) { timeline in
            Canvas { context, size in
                system.update(date: timeline.date, size: size)

                for p in system.particles {
                    switch p.kind {
                    case .confetti:
                        // Copy the context so the rotate/translate only affect this flake.
                        var ctx = context
                        ctx.translateBy(x: p.x, y: p.y)
                        ctx.rotate(by: .radians(p.rot))
                        let squash = abs(cos(p.sway))
                        let w = p.w * (0.4 + 0.6 * squash)
                        let rect = CGRect(x: -w / 2, y: -p.h / 2, width: w, height: p.h)
                        ctx.fill(Path(rect), with: .color(p.color))

                    case .streamer:
                        // Trail the ribbon behind the head, waving side to side.
                        let speed = max((p.vx * p.vx + p.vy * p.vy).squareRoot(), 1)
                        let ux = p.vx / speed
                        let uy = p.vy / speed
                        let perpX = -uy
                        let perpY = ux

                        var path = Path()
                        var s = 0.0
                        while s <= p.len {
                            let wobble = sin(s * p.waveFreq + p.phase + p.wave) * p.waveAmp
                            let x = p.x - ux * s + perpX * wobble
                            let y = p.y - uy * s + perpY * wobble
                            let point = CGPoint(x: x, y: y)
                            if s == 0 { path.move(to: point) } else { path.addLine(to: point) }
                            s += 5
                        }
                        context.stroke(
                            path,
                            with: .color(p.color),
                            style: StrokeStyle(lineWidth: 5, lineCap: .round)
                        )
                    }
                }
            }
        }
    }
}
