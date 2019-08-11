//
//  ContentView.swift
//  SwiftUIDoubleSlider
//
//  Created by Veronica Ray on 6/23/19.
//  Copyright © 2019 Veronica Ray. All rights reserved.
//

import SwiftUI

struct PriceContentView : View {
    @State private var selectedMinValue: CGFloat = RangeType.price.minValue
    @State private var selectedMaxValue: CGFloat = RangeType.price.maxValue
    @State private var leftHandleViewState: CGSize = .zero
    @State private var rightHandleViewState: CGSize = .zero
    private let numberFormatter = RangeType.price.numberFormatter
    private let minValue = RangeType.price.minValue
    private let maxValue = RangeType.price.maxValue
    private let step = RangeType.price.step
    private let lineWidth: CGFloat = 300.0
    private let handleDiameter: Length = 24
    
    var body: some View {
        let leftHandleDragGesture = DragGesture(minimumDistance: 1, coordinateSpace: .local)
            .onChanged { value in
                guard value.location.x >= 0, value.location.x <= (self.lineWidth + self.handleDiameter) else {
                    return
                }
                self.leftHandleViewState.width = value.location.x
                let percentage = self.leftHandleViewState.width/(self.lineWidth + self.handleDiameter)
                self.selectedMinValue = max(percentage * (self.maxValue - self.minValue) + self.minValue, self.minValue)
                self.selectedMinValue = CGFloat(roundf(Float(self.selectedMinValue / self.step))) * self.step
        }
        let rightHandleDragGesture = DragGesture(minimumDistance: 1, coordinateSpace: .local)
            .onChanged { value in
                guard value.location.x <= 0, value.location.x >= -(self.lineWidth + self.handleDiameter) else {
                    return
                }
                self.rightHandleViewState.width = value.location.x
                let percentage = 1 - abs(self.rightHandleViewState.width)/(self.lineWidth + self.handleDiameter)
                self.selectedMaxValue = max(percentage * (self.maxValue - self.minValue) + self.minValue, self.minValue)
                self.selectedMaxValue = CGFloat(roundf(Float(self.selectedMaxValue / self.step))) * self.step
        }
        return
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Circle()
                        .fill(Color.purple)
                        .frame(width: handleDiameter, height: handleDiameter, alignment: .center)
                        .offset(x: leftHandleViewState.width, y: 0)
                        .gesture(leftHandleDragGesture)
                        .zIndex(1)
                    Rectangle()
                        .frame(width: lineWidth, height: CGFloat(1.0), alignment: .center)
                        .zIndex(0)
                    Circle()
                        .fill(Color.purple)
                        .frame(width: handleDiameter, height: handleDiameter, alignment: .center)
                        .offset(x: rightHandleViewState.width, y: 0)
                        .gesture(rightHandleDragGesture)
                        .zIndex(1)
                }
                Text("Selected min value: \(numberFormatter.string(from: selectedMinValue as NSNumber) ?? "")")
                Text("Selected max value: \(numberFormatter.string(from: selectedMaxValue as NSNumber) ?? "")")
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        PriceContentView()
    }
}
#endif
