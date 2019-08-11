//
//  TestSliderModel.swift
//  SwiftUISlider
//
//  Created by Veronica Ray on 8/4/19.
//  Copyright © 2019 Veronica Ray. All rights reserved.
//

import SwiftUI

enum RangeType {
    case price
    case squareFeet
    
    var step: CGFloat {
        switch self {
        case .price:
            return 250_000
        case .squareFeet:
            return 1_000
        }
    }
    
    var numberFormatter: NumberFormatter {
        switch self {
        case .price:
            return NumberFormatter.currencyFormatter()
        case .squareFeet:
            return NumberFormatter.numberFormatter()
        }
    }
    
    var minValue: CGFloat {
        return 0
    }
    
    var maxValue: CGFloat {
        switch self {
        case .price:
            return 7_750_000
        case .squareFeet:
            return 21_000
        }
    }
}
