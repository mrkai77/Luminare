//
//  EnvironmentValues+Common.swift
//  Luminare
//
//  Created by KrLite on 2026/8/10.
//

import SwiftUI

// MARK: - Internal

extension EnvironmentValues {
    @Entry var luminareClickedOutside: Bool = false
}

// MARK: - Common

public extension EnvironmentValues {
    /// The tint used by Luminare components.
    ///
    /// SwiftUI does not expose the value applied by `.tint()`, so this value must remain synchronized with it.
    @Entry var luminareTintColor: Color = .accentColor

    @Entry var luminareAnimation: Animation = .smooth(duration: 0.2)
    @Entry var luminareAnimationFast: Animation = .easeInOut(duration: 0.1)

    @Entry var luminareDismiss: () -> () = {}
}
