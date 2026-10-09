//
//  LuminareSlider+CustomTicks.swift
//  Luminare
//
//  Created by KrLite on 2026/8/10.
//

import SwiftUI

#if compiler(>=6.2)

    // MARK: - Custom Ticks

    @available(macOS 26.0, *)
    public extension LuminareSlider {
        /// Initializes a continuous slider with fully customizable ticks.
        init(
            value: Binding<V>,
            in range: ClosedRange<V>,
            format: F,
            clampsUpper: Bool = true,
            clampsLower: Bool = true,
            onEditingChanged: @escaping (Bool) -> () = { _ in },
            onEditingCommit: @escaping () -> () = {},
            @SliderTickBuilder<V> ticks: () -> some SliderTickContent<V>,
            @ViewBuilder content: @escaping (AnyView) -> Content,
            @ViewBuilder label: @escaping () -> Label
        ) {
            self.init(
                value: value,
                in: range,
                step: nil,
                format: format,
                clampsUpper: clampsUpper,
                clampsLower: clampsLower,
                onEditingChanged: onEditingChanged,
                onEditingCommit: onEditingCommit,
                sliderTickStorage: LuminareSliderTickContentStorage(ticks()),
                content: content,
                label: label
            )
        }

        /// Initializes a continuous slider with a text label and fully customizable ticks.
        @_disfavoredOverload
        init(
            _ title: some StringProtocol,
            value: Binding<V>,
            in range: ClosedRange<V>,
            format: F,
            clampsUpper: Bool = true,
            clampsLower: Bool = true,
            onEditingChanged: @escaping (Bool) -> () = { _ in },
            onEditingCommit: @escaping () -> () = {},
            @SliderTickBuilder<V> ticks: () -> some SliderTickContent<V>,
            @ViewBuilder content: @escaping (AnyView) -> Content
        ) where Label == Text {
            self.init(
                value: value,
                in: range,
                format: format,
                clampsUpper: clampsUpper,
                clampsLower: clampsLower,
                onEditingChanged: onEditingChanged,
                onEditingCommit: onEditingCommit,
                ticks: ticks,
                content: content
            ) {
                Text(title)
            }
        }

        /// Initializes a continuous slider with a localized label and fully customizable ticks.
        init(
            _ titleKey: LocalizedStringKey,
            value: Binding<V>,
            in range: ClosedRange<V>,
            format: F,
            clampsUpper: Bool = true,
            clampsLower: Bool = true,
            onEditingChanged: @escaping (Bool) -> () = { _ in },
            onEditingCommit: @escaping () -> () = {},
            @SliderTickBuilder<V> ticks: () -> some SliderTickContent<V>,
            @ViewBuilder content: @escaping (AnyView) -> Content
        ) where Label == Text {
            self.init(
                value: value,
                in: range,
                format: format,
                clampsUpper: clampsUpper,
                clampsLower: clampsLower,
                onEditingChanged: onEditingChanged,
                onEditingCommit: onEditingCommit,
                ticks: ticks,
                content: content
            ) {
                Text(titleKey)
            }
        }

        /// Initializes a prefixed or suffixed continuous slider with fully customizable ticks.
        init(
            value: Binding<V>,
            in range: ClosedRange<V>,
            format: F,
            clampsUpper: Bool = true,
            clampsLower: Bool = true,
            prefix: Text? = nil,
            suffix: Text? = nil,
            onEditingChanged: @escaping (Bool) -> () = { _ in },
            onEditingCommit: @escaping () -> () = {},
            @SliderTickBuilder<V> ticks: () -> some SliderTickContent<V>,
            @ViewBuilder label: @escaping () -> Label
        ) where Content == HStack<TupleView<(Text?, AnyView, Text?)>> {
            self.init(
                value: value,
                in: range,
                format: format,
                clampsUpper: clampsUpper,
                clampsLower: clampsLower,
                onEditingChanged: onEditingChanged,
                onEditingCommit: onEditingCommit,
                ticks: ticks
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

        /// Initializes a prefixed or suffixed continuous slider with a text label and customizable ticks.
        @_disfavoredOverload
        init(
            _ title: some StringProtocol,
            value: Binding<V>,
            in range: ClosedRange<V>,
            format: F,
            clampsUpper: Bool = true,
            clampsLower: Bool = true,
            prefix: Text? = nil,
            suffix: Text? = nil,
            onEditingChanged: @escaping (Bool) -> () = { _ in },
            onEditingCommit: @escaping () -> () = {},
            @SliderTickBuilder<V> ticks: () -> some SliderTickContent<V>
        ) where Label == Text, Content == HStack<TupleView<(Text?, AnyView, Text?)>> {
            self.init(
                value: value,
                in: range,
                format: format,
                clampsUpper: clampsUpper,
                clampsLower: clampsLower,
                prefix: prefix,
                suffix: suffix,
                onEditingChanged: onEditingChanged,
                onEditingCommit: onEditingCommit,
                ticks: ticks
            ) {
                Text(title)
            }
        }

        /// Initializes a prefixed or suffixed continuous slider with a localized label and customizable ticks.
        init(
            _ titleKey: LocalizedStringKey,
            value: Binding<V>,
            in range: ClosedRange<V>,
            format: F,
            clampsUpper: Bool = true,
            clampsLower: Bool = true,
            prefix: Text? = nil,
            suffix: Text? = nil,
            onEditingChanged: @escaping (Bool) -> () = { _ in },
            onEditingCommit: @escaping () -> () = {},
            @SliderTickBuilder<V> ticks: () -> some SliderTickContent<V>
        ) where Label == Text, Content == HStack<TupleView<(Text?, AnyView, Text?)>> {
            self.init(
                value: value,
                in: range,
                format: format,
                clampsUpper: clampsUpper,
                clampsLower: clampsLower,
                prefix: prefix,
                suffix: suffix,
                onEditingChanged: onEditingChanged,
                onEditingCommit: onEditingCommit,
                ticks: ticks
            ) {
                Text(titleKey)
            }
        }
    }
#endif
