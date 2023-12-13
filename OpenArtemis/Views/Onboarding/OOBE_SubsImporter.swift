//
//  OOBE_SubsImporter.swift
//  OpenArtemis
//
//  Created by daniel on 13/12/23.
//

import SwiftUI

struct OOBE_SubsImporter: View {
    var body: some View {
        VStack{
            HStack{
                Text("Now if to transfer over your subscriptions from Reddit. Got to https://old.reddit.com/subreddits/")
                    .padding()
            }
            
            ImageDescription(text: "Search for the text 'multireddit of your subscriptions' and long press it:", image: "screen1")
            ImageDescription(text: "Next Press on Copy link and paste it into the next Sreen", image: "screen2")
            
            Spacer()
        }
        
    }
}


struct ImageDescription: View {
    var text: String
    var image: String
    var body: some View {
        VStack{
            HStack{
                Text(text)
                    .opacity(0.7)
                Spacer()
            }
            Image(image)
                .resizable()
                .mask(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                .scaledToFit()
                .frame(maxWidth: UIScreen.screenWidth)
        }
        .padding()
    }
}

