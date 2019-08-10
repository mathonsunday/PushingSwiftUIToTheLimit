# [fit] From UIKit to SwiftUI

## Veronica Ray
## Senior Software Engineer at Compass

---

# Goal

Rewrite a range slider from UIKit and Core Graphics into SwiftUI

---

# Compass RangeSeekSlider

* Based on an open source project
* Heavily modified to remove features we didn't need and to follow our coding style

---

![inline](rangeSeekSliderGitHub.png)

---

![inline](rangeSeekSliderDemo.gif)

---

|| Lines of code | 
| --- | :-----------: | :-----------:|
|RangeSeekSlider | 360 | 
|RangeSeekSliderViewModel | 120 | 

---

# [fit] Shapes
# [fit] Gestures

---
# [fit] Start Simple 
# [fit] And Get The 
# [fit] Little Details Right

---

![fit](rockClimbingWall.jpg)

---

# [fit] Native 
# [fit] UISlider

---

# Goals

* Correct padding on left and right side
* Formatted text that displays the selected value 

---

![inline](UISliderDemo.gif)

---

# [fit] Dependency Injection 
# [fit] With Views

---

# This Will Not Compile

```swift
struct TestSlider : View {
    @State var selectedValue: CGFloat = 0.0
    @State var numberFormatter: NumberFormatter
    
    init(numberFormatter: NumberFormatter = NumberFormatter.createNumberFormatter()) {
        self.numberFormatter = numberFormatter
    }
    
    var body: some View {
		// removed for brevity
    }
}
```

---

> `@State` variables in SwiftUI should not be initialized from data you pass down through the initializer...
-- Joe Groff, Senior Swift Compiler Engineer, [Swift Forums](https://forums.swift.org/t/state-messing-with-initializer-flow/25276) 

---

> ...since the model is maintained outside of the view, there is no guarantee that the value will really be used.
-- Joe Groff, Senior Swift Compiler Engineer, [Swift Forums](https://forums.swift.org/t/state-messing-with-initializer-flow/25276) 

---

# [fit] `@State` Is Primarily 
# [fit] Intended For 
# [fit] Small-Scale UI State

---

```swift
struct TestSlider: View {
    @State private var selectedValue: CGFloat = 0.0
    private let numberFormatter: NumberFormatter
    private let minValue: CGFloat
    private let maxValue: CGFloat
    private let step: CGFloat
    
    init(rangeType: RangeType) {
        self.numberFormatter = rangeType.numberFormatter
        self.minValue = rangeType.minValue
        self.maxValue = rangeType.maxValue
        self.step = rangeType.step
    }
    
    var body: some View {
        VStack {
            Slider(value: $selectedValue, from: minValue, through: maxValue, by: step)
                .padding()
            Text(numberFormatter.string(from: selectedValue as NSNumber) ?? "")
        }
    }
}
```

---

![inline](multipleSliders.gif)

---

# [fit] Why Not Use `@BindableObject`?

* numberFormatter, min, max and step aren't going to change once you initialize the slider
* Only one view needs access to these values

---

# [fit] CGFloats?!

---

# I thought we were breaking from tradition...

# And leaving behind old baggage that didn't serve us well...

---

![inline](CGFloatTwitterDiscussion.png)

---

# Joe Groff's Response

* CGFloat is still single-precision in arm64_32, which is necessary for any retina display, or a non-retina display bigger than 1024x768.
 
* It's too late for shipping ABIs. 

* "change CGFloat.h so that CGFloat is always double on not-yet-defined platforms" might be a good action to take.

---

# [fit] Simple
# [fit] Gestures

---

```swift
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		// calculations 
		
        guard isTouchingLeftHandle || isTouchingRightHandle else {
            return false
        }
		// assign handleTracking to .left or .right
		
        return true
    }
```

---

```swift
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        handleTracking = .none
        initialTouchPoint = CGPoint.zero
        strokePhase = .notStarted
        trackedTouch = nil
    }
```

---

>  SwiftUI doesn't invoke the updating callback when the user ends or cancels a gesture. Instead, the gesture state property automatically resets its state back to its initial value.
-- SwiftUI Documentation

---

>  SwiftUI only invokes the `onEnded(_:)` callback when the gesture succeeds.
-- SwiftUI Documentation

---

```swift
var body: some View {
        let minimumLongPressDuration = 0.5
        let longPressDrag = LongPressGesture(minimumDuration: minimumLongPressDuration)
            .sequenced(before: DragGesture())
            .updating($dragState) { value, state, transaction in
                switch value {
                // Long press begins.
                case .first(true):
                    state = .pressing
                // Long press confirmed, dragging may begin.
                case .second(true, let drag):
                    state = .dragging(translation: drag?.translation ?? .zero)
                // Dragging ended or the long press cancelled.
                default:
                    state = .inactive
                }
            }
            .onEnded { value in
                guard case .second(true, let drag?) = value else { return }
                self.viewState.width += drag.translation.width
                self.viewState.height += drag.translation.height
            }
```

---

![](boatStuck.jpg)

---

# [fit] Improve Conceptual 
# [fit] Understanding

---

![inline](cocoaWithLove.png)

---

# [fit] Moving From 
# [fit] "How Do I 
# [fit] Do X  In Y?"

---

# [fit] To 
# [fit] "What's The 
# [fit] New X?"

---

# Where is `UIControl`? 

# Where are `beginTracking`/`continueTracking`/`endTracking`? I have to override them in my new class, right?

---

# [fit] There's no 
# [fit] more 
# [fit] `UIControl`.
# [fit] Use a View.

---


# We now call `updating`, `onChanged` and `onEnd` functions on `Gesture` instead of overriding any functions on our class.

---

# [fit] RangeSeekSlider 
# [fit] Without Gestures

---

![fit](buildingCustomViews.png)

---

* We no longer have a `UIKit` and `Core Graphics` separation
* Everything in SwiftUI is a `View`

---

![inline](doubleSliderNoGesture.png)

---

```swift
struct ContentView : View {
    var body: some View {
        return HStack(spacing: 0) {
            Circle()
                .fill(Color.purple)
                .frame(width: 24, height: 24, alignment: .center)
                .zIndex(1)
            Rectangle()
                .frame(width: CGFloat(300.0), height: CGFloat(1.0), alignment: .center)
                .zIndex(0)
            Circle()
                .fill(Color.purple)
                .frame(width: 24, height: 24, alignment: .center)
                .zIndex(1)
        }
    }
}
```

---

# [fit] RangeSeekSlider 
# [fit] With Gestures

---

```swift
struct ContentView : View {
    @State var leftHandleViewState = CGSize.zero
    @State var rightHandleViewState = CGSize.zero
    var body: some View {
        let leftHandleDragGesture = DragGesture(minimumDistance: 1, coordinateSpace: .local)
            .onChanged { value in
                guard value.location.x >= 0 else {
                    return
                }
                self.leftHandleViewState.width = value.location.x
        }
        let rightHandleDragGesture = DragGesture(minimumDistance: 1, coordinateSpace: .local)
            .onChanged { value in
                guard value.location.x <= 0 else {
                    return
                }
                self.rightHandleViewState.width = value.location.x
        }
        return HStack(spacing: 0) {
            Circle()
                .fill(Color.purple)
                .frame(width: 24, height: 24, alignment: .center)
                .offset(x: leftHandleViewState.width, y: 0)
                .gesture(leftHandleDragGesture)
                .zIndex(1)
            Rectangle()
                .frame(width: CGFloat(300.0), height: CGFloat(1.0), alignment: .center)
                .zIndex(0)
            Circle()
                .fill(Color.purple)
                .frame(width: 24, height: 24, alignment: .center)
                .offset(x: rightHandleViewState.width, y: 0)
                .gesture(rightHandleDragGesture)
                .zIndex(1)
        }
    }
}
```

---

```swift
    private func xPositionAlongLine(for value: CGFloat) -> CGFloat {
        let percentage = percentageAlongLine(for: value)
        let maxMinDif = sliderLine.frame.maxX - sliderLine.frame.minX
        let offset = percentage * maxMinDif
        return sliderLine.frame.minX + offset
    }
    
    private func percentageAlongLine(for value: CGFloat) -> CGFloat {
        guard viewModel.minValue < viewModel.maxValue else {
            return 0
        }
        let maxMinDif = viewModel.maxValue - viewModel.minValue
        let valueSubtracted = value - viewModel.minValue
        return valueSubtracted / maxMinDif
    }
```

---

|Lines Of Code| UIKit | SwiftUI | 
| --- | :-----------: | :-----------:|
|Determine which handle was being dragged | 20 | 0 |
|Set the x position of the handle during the drag gesture | 14 | 6 |

---

# Continuously Refine The UI

* Change `minimumDistance` of gestures to 1
* Guard against touch location to make sure handles are always on the line

---

# [fit] Your Knowledge 
# [fit] Portfolio

---

![](investment.jpg)


---

# Declarative UI Frameworks Are Not New

TODO: make a little timeline showing the history of declarative UI frameworks

* Lithio  https://code.fb.com/android/open-sourcing-litho-a-declarative-ui-framework-for-android/
* Layout https://github.com/nicklockwood/layout
* Flutter: https://flutter.dev/docs/get-started/flutter-for/declarative
* ComponentKit https://code.fb.com/ios/introducing-componentkit-functional-and-declarative-ui-on-ios/


---

If you've been experimenting with declarative UI frameworks like Flutter already...

If you've ben doing reactive programming already...

Then picking up SwiftUI will be easier.

---

# [fit] SwiftUI Should Be 
# [fit] Open Sourced

---

> ...the nature of larger declarative systems is such that API documentation will never fill-in all the details... 
-- "First impressions of SwiftUI" by Matt Gallagher

---

> ...there is too much behavior that does not manifest through the interface.
-- "First impressions of SwiftUI" by Matt Gallagher

---

# [fit] www.nerdonica.com
# [fit] @nerdonica

        
        





