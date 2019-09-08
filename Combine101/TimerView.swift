//
//  TimerView.swift
//  Combine101
//
//  Created by Paul Solt on 9/8/19.
//  Copyright © 2019 Paul Solt. All rights reserved.
//

import SwiftUI
import Combine

struct TimerView: View {
    @State private var isActive: Bool = false
    @State private var timer: AnyCancellable? = nil
    @State private var startDate: Date = Date()
    @State private var timeText: String = "00:00"
    
    var body: some View {
        VStack {
            Text(timeText)
                .font(
                    Font.system(size: 80, weight: .semibold, design: .default).monospacedDigit()
                    )
            startStopButton
        }.onAppear(perform: viewDidAppear)
    }
    
    var startStopButton: some View {
        Button(action: startStop, label: {
            
            Text(isActive ? "Stop" : "Start")
                .font(.system(.largeTitle))
            
        })
    }
    
    func startStop() {
        // TODO: Timer (cancel it / createTimer)
        if isActive {
            timer?.cancel()
        } else {
            timer = makeTimer()
        }
        self.isActive.toggle()
    }
    
    func viewDidAppear() {
        
//        timer = Timer.publish(every: 0.2, on: RunLoop.main, in: .common)
//            .autoconnect()
//            .sink {
//                print($0)
//        }
        
    }
    
    func makeTimer() -> AnyCancellable {
        startDate = Date()
        
        return Timer.publish(every: 0.2, on: RunLoop.main, in: .common)
            .autoconnect()
            .sink {
                
                // how much time has passed?
//                textField.text = "00:01"
                self.timeText = self.timeFormatter.string(from: self.startDate, to: $0) ?? "00:00"
                print($0)
            }
    }
    
    var timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        return formatter
    }()
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}
