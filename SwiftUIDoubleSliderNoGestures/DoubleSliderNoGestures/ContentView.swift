//
//  ContentView.swift
//  DoubleSliderNoGestures
//
//  Created by Veronica Ray on 7/28/19.
//  Copyright © 2019 Veronica Ray. All rights reserved.
//

import SwiftUI

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

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
