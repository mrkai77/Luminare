import Luminare
import SwiftUI
import Testing

@MainActor
struct EnvironmentValuesTests {
    @Test func defaultsRemainStable() {
        let values = EnvironmentValues()

        #expect(values.luminareModalCornerRadius == 12)
        #expect(values.luminareModalClosesOnDefocus == false)
        #expect(values.luminareTitleBarHeight == 50)
        #expect(values.luminareSidebarOverflow == 50)

        #expect(values.luminareMinHeight == 32)
        #expect(values.luminareHasDividers)
        #expect(values.luminareFormSpacing == 16)
        #expect(values.luminareFormLayout == .stacked)
        #expect(values.luminareSectionLayout == .stacked)
        #expect(values.luminareSectionHorizontalPadding == 8)
        #expect(values.luminareSectionMaxWidth == .infinity)

        #expect(values.luminareColorPickerHasCancel == false)
        #expect(values.luminareColorPickerHasDone == false)
        #expect(values.luminareCompactPickerStyle == .menu)
        #expect(values.luminareListItemHeight == 50)
        #expect(values.luminareSliderLayout == .regular)
        #expect(values.luminareSliderPickerLayout == .regular)
    }

    @Test func entriesRemainWritable() {
        var values = EnvironmentValues()

        values.luminareModalCornerRadius = 20
        values.luminareMinHeight = 44
        values.luminareListItemHeight = 60

        #expect(values.luminareModalCornerRadius == 20)
        #expect(values.luminareMinHeight == 44)
        #expect(values.luminareListItemHeight == 60)
    }
}
