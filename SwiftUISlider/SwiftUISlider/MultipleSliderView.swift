//
//  MultipleSliderView.swift
//  SwiftUISlider
//
//  Created by Veronica Ray on 8/4/19.
//  Copyright © 2019 Veronica Ray. All rights reserved.
//

import SwiftUI

struct MultipleSliderView: View {
    var body: some View {
        VStack {
            TestSlider(rangeType: .price)
            TestSlider(rangeType: .squareFeet)
        }
    }
}
