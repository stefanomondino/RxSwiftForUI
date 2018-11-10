# RxSwiftForUI
Demo Project used during my talk at SwiftHeroes - 2018-11-09

Talk and demo try to focus RxSwift/RxCocoa usage on the UI side rather than the Network chaining one (where, of course, it rocks as well!).

In this repo I've added way more stuff I couldn't show during the talk. You can also find the slides [here](https://github.com/stefanomondino/RxSwiftForUI/blob/master/RxSwift%20for%20UI.pdf)

Storyboard and cell usage is for demo purposes only (I wouldn't suggest to use segues or `UICollectionViewCell`s designed directly inside storyboards)

### Installation

RxSwift and RxCocoa are integrated with Cocoapods.
A usual 
``` 
pod install
```
will do the trick :)

### TOC

- A `TimerViewController` with a simple digital clock on the top and a stop-watch on the bottom. Click on the Start/Stop button top see it in action

- A `ParallaxViewController` with the usual "zoom on overscroll - slowly go away on scroll" effect. Magic happens directly on NSLayoutConstraints, remember to check them out in the storyboard!

- A `CarouselViewController` with an horizontal collection view tied to a PageControl displaying current page (one thing I really like: current page changes *while* scrolling, not after last drag). 
Carousel automatically scrolls to the next page after a couple of seconds but doesn't while you are scrolling.

- A `MapViewController` with a small carousel at the bottom displaying same data as the map. Combining autoscrolling and map centering, map and collection view starts to simultaneously move.


Reactive components are meant to be reused across screens and (why not?) across projects. 
You can find them in the RxExtension.swift file inside the project.
It would be a wise choice to split into more than one huge file if you're planning to use them in your project
Example : `UICollectionView+Rx.swift` or `UIScrollView+Rx.swift` with all the extensions needed

If you have questions or doubts, please contact me or open an issue!
