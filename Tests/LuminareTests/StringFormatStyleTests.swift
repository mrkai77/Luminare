@testable import Luminare
import SwiftUI
import Testing

struct StringFormatStyleTests {
    @Test func identityStrategyPreservesInput() throws {
        let style = StringFormatStyle()
        let value = "Luminare #42ab0E"

        #expect(style.format(value) == value)
        #expect(try style.parseStrategy.parse(value) == value)
    }

    @Test func hexStrategiesNormalizeAndFilterInput() throws {
        let value = " #42-ab:0E "

        #expect(try StringFormatStyle.HexStrategy.lowercased.parse(value) == "42ab0e")
        #expect(try StringFormatStyle.HexStrategy.uppercased.parse(value) == "42AB0E")
        #expect(try StringFormatStyle.HexStrategy.lowercasedWithWell.parse(value) == "#42ab0e")
        #expect(try StringFormatStyle.HexStrategy.uppercasedWithWell.parse(value) == "#42AB0E")
    }

    @Test func customHexStrategyAppliesCaseAndPrefix() throws {
        let value = "#42ab0E"

        #expect(
            try StringFormatStyle.HexStrategy.custom(.lowercase, "$").parse(value) == "$42ab0e"
        )
        #expect(
            try StringFormatStyle.HexStrategy.custom(.uppercase, "0x").parse(value) == "0x42AB0E"
        )
    }
}
