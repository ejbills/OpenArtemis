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

struct EmbeddedMultiMediaView: View {
    @EnvironmentObject var coordinator: NavCoordinator
    @Default(.showOriginalURL) private var showOriginalURL
    
    let determinedType: String
    let mediaURL: Post.PrivateURL
    let thumbnailURL: String?
    let title: String
    @State private var isLoading: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if let thumbnailURL = thumbnailURL, let formattedThumbnailURL = URL(string: thumbnailURL) {
                AsyncImage(url: formattedThumbnailURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .cornerRadius(6)
                } placeholder: {
                    Color.gray
                        .frame(width: 50, height: 50)
                        .cornerRadius(6)
                }
            } else {
                Image(systemName: "link")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.blue)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Open \(determinedType) media")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .foregroundColor(.primary)

              Text(showOriginalURL ? mediaURL.originalURL : mediaURL.privateURL)
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .italic()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(6)
        .background(RoundedRectangle(cornerRadius: 6).foregroundColor(tagBgColor))
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
