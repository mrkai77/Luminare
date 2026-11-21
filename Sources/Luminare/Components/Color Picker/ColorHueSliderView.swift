//
//  ColorHueSliderView.swift
//  Luminare
//
//  Created by Kai Azim on 2024-05-15.
//

import SwiftUI

// MARK: - Color Hue Slider

struct ColorHueSliderView: View {
    // MARK: Environments

    @Environment(\.luminareAnimation) private var animation

    // MARK: Fields

    @Binding var selectedColor: HSBColor
    var roundedTop: Bool = false
    var roundedBottom: Bool = false
    /// Corner radius of the rounded corners of the container that clips this slider.
    var containerCornerRadius: CGFloat = 8

    @State private var selectionPosition: CGFloat = 0
    @State private var selectionOffset: CGFloat = 0
    @State private var selectionWidth: CGFloat = 0

    /// gradient for the color spectrum slider
    private let colorSpectrumGradient: Gradient = .init(
        colors: stride(from: 0.0, through: 1.0, by: 0.01)
            .map { Color(hue: $0, saturation: 1, brightness: 1) }
    )

    // MARK: Body

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                LinearGradient(
                    gradient: colorSpectrumGradient,
                    startPoint: .leading,
                    endPoint: .trailing
                )

                let leadingGap = selectionOffset
                let trailingGap = geo.size.width - selectionOffset - selectionWidth

                UnevenRoundedRectangle(
                    topLeadingRadius: handleCornerRadius(horizontalGap: leadingGap, verticalGap: handleTopGap, rounded: roundedTop),
                    bottomLeadingRadius: handleCornerRadius(horizontalGap: leadingGap, verticalGap: handleBottomGap, rounded: roundedBottom),
                    bottomTrailingRadius: handleCornerRadius(horizontalGap: trailingGap, verticalGap: handleBottomGap, rounded: roundedBottom),
                    topTrailingRadius: handleCornerRadius(horizontalGap: trailingGap, verticalGap: handleTopGap, rounded: roundedTop)
                )
                .frame(width: selectionWidth, height: handleHeight)
                .padding(.bottom, 0.5)
                .offset(x: selectionOffset, y: 0)
                .foregroundColor(.white)
                .shadow(radius: 3)
                .onChange(of: selectionPosition) { position in
                    withAnimation(animation) {
                        selectionOffset = calculateOffset(
                            handleWidth: handleWidth(at: position, geo.size.width),
                            geo.size.width
                        )
                        selectionWidth = handleWidth(at: position, geo.size.width)
                    }
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        handleDragChange(value, geo.size.width)
                    }
            )
            .onAppear {
                selectionPosition = selectedColor.hue * geo.size.width
                selectionOffset = calculateOffset(
                    handleWidth: handleWidth(at: selectionPosition, geo.size.width),
                    geo.size.width
                )
                selectionWidth = handleWidth(at: selectionPosition, geo.size.width)
            }
            .onChange(of: selectedColor) { color in
                selectionPosition = color.hue * geo.size.width
            }
        }
        .frame(height: sliderHeight)
    }

    // MARK: Handle Geometry

    private let sliderHeight: CGFloat = 16
    private let handleHeight: CGFloat = 12.5
    private let handleBottomPadding: CGFloat = 0.5
    private let handleBaseCornerRadius: CGFloat = 2

    /// Gap between the top of the handle and the top of the slider.
    private var handleTopGap: CGFloat {
        (sliderHeight - handleHeight - handleBottomPadding) / 2
    }

    /// Gap between the bottom of the handle and the bottom of the slider.
    private var handleBottomGap: CGFloat {
        handleTopGap + handleBottomPadding
    }

    // MARK: Functions

    private func handleDragChange(_ value: DragGesture.Value, _ viewSize: CGFloat) {
        let lastPercentage = selectionPosition / viewSize

        let clampedX = max(5.5, min(value.location.x, viewSize - 5.5))
        selectionPosition = clampedX
        let percentage = selectionPosition / viewSize

        let edgeTarget = 5.5 / viewSize
        let isAtEdge = abs(percentage - edgeTarget) == 0 || abs(percentage - (1 - edgeTarget)) == 0

        if percentage != lastPercentage, isAtEdge {
            NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .now)
        }

        withAnimation(animation) {
            selectedColor.hue = percentage
        }
    }

    private func calculateOffset(handleWidth: CGFloat, _ viewSize: CGFloat) -> CGFloat {
        let halfWidth = handleWidth / 2
        let adjustedPosition = min(max(selectionPosition, halfWidth), viewSize - halfWidth)
        return adjustedPosition - halfWidth
    }

    private func handleWidth(at position: CGFloat, _ viewSize: CGFloat) -> CGFloat {
        let edgeDistance = min(position, viewSize - position)
        let edgeFactor = 1 - max(0, min(edgeDistance / 10, 1))
        return max(5, min(15, 5 + (6 * edgeFactor)))
    }

    /// Blends a handle corner from its base radius towards the container's corner radius as it approaches that corner.
    ///
    /// This exactly matches how macOS rounds window corners as they approach the rounded display corners of PROLED MacBooks:
    /// `t = min(1 - dx / R, 1 - dy / R)`, and the corner radius becomes `r + t * (R - r)` when `t > 0`,
    /// where `R` is the container's corner radius, `r` is the handle's base radius, and `dx`/`dy` are the gaps between the handle and the container's edges.
    private func handleCornerRadius(horizontalGap: CGFloat, verticalGap: CGFloat, rounded: Bool) -> CGFloat {
        let containerRadius = rounded ? containerCornerRadius : handleBaseCornerRadius
        guard containerRadius > handleBaseCornerRadius else { return handleBaseCornerRadius }

        let progress = min(1 - max(horizontalGap, 0) / containerRadius, 1 - max(verticalGap, 0) / containerRadius)
        guard progress > 0 else { return handleBaseCornerRadius }

        return handleBaseCornerRadius + progress * (containerRadius - handleBaseCornerRadius)
    }
}

// MARK: - Preview

@available(macOS 15.0, *)
#Preview("ColorHueSliderView") {
    @Previewable @State var color: HSBColor = Color.accentColor.hsb

    LuminareSection {
        ColorHueSliderView(selectedColor: $color, roundedTop: true, roundedBottom: true)
    }
    .padding()
}
