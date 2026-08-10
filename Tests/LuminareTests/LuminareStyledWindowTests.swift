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
        window.layoutIfNeeded()

        for type in [NSWindow.ButtonType.closeButton, .miniaturizeButton, .zoomButton] {
            let button = try #require(window.standardWindowButton(type))
            let transform = try #require(button.layer?.affineTransform())
            let renderedWidth = button.frame.width * transform.a
            let renderedHeight = button.frame.height * transform.d

            #expect(abs(renderedWidth - renderedHeight) < 0.001)
        }
    }
}
