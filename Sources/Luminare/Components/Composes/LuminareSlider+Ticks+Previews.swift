//
//  LuminareSlider+Ticks+Previews.swift
//  Luminare
//
//  Created by KrLite on 2026/8/10.
//

import SwiftUI

#if compiler(>=6.2)
    #if DEBUG
        @available(macOS 26.0, *)
        #Preview(
            "LuminareSlider Ticks",
            traits: .sizeThatFitsLayout
        ) {
            @Previewable @State var steppedValue = 0.5
            @Previewable @State var continuousValue = 0.5

            LuminareSection {
                LuminareSlider(
                    "Stepped Ticks",
                    value: $steppedValue,
                    in: 0...1,
                    step: 0.1,
                    tick: { value in
                        switch value {
                        case 0, 0.5, 1:
                            SliderTick(value) {
                                Text(value, format: .number.precision(.fractionLength(0...1)))
                            }
                        default:
                            SliderTick(value)
                        }
                    },
                    format: .number.precision(.fractionLength(0...2))
                )

                LuminareSlider(
                    "Custom Ticks",
                    value: $continuousValue,
                    in: 0...1,
                    format: .number.precision(.fractionLength(0...2)),
                    ticks: {
                        SliderTickContentForEach(
                            [0.0, 0.25, 0.5, 0.75, 1.0],
                            id: \.self
                        ) { value in
                            SliderTick(value) {
                                Text(value, format: .number.precision(.fractionLength(0...2)))
                            }
                        }
                    }
                )
            }
            .frame(width: 450)
        }
    #endif
#endif
