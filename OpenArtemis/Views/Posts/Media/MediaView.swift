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

struct MediaView: View {
    let determinedType: String
    let mediaURL: PrivateURL
    let thumbnailURL: String?
    let title: String
    
    @State var index = 0
    @State var show = true
    @State var opacity: CGFloat = 1 // Dismiss gesture background opacity
    
    @Binding var mediaSize: CGSize
    @State var showImageViewer: Bool = false
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
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .frame(width: mediaSize.width != 0 ? mediaSize.width : roughWidth, height: mediaSize.height != 0 ? mediaSize.height : roughHeight)
                            .animatedLoading()
                    }
                )
                .aspectRatio(contentMode: .fit)
                .onTapGesture {
                    ImageViewerController(images: [mediaURL.privateURL], imageTitle: title).present()
                }
                .cornerRadius(6)
//                .overlay(
//                    Button {
//                        showImageViewer.toggle()
//                    } label: {
//                        Label("Button :3", systemImage: "checkmark")
//                    }
//                )
                
            case "text":
                // we dont need to display anything.
                EmptyView()
            default:
                EmbeddedMultiMediaView(determinedType: determinedType, mediaURL: mediaURL, thumbnailURL: thumbnailURL, title: title)
            }
        }
    }
}
