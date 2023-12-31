//
//  ArticleView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 11/28/23.
//

import SwiftUI
import Defaults
import LazyPager
import CachedImage
import LinkPresentation

struct EmbeddedMultiMediaView: View {
    @EnvironmentObject var coordinator: NavCoordinator
    
    let determinedType: String
    let mediaURL: Post.PrivateURL
    let thumbnailURL: String?
    let title: String
    let appTheme: AppThemeSettings
    
    @State private var isLoading: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // determines size of thumbnail mainly, it takes up the whole image slot if you are in comapct mode.
            let mediaHeight = appTheme.compactMode ? roughCompactHeight : 50
            let mediaWidth = appTheme.compactMode ? roughCompactWidth : 50
            let mediaIcon = determinedType == "video" ? "play.square.fill" : (determinedType == "gallery" ? "photo.on.rectangle" : "safari")
            
            Group {
                if let thumbnailURL = thumbnailURL, let formattedThumbnailURL = URL(string: thumbnailURL) {
                    CachedImage(
                        url: formattedThumbnailURL,
                        content: { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: mediaWidth, height: mediaHeight)
                                .cornerRadius(6)
                        },
                        placeholder: {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .frame(width: mediaWidth, height: mediaHeight)
                                .cornerRadius(6)
                                .animatedLoading()
                        }
                    )
                } else {
                    let vm = LinkViewModel(link: mediaURL.originalURL)
                    MetadataView(vm: vm, width: mediaWidth, height: mediaHeight)
                }
            }
            .overlay {
                Image(systemName: mediaIcon)
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color.white.opacity(0.75))
                    .padding(4)
            }
            
            if !appTheme.compactMode {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Open \(determinedType) media")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .foregroundColor(.primary)
                    
                    Text(appTheme.showOriginalURL ? mediaURL.originalURL : mediaURL.privateURL)
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .italic()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(appTheme.compactMode ? 0 : 6) // less spacing in compact ^.^
        .background(RoundedRectangle(cornerRadius: 6).foregroundColor(tagBgColor).opacity(appTheme.compactMode ? 0 : 1))
        .onTapGesture {
            if !isLoading {
                withAnimation {
                    isLoading = true
                }
                
                if determinedType == "gallery" {
                    MediaUtils.galleryMediaExtractor(galleryURL: URL(string: mediaURL.privateURL)!) { imageUrls in
                        if let imageUrls = imageUrls {
                            DispatchQueue.main.async {
                                ImageViewerController(images: imageUrls, imageTitle: title).present()
                            }
                        } else {
                            print("Failed to extract image URLs.")
                        }
                        
                        isLoading = false
                    }
                } else if determinedType == "video" {
                    MediaUtils.videoMediaExtractor(videoURL: URL(string: mediaURL.privateURL)!) { videoURL in
                        if let videoURL = videoURL {
                            DispatchQueue.main.async {
                                VideoPlayerViewController(videoURL: videoURL).play()
                                
                            }
                        } else {
                            print("Failed to extract video URL.")
                        }
                        
                        isLoading = false
                    }
                } else {
                    SafariHelper.openSafariView(withURL: URL(string: mediaURL.privateURL)!)
                    isLoading = false
                }
            }
        }
        .loadingOverlay(isLoading: isLoading)
    }
}
