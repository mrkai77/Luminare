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

    private lazy var trafficLightButtonSizes: [NSButton: NSSize] = trafficLightButtons.reduce(into: [:]) { sizes, button in
        sizes[button] = button.frame.size
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
        scaleTrafficLightButtons()
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

            let buttonSize = trafficLightButtonSizes[button] ?? button.frame.size
            button.translatesAutoresizingMaskIntoConstraints = false
            trafficLightButtonConstraints.append(contentsOf: [
                button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: titleBarButtonConfiguration.padding),
                button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: xPosition),
                button.widthAnchor.constraint(equalToConstant: buttonSize.width),
                button.heightAnchor.constraint(equalToConstant: buttonSize.height)
            ])
        }
        NSLayoutConstraint.activate(trafficLightButtonConstraints)
    }

    private func scaleTrafficLightButtons() {
        for button in trafficLightButtons {
            let size = button.bounds.size
            let intrinsicSize = button.intrinsicContentSize
            guard size.width > 0, size.height > 0 else {
                continue
            }

            button.wantsLayer = true
            button.layer?.setAffineTransform(.init(
                scaleX: intrinsicSize.width / size.width,
                y: intrinsicSize.height / size.height
            ))
        }
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
