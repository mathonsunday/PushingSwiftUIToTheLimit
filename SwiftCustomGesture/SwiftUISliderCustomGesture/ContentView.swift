//
//  ContentView.swift
//  SwiftUISliderCustomGesture
//
//  Created by Veronica Ray on 6/23/19.
//  Copyright © 2019 Veronica Ray. All rights reserved.
//

import SwiftUI

struct ContentView : View {
    @GestureState var isDetectingLongPress = false
    @State var totalNumberOfTaps = 0
    @State var doneCounting = false
    var body: some View {
        let press = LongPressGesture(minimumDuration: 1)
            .updating($isDetectingLongPress) { currentState, gestureState, transaction in
                gestureState = currentState
            }.onChanged { _ in
                self.totalNumberOfTaps += 1
            }.onEnded { _ in
                self.doneCounting  = true
        }
        
        return VStack {
            Text("\(totalNumberOfTaps)")
                .font(.largeTitle)
            
            Circle()
                .fill(doneCounting ? Color.gray : isDetectingLongPress ? Color.yellow : Color.green)
                .frame(width: 100, height: 100, alignment: .center)
                .gesture(doneCounting ? nil : press)
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
