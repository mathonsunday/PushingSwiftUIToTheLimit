//
//  NumberFormatterExtensions.swift
//  SwiftUISlider
//
//  Created by Veronica Ray on 7/9/19.
//  Copyright © 2019 Veronica Ray. All rights reserved.
//

import Foundation

extension NumberFormatter {
    public static func currencyFormatter(decimalPlaces: Int = 0) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = decimalPlaces
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }
    
    public static func numberFormatter(maxDecimalPlaces: Int = 0, minDecimalPlaces: Int = 0) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = minDecimalPlaces
        formatter.maximumFractionDigits = maxDecimalPlaces
        formatter.numberStyle = .decimal
        formatter.roundingMode = .halfUp
        
        return formatter
    }
}
