//
//  LuminareSlider+StepTicks.swift
//  Luminare
//
//  Created by KrLite on 2026/8/10.
//

import SwiftUI

#if compiler(>=6.2)

    // MARK: - Stepped Ticks

    @available(macOS 26.0, *)
    public extension LuminareSlider {
        /// Initializes a slider with a customizable tick for each step.
        init(
            value: Binding<V>,
            in range: ClosedRange<V>,
            step: V.Stride,
            tick: @escaping (V) -> SliderTick<V>?,
            format: F,
            clampsUpper: Bool = true,
            clampsLower: Bool = true,
            onEditingChanged: @escaping (Bool) -> () = { _ in },
            onEditingCommit: @escaping () -> () = {},
            @ViewBuilder content: @escaping (AnyView) -> Content,
            @ViewBuilder label: @escaping () -> Label
        ) {
            self.init(
                value: value,
                in: range,
                step: step,
                format: format,
                clampsUpper: clampsUpper,
                clampsLower: clampsLower,
                onEditingChanged: onEditingChanged,
                onEditingCommit: onEditingCommit,
                sliderTickStorage: LuminareSliderStepTickStorage(body: tick),
                content: content,
                label: label
            )
        }

        /// Initializes a slider with a text label and a customizable tick for each step.
        @_disfavoredOverload
        init(
            _ title: some StringProtocol,
            value: Binding<V>,
            in range: ClosedRange<V>,
            step: V.Stride,
            tick: @escaping (V) -> SliderTick<V>?,
            format: F,
            clampsUpper: Bool = true,
            clampsLower: Bool = true,
            onEditingChanged: @escaping (Bool) -> () = { _ in },
            onEditingCommit: @escaping () -> () = {},
            @ViewBuilder content: @escaping (AnyView) -> Content
        ) where Label == Text {
            self.init(
                value: value,
                in: range,
                step: step,
                tick: tick,
                format: format,
                clampsUpper: clampsUpper,
                clampsLower: clampsLower,
                onEditingChanged: onEditingChanged,
                onEditingCommit: onEditingCommit,
                content: content
            ) {
                Text(title)
            }
        }

        /// Initializes a slider with a localized label and a customizable tick for each step.
        init(
            _ titleKey: LocalizedStringKey,
            value: Binding<V>,
            in range: ClosedRange<V>,
            step: V.Stride,
            tick: @escaping (V) -> SliderTick<V>?,
            format: F,
            clampsUpper: Bool = true,
            clampsLower: Bool = true,
            onEditingChanged: @escaping (Bool) -> () = { _ in },
            onEditingCommit: @escaping () -> () = {},
            @ViewBuilder content: @escaping (AnyView) -> Content
        ) where Label == Text {
            self.init(
                value: value,
                in: range,
                step: step,
                tick: tick,
                format: format,
                clampsUpper: clampsUpper,
                clampsLower: clampsLower,
                onEditingChanged: onEditingChanged,
                onEditingCommit: onEditingCommit,
                content: content
            ) {
                Text(titleKey)
            }
        }

        /// Initializes a prefixed or suffixed slider with a customizable tick for each step.
        init(
            value: Binding<V>,
            in range: ClosedRange<V>,
            step: V.Stride,
            tick: @escaping (V) -> SliderTick<V>?,
            format: F,
            clampsUpper: Bool = true,
            clampsLower: Bool = true,
            prefix: Text? = nil,
            suffix: Text? = nil,
            onEditingChanged: @escaping (Bool) -> () = { _ in },
            onEditingCommit: @escaping () -> () = {},
            @ViewBuilder label: @escaping () -> Label
        ) where Content == HStack<TupleView<(Text?, AnyView, Text?)>> {
            self.init(
                value: value,
                in: range,
                step: step,
                tick: tick,
                format: format,
                clampsUpper: clampsUpper,
                clampsLower: clampsLower,
                onEditingChanged: onEditingChanged,
                onEditingCommit: onEditingCommit
            ) { view in
                HStack(spacing: 0) {
                    if let prefix {
                        prefix
                            .fontDesign(.monospaced)
                    }

                    view

                    if let suffix {
                        suffix
                            .fontDesign(.monospaced)
                    }
                }
            } label: {
                label()
            }
        }

        /// Initializes a prefixed or suffixed slider with a text label and customizable ticks.
        @_disfavoredOverload
        init(
            _ title: some StringProtocol,
            value: Binding<V>,
            in range: ClosedRange<V>,
            step: V.Stride,
            tick: @escaping (V) -> SliderTick<V>?,
            format: F,
            clampsUpper: Bool = true,
            clampsLower: Bool = true,
            prefix: Text? = nil,
            suffix: Text? = nil,
            onEditingChanged: @escaping (Bool) -> () = { _ in },
            onEditingCommit: @escaping () -> () = {}
        ) where Label == Text, Content == HStack<TupleView<(Text?, AnyView, Text?)>> {
            self.init(
                value: value,
                in: range,
                step: step,
                tick: tick,
                format: format,
                clampsUpper: clampsUpper,
                clampsLower: clampsLower,
                prefix: prefix,
                suffix: suffix,
                onEditingChanged: onEditingChanged,
                onEditingCommit: onEditingCommit
            ) {
                Text(title)
            }
        }

        /// Initializes a prefixed or suffixed slider with a localized label and customizable ticks.
        init(
            _ titleKey: LocalizedStringKey,
            value: Binding<V>,
            in range: ClosedRange<V>,
            step: V.Stride,
            tick: @escaping (V) -> SliderTick<V>?,
            format: F,
            clampsUpper: Bool = true,
            clampsLower: Bool = true,
            prefix: Text? = nil,
            suffix: Text? = nil,
            onEditingChanged: @escaping (Bool) -> () = { _ in },
            onEditingCommit: @escaping () -> () = {}
        ) where Label == Text, Content == HStack<TupleView<(Text?, AnyView, Text?)>> {
            self.init(
                value: value,
                in: range,
                step: step,
                tick: tick,
                format: format,
                clampsUpper: clampsUpper,
                clampsLower: clampsLower,
                prefix: prefix,
                suffix: suffix,
                onEditingChanged: onEditingChanged,
                onEditingCommit: onEditingCommit
            ) {
                Text(titleKey)
            }
        }
    }
#endif
