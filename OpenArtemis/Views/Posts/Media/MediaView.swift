//
//  MediaView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 11/28/23.
//

import SwiftUI
import AVKit
import CachedImage

struct MediaView: View {
    let determinedType: String
    let mediaURL: PrivateURL
    let thumbnailURL: String?

    @Binding var mediaSize: CGSize
    
    var body: some View {
      
      let forcedPrivateMediaURL = URL(string: mediaURL.privateURL)!
            
        switch determinedType {
        case "image":
            CachedImage(
                url: forcedPrivateMediaURL,
                content: { image in
                    image
                        .resizable()
                        .readSize()
                        .onSizeChange { newSize in
                            Task(priority: .background) {
                                if abs(mediaSize.width - newSize.width) > 25 && abs(mediaSize.height - newSize.height) > 25 {
                                    mediaSize = newSize
                                }
                            }
                        }
                },
                placeholder: {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(width: mediaSize.width != 0 ? mediaSize.width : roughWidth, height: mediaSize.height != 0 ? mediaSize.height : roughHeight)
                        .animatedLoading()
                }
            )
            .aspectRatio(contentMode: .fit)
            .cornerRadius(6)
            .onTapGesture {
              SKPhotoBrowserController(images: [mediaURL.privateURL]).present()
            }
            
        case "text":
            // we dont need to display anything.
            EmptyView()
            
        default:
            EmbeddedMultiMediaView(determinedType: determinedType, mediaURL: mediaURL, thumbnailURL: thumbnailURL)
        }
    }
}
