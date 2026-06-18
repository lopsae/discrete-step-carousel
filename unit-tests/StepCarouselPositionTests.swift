//
//  DiscreteStepCarouselTests
//  Created by Maic Lopez Saenz.
//


@testable import DiscreteStepCarousel

import Testing


struct StepCarouselPositionTests {


    // MARK: Initialization with selectedValue

    @Test func initialSelectedValue() {
        let position = StepCarouselPosition(
            values: ["zero", "one", "two", "three", "four"],
            selectedValue: "two"
        )

        #expect(position.selectedIndex == 2)
        #expect(position.selectedValue == "two")
        #expect(position.values == ["zero", "one", "two", "three", "four"])
    }


    @Test func initialSelectedValueNotFound_defaultsToFirst() {
        let position = StepCarouselPosition(
            values: ["zero", "one", "two"],
            selectedValue: "none"
        )

        #expect(position.selectedIndex == 0)
        #expect(position.selectedValue == "zero")
        #expect(position.values == ["zero", "one", "two"])
    }


    @Test func initialSelectedValueDuplicate_selectsFirstOccurrence() {
        let position = StepCarouselPosition(
            values: ["zero", "repeat", "two", "repeat", "four"],
            selectedValue: "repeat"
        )

        #expect(position.selectedIndex == 1)
        #expect(position.selectedValue == "repeat")
        #expect(position.values == ["zero", "repeat", "two", "repeat", "four"])
    }


    // MARK: - Initialization with selectedIndex

    @Test func initialSelectedIndex() {
        let position = StepCarouselPosition(
            values: ["zero", "one", "two", "three", "four"],
            selectedIndex: 3
        )

        #expect(position.selectedIndex == 3)
        #expect(position.selectedValue == "three")
        #expect(position.values == ["zero", "one", "two", "three", "four"])
    }


    @Test func noInitialSelectedIndex_defaultsToFirst() {
        let position = StepCarouselPosition(values: ["zero", "one", "two"])

        #expect(position.selectedIndex == 0)
        #expect(position.selectedValue == "zero")
        #expect(position.values == ["zero", "one", "two"])
    }


    // MARK: Layout properties

    @Test func defaultMarkLengthAndSpacing() {
        let position = StepCarouselPosition(values: ["zero", "one", "two"])

        #expect(position.markLength == StepCarouselDefaults.markLength)
        #expect(position.markLength == 22)
        #expect(position.spacing == .zero)
        #expect(position.totalMarkLength == 22)
    }


    @Test func customMarkLengthAndSpacing() {
        let position = StepCarouselPosition(
            values: ["zero", "one", "two"],
            markLength: 20,
            spacing: 4
        )

        #expect(position.markLength == 20)
        #expect(position.spacing == 4)
        #expect(position.totalMarkLength == 24)
    }


    // MARK: selectIndex

    @Test func selectIndex_updatesImmediately() {
        var position = StepCarouselPosition(
            values: ["zero", "one", "two", "three", "four"],
            markLength: 20,
            spacing: 4
        )

        position.selectIndex(3)

        #expect(position.selectedIndex == 3)
        #expect(position.scrollPosition.x == 72)

        // selectedValue does NOT get updated.
        #expect(position.selectedValue == "zero")
    }


    @Test func selectIndexNotImmediate_doesNotUpdate() {
        var position = StepCarouselPosition(
            values: ["zero", "one", "two", "three", "four"],
            markLength: 20,
            spacing: 4
        )

        position.selectIndex(3, immediate: false)

        #expect(position.scrollPosition.x == 72)

        // Not updated.
        #expect(position.selectedIndex == 0)
        #expect(position.selectedValue == "zero")

    }


    // FIXME: Invalid selectIndex


    @Test func selectIndex_invalidIndex_noChange() {
        var position = StepCarouselPosition(values: ["zero", "one", "two"])

        position.selectIndex(5)

        #expect(position.selectedIndex == 0)
        #expect(position.selectedValue == "zero")
    }


    @Test func selectIndex_negativeIndex_noChange() {
        var position = StepCarouselPosition(values: ["zero", "one", "two"])

        position.selectIndex(-1)

        #expect(position.selectedIndex == 0)
        #expect(position.selectedValue == "zero")
    }


    @Test func selectIndex_toFirstIndex() {
        var position = StepCarouselPosition(
            values: ["zero", "one", "two"],
            selectedIndex: 2,
            markLength: 20
        )

        position.selectIndex(0)

        #expect(position.selectedIndex == 0)
        #expect(position.scrollPosition.x == 0)
    }


    @Test func selectIndex_toLastIndex() {
        var position = StepCarouselPosition(
            values: ["zero", "one", "two"],
            markLength: 20
        )

        position.selectIndex(2)

        #expect(position.selectedIndex == 2)
        #expect(position.scrollPosition.x == 40)
    }


    // MARK: selectValue

    @Test func selectValue_updatesSelectedValueAndIndex() {
        var position = StepCarouselPosition(
            values: ["zero", "one", "two", "three", "four"],
            markLength: 20
        )

        position.selectValue("two")

        #expect(position.selectedIndex == 2)
        #expect(position.selectedValue == "two")
        #expect(position.scrollPosition.x == 40.0)
    }


    @Test func selectValue_notImmediate_doesNotUpdateSelectedValueOrIndex() {
        var position = StepCarouselPosition(
            values: ["zero", "one", "two", "three", "four"],
            markLength: 20
        )

        position.selectValue("two", immediate: false)

        #expect(position.scrollPosition.x == 40)

        // Not updated.
        #expect(position.selectedIndex == 0)
        #expect(position.selectedValue == "zero")
    }


    @Test func selectValue_notFound_noChange() {
        var position = StepCarouselPosition(values: ["zero", "one", "two"])

        position.selectValue("none")

        #expect(position.selectedIndex == 0)
        #expect(position.selectedValue == "zero")
    }


    @Test func selectValue_duplicate_selectsFirstOccurrence() {
        var position = StepCarouselPosition(
            values: ["zero", "repeat", "two", "repeat", "four"],
            markLength: 20
        )

        position.selectValue("repeat")

        #expect(position.selectedIndex == 1)
        #expect(position.scrollPosition.x == 20.0)
    }


    // MARK: Sequential selections update scrollPosition

    @Test func multipleSelectIndex_updatesScrollPositionEachTime() {
        var position = StepCarouselPosition(
            values: ["zero", "one", "two", "three", "four"],
            markLength: 10,
        )

        position.selectIndex(2)
        #expect(position.scrollPosition.x == 20)

        position.selectIndex(4)
        #expect(position.scrollPosition.x == 40)

        position.selectIndex(0)
        #expect(position.scrollPosition.x == 0)
    }


    @Test func multipleSelectValue_updatesScrollPositionEachTime() {
        var position = StepCarouselPosition(
            values: ["zero", "one", "two", "three", "four"],
            markLength: 10.0,
        )

        position.selectValue("two")
        #expect(position.scrollPosition.x == 20)

        position.selectValue("four")
        #expect(position.scrollPosition.x == 40)

        position.selectValue("zero")
        #expect(position.scrollPosition.x == 0)
    }


    // FIXME: add tests with collections with offset indexes

}
