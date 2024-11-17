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
    let determinedType: String
    let mediaURL: Post.PrivateURL
    let thumbnailURL: String?
    let useLargeThumbnail: Bool

    let title: String
    let forceCompactMode: Bool
    let appTheme: AppThemeSettings
    let textSizePreference: TextSizePreference
    
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
                                        withAnimation {
                                            mediaSize = newSize
                                        }
                                    }
                                }
                            }
                    },
                    placeholder: {
                        HStack {
                            let width: CGFloat = appTheme.compactMode || forceCompactMode ? roughCompactWidth : mediaSize.width != 0 ? mediaSize.width : roughWidth
                            let height: CGFloat = appTheme.compactMode || forceCompactMode ? roughCompactHeight : mediaSize.height != 0 ? mediaSize.height : roughHeight
                            
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
                if appTheme.compactMode || forceCompactMode {
                    Image(systemName: "line.horizontal.3")
                        .padding()
                        .font(.largeTitle)
                        .foregroundStyle(Color.white.opacity(0.75))
                }
            default:
                EmbeddedMultiMediaView(determinedType: determinedType, mediaURL: mediaURL, thumbnailURL: thumbnailURL, useLargeThumbnail: useLargeThumbnail, title: title, forceCompactMode: forceCompactMode, appTheme: appTheme, textSizePreference: textSizePreference)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(tagBgColor)
                .opacity(appTheme.compactMode || forceCompactMode ? 1 : 0) // only display gray bg in compact mode
                .frame(width: roughCompactWidth, height: roughCompactWidth)
        )
    }
}
