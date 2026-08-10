//
//  EnvironmentValues+Window.swift
//  Luminare
//
//  Created by KrLite on 2026/8/10.
//

import SwiftUI

public extension EnvironmentValues {
    // MARK: Modal

    @Entry var luminareModalStyle: LuminareModalStyle = .sheet
    @Entry var luminareModalCornerRadius: CGFloat = 12
    @Entry var luminareModalPresentation: LuminareModalPresentation = .windowCenter
    @Entry var luminareModalClosesOnDefocus: Bool = false
    @Entry var luminareIsInsideModal: Bool = false

    // MARK: Title Bar

    /// A naming convention: `titleBar` for SwiftUI, `titlebar` for AppKit, and `title bar` for natural language.
    @Entry var luminareTitleBarHeight: CGFloat = 50

    // MARK: Sidebar

    @Entry var luminareSidebarOverflow: CGFloat = 50
}
