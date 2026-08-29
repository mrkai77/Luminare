import AppKit
@testable import Luminare
import Testing

@MainActor
struct LuminareStyledWindowTests {
    @Test func trafficLightsRemainCircular() throws {
        let window = LuminareStyledWindow(
            contentRect: .init(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.titled, .fullSizeContentView, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )

        window.layoutIfNeeded()
        try expectCircularTrafficLights(in: window)

        // A second pass takes the "already constrained" early return, which must not change the
        // geometry the first pass already established
        window.layoutIfNeeded()
        try expectCircularTrafficLights(in: window)
    }

    private func expectCircularTrafficLights(
        in window: LuminareStyledWindow,
        sourceLocation: SourceLocation = #_sourceLocation
    ) throws {
        for type in [NSWindow.ButtonType.closeButton, .miniaturizeButton, .zoomButton] {
            let button = try #require(window.standardWindowButton(type), sourceLocation: sourceLocation)
            #expect(button.frame.width > 0, sourceLocation: sourceLocation)
            #expect(button.frame.width == button.frame.height, sourceLocation: sourceLocation)
        }
    }
}
