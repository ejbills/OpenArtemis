//
//  PostPageView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/2/23.
//

import SwiftUI

struct PostPageView: View {
    let post: Post
    
    var body: some View {
        ScrollView {
            VStack {
                PostFeedView(post: post)
                
                DividerView()
                
                HStack {
                    Text("Comments")
                        .font(.subheadline)
                    
                    Spacer()
                }
                
                ForEach(0..<100, id: \.self) { index in
                    Text("example comment")
                        .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
