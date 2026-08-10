//
//  EnvironmentValues+Layout.swift
//  Luminare
//
//  Created by KrLite on 2026/8/10.
//

import SwiftUI

public extension EnvironmentValues {
    @Entry var luminareCornerRadii: RectangleCornerRadii = .init(12)
    @Entry var luminareMinHeight: CGFloat = 32

    @Entry var luminareBorderedStates: LuminareBorderStates = .default
    @Entry var luminareFilledStates: LuminareFillStates = .default
    @Entry var luminareSurfaceStyle: LuminareSurfaceStyle = .plateau
    @Entry var luminareHasDividers: Bool = true

    @Entry var luminareContentMarginsTop: CGFloat = 0
    @Entry var luminareContentMarginsLeading: CGFloat = 0
    @Entry var luminareContentMarginsBottom: CGFloat = 0
    @Entry var luminareContentMarginsTrailing: CGFloat = 0

    // MARK: Form

    @Entry var luminareFormSpacing: CGFloat = 16
    @Entry var luminareFormLayout: LuminareFormLayout = .stacked

    // MARK: Section

    @Entry var luminareSectionLayout: LuminareSectionLayout = .stacked
    @Entry var luminareSectionHorizontalPadding: CGFloat = 8
    @Entry var luminareIsInsideSection: Bool = false
    @Entry var luminareTopLeadingRounded: Bool = true
    @Entry var luminareTopTrailingRounded: Bool = true
    @Entry var luminareBottomLeadingRounded: Bool = true
    @Entry var luminareBottomTrailingRounded: Bool = true

    /// If `0`, the section uses its fixed intrinsic width.
    @Entry var luminareSectionMaxWidth: CGFloat? = .infinity

    // MARK: Button Row

    @Entry var luminareButtonRowSpacing: CGFloat = 4

    // MARK: Compose

    @Entry var luminareComposeControlSize: LuminareComposeControlSize = .automatic
}
