import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var model = CountdownModel()
    @State private var system = ConfettiSystem()
    @State private var celebrating = false

    /// Ring fill: full at rest, draining as the countdown runs.
    private var fraction: Double {
        model.total == 0 ? 1 : max(0, Double(model.remaining) / Double(model.total))
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: 0xE9F1FB), Color(hex: 0xDCE9F8)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                Text("10-SECOND COUNTDOWN")
                    .font(.caption).fontWeight(.bold)
                    .tracking(3)
                    .foregroundStyle(.secondary)

                ring

                Button {
                    model.start(seconds: 10)
                } label: {
                    Text(model.isRunning ? "Counting down…" : "Start 10s countdown")
                        .font(.headline)
                        .padding(.horizontal, 8)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(hex: 0x7AA4DD))
                .controlSize(.large)
                .disabled(model.isRunning)

                card
            }
            .padding()

            ConfettiView(system: system, celebrating: $celebrating)
                .allowsHitTesting(false)
                .ignoresSafeArea()
        }
        .onAppear {
            system.onFinished = { celebrating = false }
        }
        .onChange(of: model.finishCount) { _ in
            system.trigger()
            celebrating = true
        }
    }

    private var ring: some View {
        ZStack {
            Circle()
                .stroke(Color(hex: 0xD4E3F6), lineWidth: 14)
            Circle()
                .trim(from: 0, to: fraction)
                .stroke(
                    Color(hex: 0x7AA4DD),
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: fraction)
            VStack(spacing: 2) {
                Text("\(model.remaining)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(Color(hex: 0x2B2839))
                Text("SECONDS")
                    .font(.caption2).tracking(2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 240, height: 240)
    }

    private var card: some View {
        HStack(spacing: 16) {
            avatar
                .resizable()
                .scaledToFill()
                .frame(width: 84, height: 84)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 4) {
                Text("James Sanders").font(.headline)
                Text("Founder · Music Teacher · Frontend Developer")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text("BRISBANE, AUSTRALIA")
                    .font(.caption2).fontWeight(.bold)
                    .tracking(1)
                    .foregroundStyle(Color(hex: 0x7AA4DD))
                    .padding(.top, 4)
            }
            Spacer(minLength: 0)
        }
        .padding(18)
        .frame(maxWidth: 420)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    /// The avatar, loaded from bundled resources with an SF Symbol fallback.
    private var avatar: Image {
        if let url = Bundle.module.url(forResource: "james", withExtension: "jpg"),
           let uiImage = UIImage(contentsOfFile: url.path) {
            return Image(uiImage: uiImage)
        }
        return Image(systemName: "person.crop.square.fill")
    }
}
