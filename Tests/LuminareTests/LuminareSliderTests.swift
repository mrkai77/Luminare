import Foundation
@testable import Luminare
import Testing

struct LuminareSliderTests {
    @Test func conformanceRoundsToTheFormatsPrecision() {
        let decimals = FloatingPointFormatStyle<Double>.number.precision(.fractionLength(0...2))
        let tenths = FloatingPointFormatStyle<Double>.number.precision(.fractionLength(1))

        #expect(decimals.conformed(3.14159) == 3.14)
        #expect(tenths.conformed(0.30000000000000004) == 0.3)
    }

    @Test func snappingIsAnchoredToTheLowerBoundAndStaysWithinTheRange() {
        #expect(1.4.snapped(to: 2, in: 0.5...10) == 0.5)
        #expect(1.6.snapped(to: 2, in: 0.5...10) == 2.5)
        #expect(10.6.snapped(to: 1, in: 0...10.6) == 10.6)
    }
}
