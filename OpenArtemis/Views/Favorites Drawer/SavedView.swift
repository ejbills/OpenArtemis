//
//  SavedView.swift
//  OpenArtemis
//
//  Created by daniel on 08/12/23.
//

import SwiftUI
import CoreData

struct SavedView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(sortDescriptors: []) var savedPosts: FetchedResults<SavedPost>
    @FetchRequest(sortDescriptors: []) var savedComments: FetchedResults<SavedComment>
    @State var mixedMediaLinks: [ItemTuple] = []
    
    var body: some View {
        ScrollView {
            ForEach(mixedMediaLinks, id: \.self) { item in
                MixedContentView(content: item.content, savedPosts: savedPosts, savedComments: savedComments)
                DividerView(frameHeight: 10)
            }
        }
        .onAppear {
            updateFeed()
        }
        .refreshable {
            updateFeed()
        }
        .navigationTitle("Saved")
    }
    
    func updateFeed() {
        mixedMediaLinks = []
        //map the posts and comments loaded from CoreData to the mixedMediaLinks Array
        let posts = savedPosts.map {
            let post = PostUtils.shared.savedPostToPost(context: managedObjectContext, $0)
            return ItemTuple(date: post.0 ?? Date(),content: Either<Post, CommentWithPostLink>.first(post.1))
        }
        let comments = savedComments.map {
            let comment = CommentUtils().savedCommentToComment($0)
            //Triple isnt real it cant hurt you
            //Tripe: ٩(⊙‿⊙‿⊙)۶
            return ItemTuple(date: comment.0 ?? Date(), content: Either<Post, CommentWithPostLink>.second(CommentWithPostLink(comment: comment.1, postLink: comment.2)))
        }
        
        mixedMediaLinks.append(contentsOf: posts)
        mixedMediaLinks.append(contentsOf: comments)
        mixedMediaLinks = mixedMediaLinks.sorted { $0.date > $1.date}
    }
}


///This is a view that combines both Posts and Comments
struct MixedContentView: View {
    var content: Either<Post, CommentWithPostLink>
    let savedPosts: FetchedResults<SavedPost>
    let savedComments: FetchedResults<SavedComment>
    
    @EnvironmentObject var coordinator: NavCoordinator
    
    @State var isLoadingCommentPost: Bool = false
    @State var isCommentSaved: Bool = false
    
    var body: some View {
        switch content {
        case .first(let post):
            PostFeedView(post: post)
                .onTapGesture {
                    coordinator.path.append(PostResponse(post: post))
                }
        case .second(let comment):
            CommentView(comment: comment.comment, numberOfChildren: 0)
                .savedIndicator($isCommentSaved, offset: (-8,-8))
                .onAppear{
                    isCommentSaved = savedComments.contains { $0.id == comment.comment.id }
                }
                .loadingOverlay(isLoading: isLoadingCommentPost, radius: 0)
                .addGestureActions(primaryLeadingAction: GestureAction(symbol: .init(emptyName: "star", fillName: "star.fill"), color: .green, action: {
                    let commentsURL = comment.postLink
                    RedditScraper.scrapePostFromCommentsURL(url: commentsURL, trackingParamRemover: nil) { result in
                        switch result {
                        case .success(let post):
                            isCommentSaved = CommentUtils().toggleSaved(comment: comment.comment, post: post, savedComments: savedComments)
                        case .failure(let failure):
                            print("Error: \(failure)")
                        }
                    }
                    
                }), secondaryLeadingAction: nil, primaryTrailingAction: nil, secondaryTrailingAction: nil)
                .onTapGesture {
                    if !isLoadingCommentPost {
                        withAnimation{
                            isLoadingCommentPost = true
                        }
                        
                        let commentsURL = comment.postLink
                        RedditScraper.scrapePostFromCommentsURL(url: commentsURL, trackingParamRemover: nil) { result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success(let post):
                                    coordinator.path.append(PostResponse(post: post))
                                case .failure(let failure):
                                    print("Error: \(failure)")
                                }
                                
                                isLoadingCommentPost = false
                            }
                        }
                    }
                }
        }
    }
}


/// A structure representing a comment with a link to the associated post.
struct CommentWithPostLink: Codable, Equatable, Hashable {
    /// The comment.
    let comment: Comment
    
    /// The link to the associated post.
    let postLink: String
}

/// A tuple that combines a date with content that can be either a post or a comment with a post link.
struct ItemTuple: Hashable {
    /// The date when the item was added.
    let date: Date
    
    /// The content of the item, which can be either a post or a comment with a post link.
    let content: Either<Post, CommentWithPostLink>
}

/// An enum representing either the first type `A` or the second type `B`.
enum Either<A: Codable & Hashable, B: Codable & Hashable>: Codable, Hashable {
    /// The first type.
    case first(A)
    
    /// The second type.
    case second(B)
    
    /// Initializes an instance of `Either` by decoding either the first type `A` or the second type `B`.
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        do {
            let firstType = try container.decode(A.self)
            self = .first(firstType)
        } catch let firstError {
            do {
                let secondType = try container.decode(B.self)
                self = .second(secondType)
            } catch let secondError {
                let context = DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Type mismatch for both types.",
                    underlyingError: Swift.DecodingError.typeMismatch(
                        Any.self,
                        DecodingError.Context(
                            codingPath: decoder.codingPath,
                            debugDescription: "First type error: \(firstError). Second type error: \(secondError)"
                        )
                    )
                )
                throw DecodingError.dataCorrupted(context)
            }
        }
    }
    
    /// Encodes the value into the given encoder.
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .first(let value):
            try container.encode(value)
        case .second(let value):
            try container.encode(value)
        }
    }
}
