//
//  ProfileView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/26/23.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var trackingParamRemover: TrackingParamRemover
    
    let username: String
    let appTheme: AppThemeSettings
    
    @FetchRequest(sortDescriptors: []) var savedPosts: FetchedResults<SavedPost>
    @FetchRequest(sortDescriptors: []) var savedComments: FetchedResults<SavedComment>

    @State private var mixedMedia: [MixedMedia] = []
    @State private var mediaIDs: Set<String> = Set()
    @State private var isLoading: Bool = true
    
    @State private var lastPostAfter: String = ""
    @State private var filterType: String = ""

    var body: some View {
        ThemedScrollView(appTheme: appTheme) {
            LazyVStack(spacing: 0) {
                if !mixedMedia.isEmpty {
                    ForEach(mixedMedia, id: \.self) { media in
                        MixedContentView(content: media, savedPosts: savedPosts, savedComments: savedComments, appTheme: appTheme, bypassFetchSavedStatus: true)
                            .onAppear {
                                handleMediaAppearance(extractMediaId(from: media))
                            }
                        DividerView(frameHeight: 10, appTheme: appTheme)
                    }
                    
                    if isLoading { // show spinner at the bottom of the feed
                        ProgressView()
                            .id(UUID()) // swift ui bug, needs a uuid to render multiple times. :|
                            .padding()
                    }
                } else {
                    LoadingAnimation(loadingText: "Loading profile...", isLoading: isLoading)
                }
            }
        }
        .navigationTitle(username)
        .navigationBarItems(
            trailing:
                Picker("Filter Profile", selection: $filterType) {
                    Text("Overview").tag("")
                    Text("Posts").tag("submitted")
                    Text("Comments").tag("comments")
                }
        )
        .onAppear {
            if mixedMedia.isEmpty {
                scrapeProfile()
            }
        }
        .refreshable {
            clearFeedAndReload()
        }
        .onChange(of: filterType) { oldVal, _ in
            clearFeedAndReload()
        }
    }

    private func scrapeProfile(_ lastPostAfter: String? = nil, sort: String? = nil) {
        isLoading = true
        
        RedditScraper.scrapeProfile(username: username, lastPostAfter: lastPostAfter, filterType: filterType, trackingParamRemover: trackingParamRemover) { result in
            switch result {
            case .success(let media):
                // Filter out duplicates based on media ID
                let uniqueMedia = media.filter { mediaID in
                    let id = extractMediaId(from: mediaID)
                    if !mediaIDs.contains(id) {
                        mediaIDs.insert(id)
                        return true
                    }
                    return false
                }
                
                mixedMedia.append(contentsOf: uniqueMedia)
                
                if let lastLink = uniqueMedia.last {
                    self.lastPostAfter = extractMediaId(from: lastLink)
                }
            case .failure(let err):
                print("Error: \(err)")
            }
            isLoading = false
        }
    }
    
    private func clearFeedAndReload() {
        withAnimation(.smooth) {
            mixedMedia.removeAll()
//            postIDs.removeAll()
            lastPostAfter = ""
            isLoading = false
        }
        
        scrapeProfile()
    }
    
    private func handleMediaAppearance(_ mediaId: String) {
        guard mixedMedia.count > 0 else {
            return
        }

        let index = Int(Double(mixedMedia.count) * 0.85)
        guard index < mixedMedia.count else {
            return
        }

        let tempMediaId = extractMediaId(from: mixedMedia[index])

        if mediaId == tempMediaId {
            scrapeProfile(lastPostAfter, sort: filterType)
        }
    }
                        
    private func extractMediaId(from media: MixedMedia) -> String {
        switch media {
        case .post(let post, _):
            return post.id
        case .comment(let comment, _):
            return comment.id
        default:
            return ""
        }
    }
}
