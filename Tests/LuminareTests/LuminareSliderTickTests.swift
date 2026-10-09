@testable import Luminare
import SwiftUI
import Testing

#if compiler(>=6.2)
    @MainActor
    struct LuminareSliderTickTests {
        @Test func legacyInitializerRemainsAvailable() {
            _ = LuminareSlider(
                "Legacy",
                value: Binding.constant(0.5),
                in: 0...1,
                format: .number
            )
        }

        @Test func customTickStoragePreservesEveryTick() {
            if #available(macOS 26.0, *) {
                let storage = LuminareSliderTickContentStorage(
                    SliderTickContentForEach(
                        [0.0, 0.5, 1.0],
                        id: \.self
                    ) { value in
                        SliderTick(value)
                    }
                )

                #expect(storage.body.count == 3)
            }
        }

        @Test func steppedTickStorageCanOmitTicks() {
            if #available(macOS 26.0, *) {
                let storage = LuminareSliderStepTickStorage<Double> { value in
                    value == 0.5 ? SliderTick(value) : nil
                }

                #expect(storage.body(0) == nil)
                #expect(storage.body(0.5) != nil)
                #expect(storage.body(1) == nil)
            }
        }

        @Test func publicTickInitializersBuild() {
            if #available(macOS 26.0, *) {
                let value = Binding.constant(0.5)

                _ = LuminareSlider(
                    "Stepped",
                    value: value,
                    in: 0...1,
                    step: 0.1,
                    tick: { SliderTick($0) },
                    format: .number
                )

                _ = LuminareSlider(
                    "Continuous",
                    value: value,
                    in: 0...1,
                    format: .number,
                    ticks: {
                        SliderTickContentForEach(
                            [0.0, 0.5, 1.0],
                            id: \.self
                        ) { tickValue in
                            SliderTick(tickValue)
                        }
                    }
                )
            }
        }
    }
#endif
