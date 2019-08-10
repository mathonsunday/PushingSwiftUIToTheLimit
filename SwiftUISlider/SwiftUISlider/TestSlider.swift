//
//  ContentView.swift
//  SwiftUISlider
//
//  Created by Veronica Ray on 6/22/19.
//  Copyright © 2019 Veronica Ray. All rights reserved.
//

import SwiftUI

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

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        TestSlider(rangeType: .price)
    }
}
#endif
