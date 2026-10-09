//
//  LuminareSlider+Ticks.swift
//  Luminare
//
//  Created by KrLite on 2026/8/10.
//

import SwiftUI

struct LuminareNativeSlider<V>: View
    where V: Strideable & BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
    let value: Binding<V>
    let range: ClosedRange<V>
    let step: V.Stride?
    let tickStorage: (any LuminareSliderTickStorage)?
    let onEditingChanged: (Bool) -> ()

    init(
        value: Binding<V>,
        in range: ClosedRange<V>,
        step: V.Stride?,
        tickStorage: (any LuminareSliderTickStorage)?,
        onEditingChanged: @escaping (Bool) -> ()
    ) {
        self.value = value
        self.range = range
        self.step = step
        self.tickStorage = tickStorage
        self.onEditingChanged = onEditingChanged
    }

    var body: some View {
        #if compiler(>=6.2)
            if #available(macOS 26.0, *), let tickStorage {
                slider(with: tickStorage)
            } else {
                sliderWithoutTicks
            }
        #else
            sliderWithoutTicks
        #endif
    }

    @ViewBuilder private var sliderWithoutTicks: some View {
        if let step {
            Slider(
                value: value,
                in: range,
                step: step,
                onEditingChanged: onEditingChanged
            )
        } else {
            Slider(
                value: value,
                in: range,
                onEditingChanged: onEditingChanged
            )
        }
    }

    #if compiler(>=6.2)
        @available(macOS 26.0, *)
        @ViewBuilder private func slider(with tickStorage: any LuminareSliderTickStorage) -> some View {
            if let ticks = tickStorage as? LuminareSliderTickContentStorage<V> {
                Slider(
                    value: value,
                    in: range,
                    label: { EmptyView() },
                    ticks: { ticks },
                    onEditingChanged: onEditingChanged
                )
            } else if let step,
                      let tick = tickStorage as? LuminareSliderStepTickStorage<V> {
                Slider(
                    value: value,
                    in: range,
                    step: step,
                    label: { EmptyView() },
                    tick: tick.body,
                    onEditingChanged: onEditingChanged
                )
            } else {
                sliderWithoutTicks
            }
        }
    #endif
}

#if compiler(>=6.2)
    @available(macOS 26.0, *)
    struct LuminareSliderTickContentStorage<V>: SliderTickContent, LuminareSliderTickStorage
        where V: BinaryFloatingPoint {
        typealias Value = V
        typealias Body = [SliderTick<V>]

        let body: Body

        init(_ content: some SliderTickContent<V>) {
            self.body = Array(content.body)
        }
    }

    @available(macOS 26.0, *)
    struct LuminareSliderStepTickStorage<V>: LuminareSliderTickStorage
        where V: BinaryFloatingPoint {
        let body: (V) -> SliderTick<V>?
    }

#endif
