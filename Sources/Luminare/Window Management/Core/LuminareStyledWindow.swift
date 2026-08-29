//
//  LuminareStyledWindow.swift
//  Luminare
//
//  Created by Kai Azim on 2026-05-10.
//

import AppKit

open class LuminareStyledWindow: NSWindow {
    private lazy var trafficLightButtons: [NSButton] = [
        .closeButton,
        .miniaturizeButton,
        .zoomButton
    ].compactMap { type in
        standardWindowButton(type)
    }

    private lazy var trafficLightButtonMetrics: [NSButton: (size: NSSize, intrinsic: NSSize)] = trafficLightButtons
        .reduce(into: [:]) { metrics, button in
            metrics[button] = (button.frame.size, button.intrinsicContentSize)
        }

    private var trafficLightButtonConstraints: [NSLayoutConstraint] = []
    private weak var constrainedContentView: NSView?

    public var titleBarButtonConfiguration: LuminareTitleBarButtonConfiguration? = .default {
        didSet {
            constrainedContentView = nil
            relocateTrafficLights()
        }
    }

    public var luminareCornerRadius: CGFloat = LuminareStyledWindow.defaultCornerRadius

    override open func layoutIfNeeded() {
        super.layoutIfNeeded()
        relocateTrafficLights()
    }

    @objc dynamic var _cornerRadius: CGFloat {
        luminareCornerRadius
    }

    public static var defaultCornerRadius: CGFloat {
        if #available(macOS 27, *) {
            16
        } else if #available(macOS 26, *) {
            24
        } else {
            12
        }
    }

    func relocateTrafficLights() {
        guard titleBarButtonConfiguration != nil else {
            NSLayoutConstraint.deactivate(trafficLightButtonConstraints)
            trafficLightButtonConstraints.removeAll()
            constrainedContentView = nil
            for button in trafficLightButtons {
                button.isHidden = true
            }
            return
        }

        relocateTrafficLightButtons()
        refreshTrafficLightTrackingAreas()
    }

    private func relocateTrafficLightButtons() {
        guard let contentView, let titleBarButtonConfiguration else {
            return
        }

        guard !trafficLightButtonsAreConstrained(to: contentView) else {
            return
        }

        NSLayoutConstraint.deactivate(trafficLightButtonConstraints)
        trafficLightButtonConstraints.removeAll()
        constrainedContentView = contentView

        // Opting a button out of autoresizing below replaces its frame, so the
        // native geometry has to be captured while every button is still untouched
        let metrics = trafficLightButtonMetrics

        let nativeButtonAreaWidth = (trafficLightButtons.last?.frame.minX ?? 0) - (trafficLightButtons.first?.frame.minX ?? 0)
        let buttonSpacing = titleBarButtonConfiguration.spacing > 0
            ? titleBarButtonConfiguration.spacing
            : nativeButtonAreaWidth / CGFloat(trafficLightButtons.count - 1)
        let buttonAreaWidth = CGFloat(trafficLightButtons.count - 1) * buttonSpacing

        for (index, button) in trafficLightButtons.enumerated() {
            button.isHidden = false

            if button.superview != contentView {
                button.removeFromSuperview()
                contentView.addSubview(button)
            }

            let xPosition: CGFloat = if windowTitlebarLayoutDirection == .leftToRight {
                titleBarButtonConfiguration.padding + CGFloat(index) * buttonSpacing
            } else {
                titleBarButtonConfiguration.padding + (buttonAreaWidth - CGFloat(index) * buttonSpacing)
            }

            button.translatesAutoresizingMaskIntoConstraints = false

            let native = metrics[button]
            let buttonSize: NSSize = if let native, native.intrinsic.width > 0, native.intrinsic.height > 0 {
                native.intrinsic
            } else {
                native?.size ?? button.frame.size
            }

            trafficLightButtonConstraints.append(contentsOf: [
                button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: titleBarButtonConfiguration.padding),
                button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: xPosition),
                button.widthAnchor.constraint(equalToConstant: buttonSize.width),
                button.heightAnchor.constraint(equalToConstant: buttonSize.height)
            ])
        }

        NSLayoutConstraint.activate(trafficLightButtonConstraints)
    }

    private func trafficLightButtonsAreConstrained(to contentView: NSView) -> Bool {
        constrainedContentView === contentView
            && !trafficLightButtonConstraints.isEmpty
            && trafficLightButtonConstraints.allSatisfy(\.isActive)
            && trafficLightButtons.allSatisfy { button in
                button.superview === contentView && !button.isHidden
            }
    }

    // Reference: https://github.com/Automattic/simplenote-macos/blob/7b1d6d736e337ec99fb8f3c5e2ab973040b2ac9b/Simplenote/Window.swift#L148
    private func refreshTrafficLightTrackingAreas() {
        guard let themeView = contentView?.superview else {
            return
        }

        themeView.viewWillStartLiveResize()
        themeView.viewDidEndLiveResize()
    }

    override open var canBecomeKey: Bool {
        true
    }

    override open var canBecomeMain: Bool {
        true
    }
}
