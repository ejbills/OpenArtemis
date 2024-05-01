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
    
    let determinedType: String
    let mediaURL: Post.PrivateURL
    let thumbnailURL: String?
    let title: String
    let forceCompactMode: Bool
    let appTheme: AppThemeSettings
    let textSizePreference: TextSizePreference
    
    @State private var isLoading: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // determines size of thumbnail mainly, it takes up the whole image slot if you are in comapct mode.
            let mediaHeight = appTheme.compactMode || forceCompactMode ? roughCompactHeight : 50
            let mediaWidth = appTheme.compactMode || forceCompactMode ? roughCompactWidth : 50
            let mediaIcon = getMediaIcon(type: determinedType)

            if let thumbnailURL, let formattedThumbnailURL = URL(string: thumbnailURL) {
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
                .overlay {
                    Image(systemName: mediaIcon)
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(Color.white.opacity(0.75))
                }
            } else {
                RoundedRectangle(cornerRadius: 6)
                   .foregroundColor(.clear)
                   .frame(width: mediaWidth, height: mediaHeight)
                   .overlay(
                       Image(systemName: mediaIcon)
                           .resizable()
                           .frame(width: 30, height: 30)
                           .foregroundStyle(Color.white.opacity(0.75))
                   )
            }
            
            if !appTheme.compactMode && !forceCompactMode {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Open \(determinedType) media")
                        .font(textSizePreference.body)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .foregroundColor(.primary)
                    
                    Text(appTheme.showOriginalURL ? mediaURL.originalURL : mediaURL.privateURL)
                        .font(textSizePreference.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .italic()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(appTheme.compactMode || forceCompactMode ? 0 : 6) // less spacing in compact ^.^
        .background(RoundedRectangle(cornerRadius: 6).foregroundColor(tagBgColor).opacity(appTheme.compactMode || forceCompactMode ? 0 : 1))
        .onTapGesture {
            if determinedType == "article" {
                SafariHelper.openSafariView(withURL: URL(string: mediaURL.privateURL)!)
            }
        }
        .loadingOverlay(isLoading: isLoading)
    }
    
    private func getMediaIcon(type: String) -> String {
        switch type {
        case "gallery":
            return "photo.on.rectangle"
        case "video", "gif":
            return "play.square.fill"
        case "article":
            return "safari"
        default:
            return "link"
        }
    }

}
