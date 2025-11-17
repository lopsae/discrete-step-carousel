import Testing
@testable import DiscreteStepSlider

@Test func example() async throws {
    let parts: [String] = [
        "sphinx",
        "of",
        "black",
        "quartz",
        "judge",
        "my",
        "vow"
    ]

    #expect(parts.joined(separator: " ") == "sphinx of black quartz judge my vow")
}
