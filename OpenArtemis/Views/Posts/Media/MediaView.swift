//
//  MediaView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 11/28/23.
//

import SwiftUI
import AVKit
import CachedImage
import LazyPager
import Defaults

struct MediaView: View {
    @Default(.compactMode) var compactMode
    
    let determinedType: String
    let mediaURL: Post.PrivateURL
    let thumbnailURL: String?
    let title: String
    
    @Binding var mediaSize: CGSize
    
    var body: some View {
        VStack {
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
                        HStack {
                            let width: CGFloat = compactMode ? roughCompactWidth : mediaSize.width != 0 ? mediaSize.width : roughWidth
                            let height: CGFloat = compactMode ? roughCompactHeight : mediaSize.height != 0 ? mediaSize.height : roughHeight

                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .frame(width: mediaSize.width != 0 ? mediaSize.width : width, height: mediaSize.height != 0 ? mediaSize.height : height)
                                .animatedLoading()
                            Spacer()
                        }
                    }
                )
                .aspectRatio(contentMode: .fit)
                .onTapGesture {
                    ImageViewerController(images: [mediaURL.privateURL], imageTitle: title).present()
                }
                .cornerRadius(6)
                
            case "text":
                if compactMode {
                    RoundedRectangle(cornerRadius: 6)
                        .overlay(
                            Image(systemName: "line.horizontal.3")
                                .padding()
                                .font(.largeTitle)
                        )
                        .foregroundColor(tagBgColor)
                } else {
                    // Display empty view with negative padding to make up for the spacing
                    EmptyView().padding(-16)
                }

            default:
                EmbeddedMultiMediaView(determinedType: determinedType, mediaURL: mediaURL, thumbnailURL: thumbnailURL, title: title)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(tagBgColor)
                .opacity(compactMode ? 1 : 0) // only display gray bg in compact mode
                .frame(width: roughCompactWidth, height: roughCompactWidth)
        )
    }
}
