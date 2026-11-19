//
//  LuminareSlider.swift
//  Luminare
//
//  Created by Kai Azim on 2024-04-02.
//

import SwiftUI

public enum LuminareSliderLayout: Equatable, Hashable, Identifiable, Codable, Sendable {
    case regular
    case compact(textBoxWidth: CGFloat? = nil, moveTextBoxToLeadingOnDrag: Bool = false)

    public var id: Self { self }

    var controlSizeMinHeight: CGFloat? {
        switch self {
        case .regular:
            70
        case .compact:
            nil
        }
    }
}

public extension LuminareSliderLayout {
    static var compact: Self { .compact() }
}

// MARK: - Slider (Compose)

public struct LuminareSlider<Label, Content, V, F>: View
    where Label: View, Content: View, V: Strideable & BinaryFloatingPoint, V.Stride: BinaryFloatingPoint,
    F: ParseableFormatStyle, F.FormatInput == V, F.FormatOutput == String {
    private enum FocusedField {
        case textbox
    }

    // MARK: Environments

    @Environment(\.luminareAnimation) private var animation
    @Environment(\.luminareAnimationFast) private var animationFast
    @Environment(\.luminareSectionHorizontalPadding) private var horizontalPadding
    @Environment(\.luminareSliderLayout) private var layout

    @FocusState private var focusedField: FocusedField?

    // MARK: Fields

    @Binding private var value: V
    @State private var internalValue: V
    @State private var lastValue: V
    private let range: ClosedRange<V>
    private let sliderStep: V.Stride?
    private let showSliderSteps: Bool
    private let format: F
    private let clampsUpper: Bool, clampsLower: Bool
    private let onEditingChanged: (Bool) -> ()
    private let onEditingCommit: () -> ()

    @ViewBuilder private var content: (AnyView) -> Content, label: () -> Label

    @State private var isTextBoxVisible: Bool = false
    @State private var isSliderHovering: Bool = false
    @State private var isSliderDebouncedHovering: Bool = false
    @State private var isSliderEditing: Bool = false
    @State private var composeWidth: CGFloat = .zero

    private let id: UUID = .init()

    // MARK: Initializers

    public init(
        value: Binding<V>,
        in range: ClosedRange<V>,
        sliderStep: V.Stride? = nil,
        showSliderSteps: Bool = true,
        format: F,
        clampsUpper: Bool = true,
        clampsLower: Bool = true,
        onEditingChanged: @escaping (Bool) -> () = { _ in },
        onEditingCommit: @escaping () -> () = {},
        @ViewBuilder content: @escaping (AnyView) -> Content,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self._value = value
        self.internalValue = value.wrappedValue
        self.lastValue = value.wrappedValue
        self.range = range
        self.sliderStep = sliderStep
        self.showSliderSteps = showSliderSteps
        self.format = format
        self.clampsUpper = clampsUpper
        self.clampsLower = clampsLower
        self.onEditingChanged = onEditingChanged
        self.onEditingCommit = onEditingCommit

        self.content = content
        self.label = label
    }

    @_disfavoredOverload
    public init(
        _ title: some StringProtocol,
        value: Binding<V>,
        in range: ClosedRange<V>,
        sliderStep: V.Stride? = nil,
        showSliderSteps: Bool = true,
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
            sliderStep: sliderStep,
            showSliderSteps: showSliderSteps,
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

    public init(
        _ titleKey: LocalizedStringKey,
        value: Binding<V>,
        in range: ClosedRange<V>,
        sliderStep: V.Stride? = nil,
        showSliderSteps: Bool = true,
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
            sliderStep: sliderStep,
            showSliderSteps: showSliderSteps,
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

    public init(
        value: Binding<V>,
        in range: ClosedRange<V>,
        sliderStep: V.Stride? = nil,
        showSliderSteps: Bool = true,
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
            sliderStep: sliderStep,
            showSliderSteps: showSliderSteps,
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

    @_disfavoredOverload
    public init(
        _ title: some StringProtocol,
        value: Binding<V>,
        in range: ClosedRange<V>,
        sliderStep: V.Stride? = nil,
        showSliderSteps: Bool = true,
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
            sliderStep: sliderStep,
            showSliderSteps: showSliderSteps,
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

    public init(
        _ titleKey: LocalizedStringKey,
        value: Binding<V>,
        in range: ClosedRange<V>,
        sliderStep: V.Stride? = nil,
        showSliderSteps: Bool = true,
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
            sliderStep: sliderStep,
            showSliderSteps: showSliderSteps,
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

    // MARK: Body

    public var body: some View {
        VStack(spacing: 4) {
            switch layout {
            case .regular:
                LuminareCompose {
                    textBoxView()
                        .fixedSize()
                } label: {
                    label()
                }

                sliderView()
                    .padding(.horizontal, horizontalPadding)
            case let .compact(textBoxWidth, moveTextBoxToLeadingOnDrag):
                if !moveTextBoxToLeadingOnDrag {
                    LuminareCompose {
                        HStack {
                            sliderView()

                            textBoxView()
                                .frame(width: textBoxWidth)
                                .fixedSize()
                        }
                        .frame(maxWidth: composeWidth * 0.7, alignment: .trailing)
                    } label: {
                        label()
                    }
                } else {
                    let isAlternativeTextBoxVisible = isSliderDebouncedHovering || isSliderEditing

                    LuminareCompose {
                        HStack {
                            sliderView()

                            if !isAlternativeTextBoxVisible {
                                textBoxView()
                                    .frame(width: textBoxWidth)
                                    .fixedSize()
                                    .transition(.move(edge: .trailing).combined(with: .opacity))
                            }
                        }
                        .frame(maxWidth: isAlternativeTextBoxVisible ? nil : composeWidth * 0.7, alignment: .trailing)
                    } label: {
                        if isAlternativeTextBoxVisible {
                            textBoxView()
                                .frame(width: textBoxWidth)
                                .fixedSize()
                                .transition(.move(edge: .leading).combined(with: .opacity))
                        } else {
                            label()
                        }
                    }
                }
            }
        }
        .frame(minHeight: layout.controlSizeMinHeight)
        .animation(animation, value: value)
        .animation(animation, value: isTextBoxVisible)
        .animation(animation, value: isSliderHovering)
        .animation(animation, value: isSliderDebouncedHovering)
        .animation(animation, value: isSliderEditing)
        .booleanThrottleDebounced(isSliderHovering) { debouncedValue in
            isSliderDebouncedHovering = debouncedValue
        }
        .onGeometryChange(for: CGFloat.self, of: \.size.width) { newValue in
            composeWidth = newValue
        }
        .onChange(of: value) { _ in // If value changes externally, reflect that internally
            internalValue = value
        }
    }

    private var countsDown: Bool {
        value > lastValue
    }

    /// The step passed to the slider track, which snaps while dragging and shows tick marks.
    private var trackStep: V.Stride? {
        showSliderSteps ? sliderStep : nil
    }

    @ViewBuilder private func sliderView() -> some View {
        let binding = Binding<V> {
            value
        } set: { newValue in
            let newValue = format.conformed(newValue)
            let didChange = newValue != value
            value = newValue
            isTextBoxVisible = false

            if trackStep != nil, didChange {
                NSHapticFeedbackManager.defaultPerformer.perform(
                    .alignment,
                    performanceTime: .drawCompleted
                )
            }
        }

        Group {
            if let trackStep {
                Slider(
                    value: binding,
                    in: range,
                    step: trackStep
                ) { isEditing in
                    handleEditingChanged(isEditing)
                }
            } else {
                Slider(
                    value: binding,
                    in: range
                ) { isEditing in
                    handleEditingChanged(isEditing)
                }
            }
        }
        .onHover { isSliderHovering = $0 }
    }

    private func textBoxView() -> some View {
        HStack {
            if isTextBoxVisible {
                let textFieldView = TextField(
                    value: $internalValue,
                    format: format
                ) {
                    EmptyView()
                }
                .labelsHidden()
                .textFieldStyle(.plain)
                .focused($focusedField, equals: .textbox)
                .multilineTextAlignment(.trailing)
                .padding(.leading, -4)
                .fontDesign(.monospaced)
                .onSubmit(commit)
                .onChange(of: focusedField == .textbox) {
                    if !$0 {
                        commit()
                    }
                }

                content(.init(textFieldView))
            } else {
                let textView = Text(format.format(value))
                    .contentTransition(.numericText(countsDown: countsDown))
                    .multilineTextAlignment(.trailing)
                    .fontDesign(.monospaced)

                Button {
                    withAnimation(animationFast) {
                        isTextBoxVisible.toggle()
                        focusedField = .textbox
                    }
                } label: {
                    content(.init(textView))
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(4)
        .padding(.horizontal, 4)
        .luminareSurface(isPressed: isTextBoxVisible, style: .flat)
        .luminareCornerRadius(999)
        .clipShape(.capsule)
        .onChange(of: isTextBoxVisible) { _ in
            if isTextBoxVisible {
                addEventMonitor()
            } else {
                removeEventMonitor()
            }
        }
        .onDisappear {
            removeEventMonitor()
        }
        .onChange(of: value) { value in
            DispatchQueue.main.async {
                lastValue = value
            }
        }
    }

    // MARK: Functions

    /// Clamps a value according to `clampsLower` and `clampsUpper`, then conforms it to `format`.
    private func committable(_ newValue: V) -> V {
        let clamped = if clampsLower, clampsUpper {
            newValue.clamped(to: range)
        } else if clampsLower {
            max(range.lowerBound, newValue)
        } else if clampsUpper {
            min(range.upperBound, newValue)
        } else {
            newValue
        }

        return format.conformed(clamped)
    }

    private func commit() {
        value = committable(internalValue)
        internalValue = value

        withAnimation(animationFast) {
            isTextBoxVisible = false
        }
    }

    private func handleEditingChanged(_ isEditing: Bool) {
        isSliderEditing = isEditing

        if !isEditing, !showSliderSteps, let sliderStep {
            value = format.conformed(value.snapped(to: sliderStep, in: range))
        }

        onEditingChanged(isEditing)

        if !isEditing {
            onEditingCommit()
        }
    }

    func addEventMonitor() {
        EventMonitorManager.shared.addLocalMonitor(
            for: id,
            matching: .keyDown
        ) { event in
            let downArrow: CGKeyCode = 0x7D
            let upArrow: CGKeyCode = 0x7E

            guard event.keyCode == downArrow || event.keyCode == upArrow else {
                return event
            }

            let isShiftDown = event.modifierFlags.contains(.shift) // x10
            let isOptionDown = event.modifierFlags.contains(.option) // x0.1
            let acceleration: V = if isShiftDown, isOptionDown {
                1
            } else if isShiftDown {
                10
            } else if isOptionDown {
                0.1
            } else {
                1
            }
            let step = V(sliderStep ?? 1) * acceleration
            let direction: V = event.keyCode == upArrow ? 1 : -1

            value = committable(value + direction * step)

            return nil
        }
    }

    func removeEventMonitor() {
        EventMonitorManager.shared.removeMonitor(for: id)
    }
}

// MARK: - Deprecated Initializers

@available(*, deprecated, message: "Use `sliderStep:` and `showSliderSteps:` instead.")
public extension LuminareSlider {
    init(
        value: Binding<V>,
        in range: ClosedRange<V>,
        step: V.Stride?,
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
            sliderStep: step,
            showSliderSteps: true,
            format: format,
            clampsUpper: clampsUpper,
            clampsLower: clampsLower,
            onEditingChanged: onEditingChanged,
            onEditingCommit: onEditingCommit,
            content: content,
            label: label
        )
    }

    @_disfavoredOverload
    init(
        _ title: some StringProtocol,
        value: Binding<V>,
        in range: ClosedRange<V>,
        step: V.Stride?,
        format: F,
        clampsUpper: Bool = true,
        clampsLower: Bool = true,
        onEditingChanged: @escaping (Bool) -> () = { _ in },
        onEditingCommit: @escaping () -> () = {},
        @ViewBuilder content: @escaping (AnyView) -> Content
    ) where Label == Text {
        self.init(
            title,
            value: value,
            in: range,
            sliderStep: step,
            showSliderSteps: true,
            format: format,
            clampsUpper: clampsUpper,
            clampsLower: clampsLower,
            onEditingChanged: onEditingChanged,
            onEditingCommit: onEditingCommit,
            content: content
        )
    }

    init(
        _ titleKey: LocalizedStringKey,
        value: Binding<V>,
        in range: ClosedRange<V>,
        step: V.Stride?,
        format: F,
        clampsUpper: Bool = true,
        clampsLower: Bool = true,
        onEditingChanged: @escaping (Bool) -> () = { _ in },
        onEditingCommit: @escaping () -> () = {},
        @ViewBuilder content: @escaping (AnyView) -> Content
    ) where Label == Text {
        self.init(
            titleKey,
            value: value,
            in: range,
            sliderStep: step,
            showSliderSteps: true,
            format: format,
            clampsUpper: clampsUpper,
            clampsLower: clampsLower,
            onEditingChanged: onEditingChanged,
            onEditingCommit: onEditingCommit,
            content: content
        )
    }

    init(
        value: Binding<V>,
        in range: ClosedRange<V>,
        step: V.Stride?,
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
            sliderStep: step,
            showSliderSteps: true,
            format: format,
            clampsUpper: clampsUpper,
            clampsLower: clampsLower,
            prefix: prefix,
            suffix: suffix,
            onEditingChanged: onEditingChanged,
            onEditingCommit: onEditingCommit,
            label: label
        )
    }

    @_disfavoredOverload
    init(
        _ title: some StringProtocol,
        value: Binding<V>,
        in range: ClosedRange<V>,
        step: V.Stride?,
        format: F,
        clampsUpper: Bool = true,
        clampsLower: Bool = true,
        prefix: Text? = nil,
        suffix: Text? = nil,
        onEditingChanged: @escaping (Bool) -> () = { _ in },
        onEditingCommit: @escaping () -> () = {}
    ) where Label == Text, Content == HStack<TupleView<(Text?, AnyView, Text?)>> {
        self.init(
            title,
            value: value,
            in: range,
            sliderStep: step,
            showSliderSteps: true,
            format: format,
            clampsUpper: clampsUpper,
            clampsLower: clampsLower,
            prefix: prefix,
            suffix: suffix,
            onEditingChanged: onEditingChanged,
            onEditingCommit: onEditingCommit
        )
    }

    init(
        _ titleKey: LocalizedStringKey,
        value: Binding<V>,
        in range: ClosedRange<V>,
        step: V.Stride?,
        format: F,
        clampsUpper: Bool = true,
        clampsLower: Bool = true,
        prefix: Text? = nil,
        suffix: Text? = nil,
        onEditingChanged: @escaping (Bool) -> () = { _ in },
        onEditingCommit: @escaping () -> () = {}
    ) where Label == Text, Content == HStack<TupleView<(Text?, AnyView, Text?)>> {
        self.init(
            titleKey,
            value: value,
            in: range,
            sliderStep: step,
            showSliderSteps: true,
            format: format,
            clampsUpper: clampsUpper,
            clampsLower: clampsLower,
            prefix: prefix,
            suffix: suffix,
            onEditingChanged: onEditingChanged,
            onEditingCommit: onEditingCommit
        )
    }
}

// MARK: - Value Conformance

extension ParseableFormatStyle where FormatOutput == String {
    /// Formats a value and parses it back, so it carries exactly the precision the format displays.
    /// Falls back to the original value if it can't be parsed.
    func conformed(_ value: FormatInput) -> FormatInput {
        (try? parseStrategy.parse(format(value))) ?? value
    }
}

extension Strideable where Stride: BinaryFloatingPoint {
    /// Snaps the value to the nearest multiple of `step` from the range's lower bound, staying within the range.
    func snapped(to step: Stride, in range: ClosedRange<Self>) -> Self {
        let steps = (range.lowerBound.distance(to: self) / step).rounded()
        return range.lowerBound.advanced(by: steps * step).clamped(to: range)
    }
}

// MARK: - Preview

@available(macOS 15.0, *)
#Preview(
    "LuminareSlider",
    traits: .sizeThatFitsLayout
) {
    @Previewable @State var value: Double = 42

    LuminareSection {
        LuminareSlider(
            value: $value,
            in: 0...128,
            format: .number.precision(.fractionLength(0...3)),
            prefix: Text("#")
        ) {
            VStack(alignment: .leading) {
                Text("Slide to stride")

                Text("Composed")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }

        LuminareSlider(
            "2 Decimal Places",
            value: $value,
            in: 0...128,
            format: .number.precision(.fractionLength(0...2)),
            prefix: Text("#")
        )
        .luminareSliderLayout(.compact(textBoxWidth: 100))

        LuminareSlider(
            value: $value,
            in: 0...128,
            format: .number.precision(.fractionLength(0...3)),
            prefix: Text("#")
        ) {
            Text("With an info")
                .luminareToolTip(attachedTo: .topTrailing) {
                    Text("Incididunt Lorem pariatur eiusmod laboris laboris.")
                        .padding()
                }
        }

        LuminareSlider(
            "Stepped with ticks",
            value: $value,
            in: 0...128,
            sliderStep: 8,
            format: .number.precision(.fractionLength(0...2)),
            prefix: Text("#")
        )

        LuminareSlider(
            "Snaps to whole numbers on release",
            value: $value,
            in: 0...128,
            sliderStep: 1,
            showSliderSteps: false,
            format: .number.precision(.fractionLength(0...2)),
            prefix: Text("#")
        )
        .luminareSliderLayout(.compact(textBoxWidth: 100))

        LuminareSlider(
            "With a sliding textbox",
            value: $value,
            in: 0...128,
            format: .number.precision(.fractionLength(0...2)),
            prefix: Text("#")
        )
        .luminareSliderLayout(.compact(textBoxWidth: 100, moveTextBoxToLeadingOnDrag: true))
    }
}
