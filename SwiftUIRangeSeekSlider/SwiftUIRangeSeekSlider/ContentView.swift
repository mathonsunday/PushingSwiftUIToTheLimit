//
//  ContentView.swift
//  SwiftUIRangeSeekSlider
//
//  Created by Veronica Ray on 6/16/19.
//  Copyright © 2019 Veronica Ray. All rights reserved.
//

import SwiftUI

struct ContentView : View {
    var body: some View {
        Text("Hello World")
    }
    
    class RangeSeekSlider: UIControl {
        private enum HandleTracking {
            case none
            case left
            case right
            case overlap
        }
        
        public let valueChanged = Observable<(Double?, Double?)>()
    
        private let sliderContainer = UIView()
        private let leftLabel = UILabel()
        private let rightLabel = UILabel()
        private let lineHeight: CGFloat = 2
        private let handleColor: UIColor = .white
        private let handleBorderColor: UIColor = .gray30
        private let handleDiameter: CGFloat = 24
        private var handleTracking: HandleTracking = .none
        private let sliderLine = CALayer()
        private let sliderLineBetweenHandles = CALayer()
        private let leftHandle = CALayer()
        private let rightHandle = CALayer()
        private let viewModel = RangeSeekSliderViewModel()
        
        private var displayName = "Price"
        private var stepRules: [ClosedRange<CGFloat>: CGFloat] = [
        50_000...2_000_000: 50_000,
        2_000_001...7_900_000: 100_000
        ]
        private var leftStep: CGFloat = 0
        private var rightStep: CGFloat = 0
        
        override init(frame: CGRect) {
            super.init(frame: .zero)
            let labelContainer = UIView()
            addSubview(labelContainer) { make in
                make.top.equalTo(self).inset(24)
                make.left.equalTo(self).inset(16)
                make.right.equalTo(self).inset(16)
                make.height.equalTo(24)
            }
            labelContainer.isUserInteractionEnabled = false
            
            leftLabel.font = .compassSansMedium(16)
            labelContainer.addSubview(leftLabel) { make in
                make.left.top.equalTo(labelContainer)
            }
            
            rightLabel.font = .compassSansRegular(16)
            labelContainer.addSubview(rightLabel) { make in
                make.right.top.equalTo(labelContainer)
            }
            
            addSubview(sliderContainer) { make in
                make.top.equalTo(labelContainer.snp.bottom).offset(8)
                make.left.right.equalTo(labelContainer).inset(2)
                make.bottom.equalTo(self)
                make.height.equalTo(28)
            }
            sliderContainer.isUserInteractionEnabled = false
            
            sliderContainer.layer.addSublayer(sliderLine)
            sliderContainer.layer.addSublayer(sliderLineBetweenHandles)
            
            let handleBorderWidth: CGFloat = 1
            
            leftHandle.cornerRadius = handleDiameter / 2
            leftHandle.borderWidth = handleBorderWidth
            sliderContainer.layer.addSublayer(leftHandle)
            
            rightHandle.cornerRadius = handleDiameter / 2
            rightHandle.borderWidth = handleBorderWidth
            sliderContainer.layer.addSublayer(rightHandle)
            
            sliderLine.name = "sliderLine"
            sliderLineBetweenHandles.name = "sliderLineBetweenHandles"
            leftHandle.name = "leftHandle"
            rightHandle.name = "rightHandle"
            tintColor = .pandora
            updateLineHeight()
            refresh()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private var enableStep: Bool {
            return !stepRules.isEmpty
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            if handleTracking == .none {
                updateHandleFrame()
                updateLineHeight()
                updateLabelValues()
                updateColors()
                updateHandlePositions()
            }
        }
        
        override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
            let touchLocation = touch.location(in: self)
            let handleTapTargetInset: CGFloat = -10
            let isTouchingLeftHandle: Bool = leftHandle.frame.offsetBy(dx: sliderContainer.frame.minX, dy: sliderContainer.frame.minY).insetBy(dx: handleTapTargetInset, dy: handleTapTargetInset).contains(touchLocation)
            let isTouchingRightHandle: Bool = rightHandle.frame.offsetBy(dx: sliderContainer.frame.minX, dy: sliderContainer.frame.minY).insetBy(dx: handleTapTargetInset, dy: handleTapTargetInset).contains(touchLocation)
            
            guard isTouchingLeftHandle || isTouchingRightHandle else {
                return false
            }
            
            let distanceFromLeftHandle = touchLocation.distance(to: leftHandle.frame.center)
            let distanceFromRightHandle = touchLocation.distance(to: rightHandle.frame.center)
            
            if distanceFromLeftHandle < distanceFromRightHandle {
                handleTracking = .left
            } else if viewModel.selectedMaxValue == viewModel.maxValue && leftHandle.frame.midX == rightHandle.frame.midX {
                handleTracking = .left
            } else {
                handleTracking = .right
            }
            
            return true
        }
        
        override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
            guard handleTracking != .none else {
                return false
            }
            
            let location = touch.location(in: self)
            let percentage = (location.x - sliderLine.frame.minX - handleDiameter / 2) / (sliderLine.frame.maxX - sliderLine.frame.minX)
            let selectedValue = percentage * (viewModel.maxValue - viewModel.minValue) + viewModel.minValue
            
            switch handleTracking {
            case .left:
                viewModel.selectedMinValue = min(selectedValue, viewModel.selectedMaxValue)
            case .right:
                viewModel.selectedMaxValue = max(selectedValue, viewModel.selectedMinValue)
            case .overlap:
                let newPoint = touch.location(in: self)
                guard touch == viewModel.trackedTouch else {
                    return false
                }
                if viewModel.strokePhase == RangeSeekSliderViewModel.SlidePhases.initialPoint {
                    let direction = viewModel.directionOfTouches(for: newPoint)
                    guard direction != .none else {
                        viewModel.resetTouchTracking()
                        return false
                    }
                    viewModel.strokePhase = .sliding(direction: direction)
                    handleSlide(in: direction, for: selectedValue)
                } else if !viewModel.newPointInCorrectDirection(newPoint: newPoint) {
                    viewModel.resetTouchTracking()
                    return false
                }
            case .none:
                break
            }
            
            refresh()
            
            return true
        }
        
        private func handleSlide(in direction: RangeSeekSliderViewModel.Direction, for selectedValue: CGFloat) {
            guard direction != .none else {
                return
            }
            handleTracking = direction == .left ? .left : .right
            leftHandle.zPosition = handleTracking == .left ? 1 : 0
            rightHandle.zPosition = handleTracking == .right ? 1 : 0
            viewModel.selectedMinValue = min(selectedValue, viewModel.selectedMaxValue)
        }
        
        override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
            handleTracking = .none
            viewModel.resetTouchTracking()
        }
        
        func setup() {
            viewModel.style = .formattedNumber
            viewModel.minValue = 50_000
            viewModel.maxValue = 7_900_000
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = decimalPlaces
            formatter.numberStyle = .currency
            formatter.locale = Locale(identifier: "en_US")
            viewModel.numberFormatter = formatter
            
            refresh()
            
            controlEvent(.valueChanged).subscribe(onNext: { [weak self] in
                var minValue: Double? = 0
                var maxValue: Double? = 100
                    minValue = self?.viewModel.selectedMinValueEqualToMinOrMaxValue() == true ? nil : Double(self?.viewModel.selectedMinValue ?? 0)
                    maxValue = self?.viewModel.selectedMaxValueEqualToMaxValue() == true ? nil : Double(self?.viewModel.selectedMaxValue ?? 100)
                self?.valueChanged.on(.next((minValue, maxValue)))
            })
            
            leftLabel.text = displayName
            stepRules.forEach { range, step in
                if range.contains(viewModel.selectedMinValue) {
                    leftStep = step
                }
                if range.contains(viewModel.selectedMaxValue) {
                    rightStep = step
                }
            }
        }
        
        private func percentageAlongLine(for value: CGFloat) -> CGFloat {
            guard viewModel.minValue < viewModel.maxValue else {
                return 0
            }
            let maxMinDif = viewModel.maxValue - viewModel.minValue
            let valueSubtracted = value - viewModel.minValue
            return valueSubtracted / maxMinDif
        }
        
        private func xPositionAlongLine(for value: CGFloat) -> CGFloat {
            let percentage = percentageAlongLine(for: value)
            let maxMinDif = sliderLine.frame.maxX - sliderLine.frame.minX
            let offset = percentage * maxMinDif
            return sliderLine.frame.minX + offset
        }
        
        private func updateHandleFrame() {
            let handleFrame = CGRect(x: sliderContainer.frame.minX - 8, y: 0, width: handleDiameter, height: handleDiameter)
            leftHandle.frame = handleFrame
            rightHandle.frame = handleFrame
        }
        
        private func updateLineHeight() {
            sliderLine.frame = CGRect(x: leftHandle.frame.minX,
                                      y: leftHandle.frame.midY,
                                      width: sliderContainer.frame.width - handleDiameter,
                                      height: lineHeight)
            sliderLine.cornerRadius = lineHeight / 2
            sliderLineBetweenHandles.cornerRadius = sliderLine.cornerRadius
        }
        
        private func updateLabelValues() {
            let selectedMinValueString = viewModel.string(from: viewModel.selectedMinValue)
            let selectedMaxValueString = viewModel.string(from: viewModel.selectedMaxValue)
            rightLabel.text = "\(selectedMinValueString) - \(selectedMaxValueString)"
        }
        
        private func updateColors() {
            let tintCGColor = tintColor.cgColor
            sliderLineBetweenHandles.backgroundColor = tintCGColor
            sliderLine.backgroundColor = UIColor.gray30.cgColor
            let color = handleColor.cgColor
            leftHandle.backgroundColor = color
            leftHandle.borderColor = handleBorderColor.cgColor
            rightHandle.backgroundColor = color
            rightHandle.borderColor = handleBorderColor.cgColor
        }
        
        private func updateHandlePositions() {
            leftHandle.position = CGPoint(x: xPositionAlongLine(for: viewModel.selectedMinValue),
                                          y: sliderLine.frame.midY)
            rightHandle.position = CGPoint(x: xPositionAlongLine(for: viewModel.selectedMaxValue),
                                           y: sliderLine.frame.midY)
            sliderLineBetweenHandles.frame = CGRect(x: leftHandle.position.x,
                                                    y: sliderLine.frame.minY,
                                                    width: rightHandle.position.x - leftHandle.position.x,
                                                    height: lineHeight)
        }
        
        private func refresh() {
            if enableStep && leftStep > 0.0 && rightStep > 0.0 {
                stepRules.forEach { range, step in
                    if range.contains(viewModel.selectedMinValue) {
                        leftStep = step
                    }
                    if range.contains(viewModel.selectedMaxValue) {
                        rightStep = step
                    }
                }
                viewModel.selectedMinValue = CGFloat(roundf(Float(viewModel.selectedMinValue / leftStep))) * leftStep
                viewModel.selectedMaxValue = CGFloat(roundf(Float(viewModel.selectedMaxValue / rightStep))) * rightStep
            }
            
            let diff = viewModel.selectedMaxValue - viewModel.selectedMinValue
            let minDistance: CGFloat = 0
            if diff < minDistance {
                switch handleTracking {
                case .left:
                    viewModel.selectedMinValue = viewModel.selectedMaxValue - minDistance
                case .right:
                    viewModel.selectedMaxValue = viewModel.selectedMinValue + minDistance
                case .none, .overlap:
                    break
                }
            }
            if viewModel.selectedMinValue < viewModel.minValue {
                viewModel.selectedMinValue = viewModel.minValue
            }
            if viewModel.selectedMaxValue > viewModel.maxValue {
                viewModel.selectedMaxValue = viewModel.maxValue
            }
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            updateHandlePositions()
            CATransaction.commit()
            
            updateLabelValues()
            updateColors()
            
            sendActions(for: .valueChanged)
        }
    }

}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
