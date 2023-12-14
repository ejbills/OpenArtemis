//
//  CommentSkipper.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/8/23.
//

import SwiftUI

struct CommentSkipper: ViewModifier {
    @Binding var showJumpToNextCommentButton: Bool
    @Binding var topVisibleCommentId: String?
    @Binding var previousScrollTarget: String?
    var rootComments: [Comment]
    var reader: ScrollViewProxy

    func body(content: Content) -> some View {
        content.overlay {
            if showJumpToNextCommentButton {
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        Button {
                            HapticManager.shared.singleClick()
                            withAnimation {
                                jumpToNextComment()
                            }
                        } label: {
                            Label("Jump to Next Comment", systemImage: "chevron.down")
                                .labelStyle(.iconOnly)
                        }
                        .padding()
                        .background {
                            Circle()
                                .foregroundStyle(.thinMaterial)
                        }
                    }
                    .padding()
                }
            }
        }
    }

    private func jumpToNextComment() {
        if topVisibleCommentId == nil, let id = rootComments.first?.id {
            reader.scrollTo(id, anchor: .top)
            topVisibleCommentId = id
            return
        }

        if let topVisibleCommentId = topVisibleCommentId {
            let topVisibleCommentIndex = rootComments.map { $0.id }.firstIndex(of: topVisibleCommentId) ?? 0

            if topVisibleCommentId == previousScrollTarget {
                let nextIndex = min(topVisibleCommentIndex + 1, rootComments.count - 1)
                reader.scrollTo(rootComments[nextIndex].id, anchor: .top)
                previousScrollTarget = nextIndex < rootComments.count - 1 ? rootComments[nextIndex + 1].id : nil
            } else {
                let nextIndex = min(topVisibleCommentIndex + 1, rootComments.count - 1)
                reader.scrollTo(rootComments[nextIndex].id, anchor: .top)
                previousScrollTarget = topVisibleCommentId
            }
        }
    }
}

extension View {
    func commentSkipper(
        showJumpToNextCommentButton: Binding<Bool>,
        topVisibleCommentId: Binding<String?>,
        previousScrollTarget: Binding<String?>,
        rootComments: [Comment],
        reader: ScrollViewProxy
    ) -> some View {
        modifier(
            CommentSkipper(
                showJumpToNextCommentButton: showJumpToNextCommentButton,
                topVisibleCommentId: topVisibleCommentId,
                previousScrollTarget: previousScrollTarget,
                rootComments: rootComments,
                reader: reader
            )
        )
    }
}
