import Testing
@testable import DiscreteStepCarousel


struct DiscreteStepCarouselTests {

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

}
