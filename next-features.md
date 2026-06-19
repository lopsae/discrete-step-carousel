Next Features
=============

Documentation release
---------------------
+ Update app with default examples, images, and animated examples.


Future Features
---------------
+ Support for vertical carousel.
+ Migrate state of the carousel to a ratio of the scrolled content. To make this property animatable.
  Currently the main state of the carousel is the selected index, which cannot be animated since it
  is an integer value with no possibility of intermediate values.
+ Make possible to change markLength, and the current selection of the carousel to persist.
+ Use spacers to center selectable views, instead of contentMargins, in order to be able to properly use scrollTransition.
+ Implement different approaches to selection change: currently the selected item is always the one
  which center is closest to the scroll view center, but it could also be changed to when the mark
  crosses the scroll view center. See the stock camera carousel to see this effect in action. 
