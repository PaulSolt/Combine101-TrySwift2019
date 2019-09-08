//
//  ContentView.swift
//  Combine101
//
//  Created by Paul Solt on 9/8/19.
//  Copyright © 2019 Paul Solt. All rights reserved.
//

import SwiftUI
import Combine


struct ContentView: View {
    var body: some View {
        Text("Hello World")
            .onAppear(perform: viewDidAppear)
    }
}

func viewDidAppear() {
    print("Hi Try Swift!")
    
    let stringPublisher: AnyPublisher<String, Never> =
    ["try!", "Swift", "NYC"].publisher
    .eraseToAnyPublisher()
    
    let sink = Subscribers.Sink<String, Never>.init(receiveCompletion: { status in
        switch status {
        case .finished:
            print("Finished")
        case .failure:
            print("Failed")
        }
    }) { (input: String) in
        print(input)
    }
    
    stringPublisher.subscribe(sink)
    
    _ = ["Welcome", "to", "Combine"]
        .publisher                          // BUG: Indentation ???
        .sink(receiveValue: { (value) in
            print(value)
        })
    
    
    _ = [42.5, 27.5, 3.2, 104.4]
        .publisher
        .map {
            return Int($0 * 10)
        }
        .sink {
            print($0)
        }
    
    _ = [4, 5, 3, 2, 1, 1, 4, 2]
        .publisher
        .filter({ (value) -> Bool in
            value >= 3
        }).sink(receiveValue: { (value) in
            print(value)
        })
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
