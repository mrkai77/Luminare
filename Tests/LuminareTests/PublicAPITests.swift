import Luminare
import SwiftUI
import Testing

struct PublicAPITests {
    @Test func modalPresentationConfigurationIsPublic() {
        let presentation = LuminareModalPresentation(
            .origin,
            offset: .init(x: 12, y: 24),
            relativeTo: .screen
        )

        #expect(presentation.target == .screen)
        #expect(presentation.alignment == .origin)
        #expect(presentation.offset == .init(x: 12, y: 24))
    }

    @MainActor
    @Test func sidebarOverflowModifierIsPublic() {
        _ = EmptyView().luminareSidebarOverflow(24)
    }
}
