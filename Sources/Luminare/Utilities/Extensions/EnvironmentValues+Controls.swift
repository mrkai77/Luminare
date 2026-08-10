//
//  EnvironmentValues+Controls.swift
//  Luminare
//
//  Created by KrLite on 2026/8/10.
//

import SwiftUI

public extension EnvironmentValues {
    // MARK: Color Picker

    @Entry var luminareColorPickerHasCancel: Bool = false
    @Entry var luminareColorPickerHasDone: Bool = false

    // MARK: Tool Tip

    @Entry var luminareToolTipTrigger: LuminareToolTipTrigger = .hover
    @Entry var luminareToolTipShade: LuminareToolTipShade = .styled

    // MARK: Stepper

    @available(macOS 15.0, *)
    @Entry var luminareStepperAlignment: LuminareStepperAlignment = .trailing
    @available(macOS 15.0, *)
    @Entry var luminareStepperDirection: LuminareStepperDirection = .horizontal

    // MARK: Compact Picker

    @Entry var luminareCompactPickerStyle: LuminareCompactPickerStyle = .menu

    // MARK: List

    @Entry var luminareListItemCornerRadii: RectangleCornerRadii = .init(2)
    @Entry var luminareListItemHeight: CGFloat = 50
    @Entry var luminareListItemHighlightOnHover: Bool = false
    @Entry var luminareItemBeingHovered: Bool = false
    @Entry var luminareListFixedHeightUntil: CGFloat? = nil

    // MARK: Slider

    @Entry var luminareSliderLayout: LuminareSliderLayout = .regular

    // MARK: Slider Picker

    @Entry var luminareSliderPickerLayout: LuminareSliderPickerLayout = .regular
}
