//
//  LuminarePickerMenu.swift
//  Luminare
//
//  Created by Kai Azim on 2026-07-05.
//

import SwiftUI

// MARK: - Picker Menu (Compose)

public struct LuminarePickerMenu<Label, Option, Item>: View
    where Label: View, Option: View, Item: Hashable {
    @Environment(\.luminareSectionHorizontalPadding) private var horizontalPadding

    // MARK: Fields

    @ViewBuilder private var label: () -> Label
    @Binding private var selection: Item
    let items: [Item]
    @ViewBuilder private var itemToView: (Item) -> Option

    // MARK: Initializers

    public init(
        selection: Binding<Item>,
        items: [Item],
        @ViewBuilder itemToView: @escaping (Item) -> Option,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.label = label
        self._selection = selection
        self.items = items
        self.itemToView = itemToView
    }

    @_disfavoredOverload
    public init(
        _ title: some StringProtocol,
        selection: Binding<Item>,
        items: [Item],
        @ViewBuilder itemToView: @escaping (Item) -> Option
    ) where Label == Text {
        self.init(
            selection: selection,
            items: items,
            itemToView: itemToView
        ) {
            Text(title)
        }
    }

    public init(
        _ titleKey: LocalizedStringKey,
        selection: Binding<Item>,
        items: [Item],
        @ViewBuilder itemToView: @escaping (Item) -> Option
    ) where Label == Text {
        self.init(
            selection: selection,
            items: items,
            itemToView: itemToView
        ) {
            Text(titleKey)
        }
    }

    // MARK: Body

    public var body: some View {
        LuminareCompose {
            HStack(spacing: 8) {
                itemToView(selection)

                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption2)
                    .padding(4)
                    .luminareSurface()
                    .luminareCornerRadius(8)
            }
            .overlay {
                Picker("", selection: $selection) {
                    ForEach(items, id: \.self) { item in
                        itemToView(item)
                            .tag(item)
                    }
                }
                .opacity(0.001)
                .fixedSize()
                .contentShape(.rect)
            }
        } label: {
            label()
        }
    }
}

// MARK: - Preview

@available(macOS 15.0, *)
#Preview(
    "LuminarePickerMenu",
    traits: .sizeThatFitsLayout
) {
    @Previewable @State var selection = "First"
    let items = ["First", "Second", "Third"]

    LuminareSection {
        LuminarePickerMenu(
            "Picker Menu",
            selection: $selection,
            items: items
        ) { item in
            Text(item)
        }
    }
    .frame(width: 300)
}
