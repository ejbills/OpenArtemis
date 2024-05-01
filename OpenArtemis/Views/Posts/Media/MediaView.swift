//
//  MediaView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 11/28/23.
//

import SwiftUI
import CachedImage
import LazyPager
import Defaults
import SDWebImageSwiftUI

struct MediaView: View {
    let determinedType: String
    let mediaURLs: [Post.PrivateURL]
    let roughMediaHeight: Int
    let roughMediaWidth: Int
    let thumbnailURL: String?
    let title: String
    let forceCompactMode: Bool
    let appTheme: AppThemeSettings
    let textSizePreference: TextSizePreference
    
    @Binding var mediaSize: CGSize
    
    var body: some View {
        VStack {
            if let firstURL = mediaURLs.first, let forcedPrivateMediaURL = URL(string: firstURL.privateURL) {
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
                                    .frame(width: width, height: height)
                                    .animatedLoading()
                                Spacer()
                            }
                        }
                    )
                    .aspectRatio(contentMode: .fit)
                    .onTapGesture {
                        ImageViewerController(images: [firstURL.privateURL], imageTitle: title).present()
                    }
                    .cornerRadius(6)
                    
                case "gif" where (roughMediaWidth != 0 && roughMediaHeight != 0):
                    let roughMediaSize = CGSize(width: Double(integerLiteral: Int64(roughMediaWidth)),
                                                height: Double(integerLiteral: Int64(roughMediaHeight)))
                    
                    AnimatedImage(url: forcedPrivateMediaURL, placeholder: {
                        HStack {
                            let width: CGFloat = appTheme.compactMode || forceCompactMode ? roughCompactWidth : roughMediaSize.width != 0 ? roughMediaSize.width : roughWidth
                            let height: CGFloat = appTheme.compactMode || forceCompactMode ? roughCompactHeight : roughMediaSize.height != 0 ? roughMediaSize.height : roughHeight
                            
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .frame(width: width, height: height)
                                .animatedLoading()
                            Spacer()
                        }
                    })
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(roughMediaSize, contentMode: .fit)
                    .cornerRadius(6)
                    
                    //            case "video" where (roughMediaWidth != 0 && roughMediaHeight != 0):
                    
                 case "gallery":
                    ScrollView {
                        HStack {
                            ForEach(mediaURLs, id: \.self) { imageURL in
                                if let tempForcedPrivateMediaURL =  URL(string: firstURL.privateURL) {
                                    CachedImage(
                                        url: tempForcedPrivateMediaURL,
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
                                                    .frame(width: width, height: height)
                                                    .animatedLoading()
                                                Spacer()
                                            }
                                        }
                                    )
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(6)
                                }
                            }
                        }
                    }
                    .onTapGesture {
                        ImageViewerController(images: mediaURLs.privateURLs(), imageTitle: title).present()
                    }
                case "text":
                    if appTheme.compactMode || forceCompactMode {
                        Image(systemName: "line.horizontal.3")
                            .padding()
                            .font(.largeTitle)
                            .foregroundStyle(Color.white.opacity(0.75))
                    }
                default:
                    EmbeddedMultiMediaView(determinedType: determinedType, mediaURL: firstURL, thumbnailURL: thumbnailURL, title: title, forceCompactMode: forceCompactMode, appTheme: appTheme, textSizePreference: textSizePreference)
                }
            } else {
                Text("Media encountered a fatal error!")
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
