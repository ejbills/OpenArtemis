////
////  ScrollLoaderView.swift
////  OpenArtemis
////
////  Created by Michael DiGovanni on 11/11/24.
////
//import SwiftUI
//
///// This view allows us to load a
//struct ScrollLoaderView: View {
//    let action: (() -> Void) -> Void // Action we want to pass through
//    @State var id: Int = Int.min
//    
//    init(action: @escaping (passthroughAction: () -> Void) -> Void) {
//        self.action = action
//    }
//    
//    // Apply this elsewhere, code reuse
////    init(action: @escaping () -> Void) {
////        self.action = {
////            
////            action
////        }
////    }
//    
//    var body: some View {
//        Rectangle() // is this how it loads next? must expect to be hiddennext and show up again!
//            .fill(Color.clear)
//            .frame(height: 1)
//            .id(id)
//            .onAppear {
//                // maybe check if visible after completion?
//                // regardless of how we solve this, we need to know when it's done to repeat!\
//                print("small one")
////                scrapeSubreddit(lastPostAfter: lastPostAfter, sort: sortOption, preventListIdRefresh: true) {
////                    // Scraping the subreddit finished, so let's update the ID so onAppear runs again
//                    id = id + 1
////                }
//            }
//    }
//}
