# CombineTimer


## Demo 1: Combine 101 (Publishers and Subscribers)


1. Rename the ContentView.swift to CombineBasics.swift (SwiftUI file)
2. Set the SwiftUI file to be in Scene as default host
3. `import combine`


	```swift
	import SwiftUI
	import Combine
	
	struct CombineBasics: View {
	    var body: some View {
	        Text("Combine 101")
	            .onAppear(perform: viewDidAppear)
	    }
	}
	
	func viewDidAppear() {
	    // Experiment here
	
	    print("Hello World!")
	    
	    let stringPublisher: AnyPublisher<String, Never> =
	        ["try!", "Swift", "NYC"]
	            .publisher              // Publishers.Sequence<[String], Never>
	            .eraseToAnyPublisher()  // AnyPublisher<String, Never>
	    
	    let sink = Subscribers.Sink<String, Never>.init(receiveCompletion: { status in
	        print("Finished: \(status)")    // called when finished "iterating" array
	    }, receiveValue: { (input: String) in
	        print("Received: \(input)")     // called for each element in the array
	    })
	    
	    stringPublisher.subscribe(sink) // stream executes
	    
	    
	    // Short hand Welcome
	    _ = ["Welcome", "to", "Combine"]
	        .publisher
	        .sink(receiveValue: { value in
	            print(value)
	        })
	    
	    // Map (Double to Int)
	    _ = [42.5, 27.5, 3.2, 104.4]
	        .publisher
	        .map {
	            return Int($0 * 10)
	        }.sink { value in
	            print(value)
	        }
	    
	    // Filter star ratings >= 3
	    _ = [4,5,2,1,3,1]
	        .publisher
	        .filter {
	            $0 >= 3
	        }.sink { value in
	            print(value)
	        }
	}
	
	struct CombineBasics_Previews: PreviewProvider {
	    static var previews: some View {
	        CombineBasics()
	    }
	}
	```



## @State Demo 2: Sample Timer app in Combine

1. Create a new file
2. Import combine

	```swift
	//
	//  TimerView.swift
	//  Combine101
	//
	//  Created by Paul Solt on 9/7/19.
	//  Copyright © 2019 Paul Solt. All rights reserved.
	//
	
	import SwiftUI
	import Combine
	
	struct TimerView: View {
	    static private let zeroTime = "00:00"
	    
	    @State private var timeString: String = TimerView.zeroTime
	    @State private var startDate: Date? = nil
	    @State private var isActive: Bool = false
	    @State private var timer: AnyCancellable? = nil
	    
	    var body: some View {
	        VStack {
	            Text(timeString)
	                .font(Font.system(size: 80, weight: .semibold, design: .default)
	                    .monospacedDigit()
	            )
	            startStopButton
	        }.onAppear(perform: viewDidAppear)
	    }
	    
	    var startStopButton: some View {
	        Button(action: startStop, label: {
	            Text(isActive ? "Stop" : "Start")
	                .font(.title)
	        })
	    }
	    
	    func startStop() {
	        if isActive {
	            timer?.cancel()
	        } else {
	            timer = createTimer()
	        }
	        isActive.toggle()
	    }
	    
	    func viewDidAppear() {
	        
	        // Create a timer to output to console
	        timer = Timer.publish(every: 0.2, on: .main, in: .default)
	            .autoconnect()
	            .sink {
	                print($0)
	        }
	    }
	    
	    func createTimer() -> AnyCancellable {
	        startDate = Date()
	        
	        return Timer.publish(every: 0.01, on: .main, in: .default)
	            .autoconnect()
	            .sink { (now) in
	                if let startDate = self.startDate,
	                    let time = self.timeFormatter.string(from: now.timeIntervalSince(startDate)) {
	                    self.timeString = time
	                }
	            }
	        
	//        return Timer.publish(every: 0.01, on: .main, in: .default)
	//            .autoconnect()
	//            .compactMap { (now) in
	//                if let startDate = self.startDate,
	//                    let time = self.timeFormatter.string(from: now.timeIntervalSince(startDate)) {
	//                    return time
	//                }
	//                return nil
	//            }
	//            .assign(to: \.timeString, on: self)
	        // Can use the sink or assign directly to a String property
	        
	    }
	    
	    var timeFormatter: DateComponentsFormatter = {
	        let formatter = DateComponentsFormatter()
	        formatter.unitsStyle = .positional
	        formatter.allowsFractionalUnits = true
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
	```



# URLS

* Github (UIViewRepresentable + Bindable): 
* [CombineTimer - @State and Timer](https://github.com/PaulSolt/CombineTimer) 
* [App Review with Combine](https://github.com/PaulSolt/TopRatedReviewsCombine) 
* 



## SwiftUI Demo

Goal: We need to create a way to display a Review


## @ObservedObject Demo

1.  Add tags to your reference type

	```swift
	class AppReviewStore: ObservableObject {
	    @Published private(set) var reviews: [Review] = []
	    
	    private let service: AppReviewService
	    
	    init(service: AppReviewService) {
	        self.service = service
	    }
	    
	    func fetchReviews(for appId: String, ordering: AppReviewURL.ReviewOrdering) {
	        
	        let appURL = AppReviewURL(appId: appId, ordering: ordering)
	        
	        service.fetchReviews(for: appURL) { result in  // TODO: need [weak self]?
	            DispatchQueue.main.async {
	                switch result {
	                case .success(let reviews):
	                    self.reviews = reviews
	                case .failure(let error):
	                    print("Error fetching reviews: \(error)")
	                    self.reviews = []
	                }
	            }
	        }
	    }
	}
	```

2. Mark field as `@ObservedObject` in "ReviewList.swift"

	```swift
	struct ReviewList: View {
	//    var reviews: [Review] = []  // Prototype
	    @EnvironmentObject var reviewStore: AppReviewStore
	    
	    var body: some View {
	        NavigationView {
	            
	            VStack {
	                List(reviewStore.reviews) { review in
	                    ReviewRow(review: review)
	                }
	            }.navigationBarTitle(Text("Reviews"))
	        }.onAppear {
	            self.fetch()
	            
	            // TODO: Show star rating
	            // TODO: update star rating
	        }
	    }
	    
	    private func fetch() {
	        reviewStore.fetchReviews(for: "284862083", ordering: .mostHelpful) // NYTimes
	    }
	}
	
	struct ReviewList_Previews: PreviewProvider {
	    static var previews: some View {
	//        ReviewList(reviews: appReviewData) // prototype
	        ReviewList()
	            .environmentObject(
	                AppReviewStore(service: AppReviewService()
	            ))
	    }
	}
	```

3. Update the "SceneDelegate.swift"

	```swift
	        let service = AppReviewService()
	        let store = AppReviewStore(service: service)
	        store.fetchReviews(for: "284862083", ordering: .mostHelpful) // NYTimes
	    
	        // Create the SwiftUI view that provides the window contents.
	        let contentView = ReviewList()
	            .environmentObject(store)
	
	```


# Extra Github Demo

1. Binding 
2. UIViewRepresentable

```swift
import Foundation
import SwiftUI
import Combine

typealias SearchCompletion = () -> Void

struct SearchBar: UIViewRepresentable {

    @Binding var text: String
    var completion: SearchCompletion? = nil
    
    init(text: Binding<String>, onChange completion: SearchCompletion? = nil) {
        _text = text
        self.completion = completion
    }
    
    // The coordinator allows us to listen for updates to our searchbar
    class SearchBarCoordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        var completion: SearchCompletion?
        
        init(text: Binding<String>, onChange completion: SearchCompletion? = nil) {
            _text = text
            self.completion = completion
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
            completion?()
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            completion?()
        }
    }
    
    func makeCoordinator() -> SearchBarCoordinator {
        return SearchBarCoordinator(text: $text, onChange: completion)
    }
    
    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.delegate = context.coordinator
        return searchBar
    }
    
    func updateUIView(_ searchBar: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        searchBar.text = text
    }
}
```

