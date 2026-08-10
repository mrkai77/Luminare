@testable import Luminare
import Testing

struct LuminareStepperSourceTests {
    @Test func finiteSourceReportsItsNumericStructure() {
        if #available(macOS 15.0, *) {
            let source = LuminareStepperSource<Double>.finite(
                in: -1...1,
                step: 0.5
            )

            #expect(source.isFinite)
            #expect(!source.isContinuous)
            #expect(source.count == 5)
            #expect(source.step == 0.5)
            #expect(source.continuousIndex(of: 0.5) == 3)
        }
    }

    @Test func finiteRoundingIsAnchoredToTheLowerBound() {
        if #available(macOS 15.0, *) {
            let source = LuminareStepperSource<Double>.finite(
                in: -1...1,
                step: 0.5
            )
            let result = source.round(0.76)

            #expect(abs(result.value - 0.5) < 0.000_001)
            #expect(abs(result.offset - 0.26) < 0.000_001)
        }
    }

    @Test func finiteBoundsClampValuesAndRespectPadding() {
        if #available(macOS 15.0, *) {
            let source = LuminareStepperSource<Double>.finite(in: 0...10)

            #expect(source.wrap(-2) == 0)
            #expect(source.wrap(12) == 10)
            #expect(source.wrap(5) == 5)
            #expect(source.reachedLowerBound(0.4, padding: 0.5))
            #expect(source.reachedUpperBound(9.6, padding: 0.5))
        }
    }

    @Test func directionalOffsetsReverseAndOptionallyBypassClamping() {
        if #available(macOS 15.0, *) {
            let source = LuminareStepperSource<Double>.finite(in: 0...10)

            #expect(source.offsetBy(5, direction: .horizontal, nonAlternateOffset: 2) == 7)
            #expect(source.offsetBy(5, direction: .vertical, nonAlternateOffset: 2) == 3)
            #expect(source.offsetBy(5, direction: .horizontalAlternate, nonAlternateOffset: 2) == 3)
            #expect(source.offsetBy(5, direction: .verticalAlternate, nonAlternateOffset: 2) == 7)
            #expect(source.offsetBy(9, direction: .horizontal, nonAlternateOffset: 3) == 10)
            #expect(source.offsetBy(9, direction: .horizontal, nonAlternateOffset: 3, wrap: false) == 12)
        }
    }
}
