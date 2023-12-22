//
//  OOBE_SubsImporter.swift
//  OpenArtemis
//
//  Created by daniel on 13/12/23.
//

import SwiftUI

struct OOBE_SubsImporter: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack{
           HStack {
                Text("Now, transfer your subscriptions from Reddit by visiting https://old.reddit.com/subreddits/")
                    .padding()
            }
            
            ImageDescription(text: "Search for the text 'multireddit of your subscriptions' and long-press it:", image: "screen1")
            ImageDescription(text: "Next, press on 'Copy link' and paste it into the next screen:", image: "screen2")
            Button{
                dismiss()
            } label: {
                Label("Skip this Step", systemImage: "pencil")
                    .labelStyle(.titleOnly)
            }
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

