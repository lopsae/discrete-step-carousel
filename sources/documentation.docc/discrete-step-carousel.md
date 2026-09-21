# ``DiscreteStepCarousel``

A control for selecting a value from a collection, with each value represented by a view in a
scrollable surface.

## Overview

The ``StepCarousel`` control displays a scrollable sequence of views where each view represents a
value in a collection. The user can scroll through these views to select one value at a time.

@Video(
    source: "animated-demo.mov",
    alt: "Demonstration video of a Step Carousel scrolling through different values.",
)

The control is configured through a ``StepCarouselPosition``, which defines the selectable values,
layout properties, and provides access to read and modify the current selected value.

```swift
@State var position = StepCarouselPosition(
    values: ["N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X"],
    selectedValue: "S"
)

// ...
    
Text(position.selectedValue)
StepCarousel(position: $position)
    .frame(height: StepCarouselDefaults.markHeight)
Text(position.selectedIndex.description)
    .font(.caption)
```
![Step Carousel control using the default marks, currently selecting the mark associated with S.](step-carousel-with-default-mark)


## Topics

### Carousel Control

+ ``StepCarousel``
+ ``StepCarouselPosition``


### Marks
+ ``DefaultMark``
