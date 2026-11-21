//
//  LuminareCustomCornerRadiusWindow.swift
//  Luminare
//
//  Created by Kai Azim on 2026-11-21.
//

import SwiftUI

/// A ``LuminareWindow`` with a specific corner radius.
///
/// This overrides AppKit's private `_cornerRadius`. An overridden corner radius takes precedence over the system's,
/// so macOS no longer adjusts it, such as rounding the window's corners to match a display's rounded corners.
/// Prefer ``LuminareWindow`` unless a specific corner radius is needed.
public final class LuminareCustomCornerRadiusWindow: LuminareWindow {
    /// The window's corner radius.
    public var luminareCornerRadius: CGFloat

    /// Initializes a ``LuminareCustomCornerRadiusWindow``.
    ///
    /// - Parameters:
    ///   - cornerRadius: The window corner radius.
    ///   - titleBarButtonConfiguration: The titlebar button padding and spacing.
    ///   - content: the content view of the window, wrapped in a ``LuminareView``.
    public convenience init(
        cornerRadius: CGFloat,
        titleBarButtonConfiguration: LuminareTitleBarButtonConfiguration? = .default,
        content: @escaping () -> some View
    ) {
        self.init(
            _internalConfiguration: (),
            cornerRadius: cornerRadius,
            titleBarButtonConfiguration: titleBarButtonConfiguration,
            content: content
        )
    }

    init(
        _internalConfiguration _: () = (),
        cornerRadius: CGFloat,
        titleBarButtonConfiguration: LuminareTitleBarButtonConfiguration? = .default,
        canBecomeMain: Bool = true,
        closesOnDefocus: Bool = false,
        initialOrigin: ((CGRect) -> CGPoint)? = nil,
        onClose: (() -> ())? = nil,
        content: @escaping () -> some View
    ) {
        // Set before `super.init`, since AppKit can read `_cornerRadius` while the window is being set up
        self.luminareCornerRadius = cornerRadius

        super.init(
            _internalConfiguration: (),
            titleBarButtonConfiguration: titleBarButtonConfiguration,
            canBecomeMain: canBecomeMain,
            closesOnDefocus: closesOnDefocus,
            initialOrigin: initialOrigin,
            onClose: onClose,
            content: content
        )
    }

    @objc dynamic var _cornerRadius: CGFloat {
        luminareCornerRadius
    }
}
