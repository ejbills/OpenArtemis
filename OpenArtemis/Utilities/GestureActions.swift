//
//  GestureActions.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 05/12/23.
//  Based on Mlem for Lemmy swipe actions - https://github.com/mlemgroup/swipeyactions
//

import Foundation
import SwiftUI
import Defaults

struct GestureAction {
    
    struct Symbol {
        let emptyName: String
        let fillName: String
    }

    enum ActionType {
        case synchronous(() -> Void)
        case asynchronous(() async -> Void)
        
        func performAction() async {
            switch self {
            case .synchronous(let action):
                action()
            case .asynchronous(let action):
                await action()
            }
        }
    }
    
    let symbol: Symbol
    let color: Color
    let action: ActionType

    init(symbol: Symbol, color: Color, action: @escaping () -> Void) {
        self.symbol = symbol
        self.color = color
        self.action = .synchronous(action)
    }
    
    init(symbol: Symbol, color: Color, action: @escaping () async -> Void) {
        self.symbol = symbol
        self.color = color
        self.action = .asynchronous(action)
    }
}


struct GestureView: ViewModifier {
    
    private var dragDistanceToSecondaryAction: CGFloat = 150.0
    
    // state
    @GestureState var dragState: CGFloat = .zero
    @State var dragPosition: CGFloat = .zero
    @State var prevDragPosition: CGFloat = .zero
    @State var dragBackground: Color? = Color(uiColor: UIColor.systemBackground)
    @State var leadingSwipeSymbol: String?
    @State var trailingSwipeSymbol: String?
    
    let primaryLeadingAction: GestureAction?
    let secondaryLeadingAction: GestureAction?
    let primaryTrailingAction: GestureAction?
    let secondaryTrailingAction: GestureAction?
    
    init(primaryLeadingAction: GestureAction?,
         secondaryLeadingAction: GestureAction?,
         primaryTrailingAction: GestureAction?,
         secondaryTrailingAction: GestureAction?
    ) {
        // assert that no secondary action exists without a primary action
        // this is logically equivalent to (primaryAction == nil -> secondaryAction == nil)
        assert(
            primaryLeadingAction != nil || secondaryLeadingAction == nil,
            "No secondary action \(secondaryLeadingAction != nil) should be present without a primary \(primaryLeadingAction == nil)"
        )
        
        assert(
            primaryTrailingAction != nil || secondaryTrailingAction == nil,
            "No secondary action should be present without a primary"
        )
        
        self.primaryLeadingAction = primaryLeadingAction
        self.secondaryLeadingAction = secondaryLeadingAction
        self.primaryTrailingAction = primaryTrailingAction
        self.secondaryTrailingAction = secondaryTrailingAction
        
        // other init
        _leadingSwipeSymbol = State(initialValue: primaryLeadingAction?.symbol.fillName)
        _trailingSwipeSymbol = State(initialValue: primaryTrailingAction?.symbol.fillName)
    }
    
    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable function_body_length
    func body(content: Content) -> some View {
        content
            .offset(x: dragPosition) // using dragPosition so we can apply withAnimation() to it
        // needs to be high priority or else dragging on links leads to navigating to the link at conclusion of drag
            .highPriorityGesture(
                DragGesture(minimumDistance: 40, coordinateSpace: .global) // min distance prevents conflict with scrolling drag gesture
                    .updating($dragState) { value, state, _ in
                        // this check adds a dead zone to the left side of the screen so it doesn't interfere with navigation
                        if dragState != .zero || value.location.x > 70 {
                            state = value.translation.width
                        }
                    }
            )
            .onChange(of: dragState) { _, newDragState in
                // if dragState changes and is now 0, gesture has ended; compute action based on last detected position
                if newDragState == .zero {
                    draggingDidEnd()
                } else {
                    guard shouldRespondToDragPosition(newDragState) else {
                        // as swipe actions are optional we don't allow dragging without a primary action
                        return
                    }

                    // update position
                    dragPosition = newDragState
                    
                    // update color and symbol. If crossed an edge, play a gentle haptic
                    if dragPosition <= -dragDistanceToSecondaryAction && secondaryTrailingAction != nil {
                        dragBackground = secondaryTrailingAction?.color ?? primaryTrailingAction?.color
                        trailingSwipeSymbol = secondaryTrailingAction?.symbol.fillName ?? primaryLeadingAction?.symbol.fillName
                        
                        if prevDragPosition > -dragDistanceToSecondaryAction && secondaryTrailingAction != nil {
                            // crossed from short swipe -> long swipe
                            HapticManager.shared.mushyInfo()
                        }
                    } else if dragPosition <= -1 * 50 {
                        trailingSwipeSymbol = primaryTrailingAction?.symbol.fillName
                        dragBackground = primaryTrailingAction?.color

                        if prevDragPosition > -1 * 50 {
                            // crossed from no swipe -> short swipe
                            HapticManager.shared.gentleInfo()
                        } else if prevDragPosition <= -dragDistanceToSecondaryAction && secondaryTrailingAction != nil {
                            // crossed from long swipe -> short swipe
                            HapticManager.shared.mushyInfo()
                        }
                    } else if dragPosition < 0 {
                        trailingSwipeSymbol = primaryTrailingAction?.symbol.emptyName
                        dragBackground = primaryTrailingAction?.color.opacity(-(dragPosition / 50))

                        if prevDragPosition <= -1 * 50 {
                            // crossed from short swipe -> no swipe
                            HapticManager.shared.mushyInfo()
                        }
                    } else if dragPosition < 50 {
                        leadingSwipeSymbol = primaryLeadingAction?.symbol.emptyName
                        dragBackground = primaryLeadingAction?.color.opacity(dragPosition / 50)

                        if prevDragPosition >= 50 {
                            // crossed from short swipe -> no swipe
                            HapticManager.shared.mushyInfo()
                        }
                    } else if dragPosition < dragDistanceToSecondaryAction {
                        leadingSwipeSymbol = primaryLeadingAction?.symbol.fillName
                        dragBackground = primaryLeadingAction?.color

                        if prevDragPosition < 50 {
                            // crossed from no swipe -> short swipe
                            HapticManager.shared.gentleInfo()
                        } else if prevDragPosition >= dragDistanceToSecondaryAction && secondaryLeadingAction != nil {
                            // crossed from long swipe -> short swipe
                            HapticManager.shared.mushyInfo()
                        }
                    } else {
                        leadingSwipeSymbol = secondaryLeadingAction?.symbol.fillName ?? primaryLeadingAction?.symbol.fillName
                        dragBackground = secondaryLeadingAction?.color ?? primaryLeadingAction?.color

                        if prevDragPosition < dragDistanceToSecondaryAction && secondaryLeadingAction != nil {
                            // crossed from short swipe -> long swipe
                            HapticManager.shared.firmerInfo()
                        }
                    }
                    prevDragPosition = dragPosition
                }
            }
            .background {
                dragBackground
                    .overlay {
                        if prevDragPosition != 0 {
                            HStack(spacing: 0) {
                                Image(systemName: leadingSwipeSymbol ?? "exclamationmark.triangle")
                                    .font(.title)
                                    .transition(.scale.animation(.easeOut))
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                Spacer()
                                Image(systemName: trailingSwipeSymbol ?? "exclamationmark.triangle")
                                    .font(.title)
                                    .transition(.scale.animation(.easeOut))
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                            }
                            .accessibilityHidden(true) // prevent these from popping up in VO
                        }
                    }
            }
        // prevents various animation glitches
            .transaction { transaction in
                transaction.disablesAnimations = true
            }
    }
    
    private func draggingDidEnd() {
        let finalDragPosition = prevDragPosition

        reset()
        
        if finalDragPosition < -50 || finalDragPosition > 50 {
            HapticManager.shared.confirmationInfo()
        }
        
        DispatchQueue.main.async {
            if finalDragPosition < -dragDistanceToSecondaryAction {
                Task(priority: .userInitiated) {
                    if secondaryTrailingAction != nil {
                        await secondaryTrailingAction?.action.performAction()
                    } else {
                        await primaryTrailingAction?.action.performAction()
                    }
                }
            } else if finalDragPosition < -1 * 50 {
                Task(priority: .userInitiated) {
                    await primaryTrailingAction?.action.performAction()
                }
            } else if finalDragPosition > dragDistanceToSecondaryAction {
                Task(priority: .userInitiated) {
                    if secondaryLeadingAction != nil {
                        await secondaryLeadingAction?.action.performAction()
                    } else {
                        await primaryLeadingAction?.action.performAction()
                    }
                }
            } else if finalDragPosition > 50 {
                Task(priority: .userInitiated) {
                    await primaryLeadingAction?.action.performAction()
                }
            }
        }
    }

    private func reset() {
        withAnimation(.spring(response: 0.25)) {
            dragPosition = .zero
            prevDragPosition = .zero
            leadingSwipeSymbol = primaryLeadingAction?.symbol.emptyName
            trailingSwipeSymbol = primaryTrailingAction?.symbol.emptyName
            dragBackground = Color(uiColor: UIColor.systemBackground)
        }
    }
    
    private func shouldRespondToDragPosition(_ position: CGFloat) -> Bool {
        if position > 0, primaryLeadingAction == nil {
            return false
        }
        
        if position < 0, primaryTrailingAction == nil {
            return false
        }
        
        return true
    }
}
// swiftlint:enable cyclomatic_complexity
// swiftlint:enable function_body_length

extension View {
    @ViewBuilder
    func gestureActions(primaryLeadingAction: GestureAction?,
                        secondaryLeadingAction: GestureAction?,
                        primaryTrailingAction: GestureAction?,
                        secondaryTrailingAction: GestureAction?) -> some View {
        if Defaults[.swipeAnywhere] {
            self
        } else {
            modifier(
                GestureView(
                    primaryLeadingAction: primaryLeadingAction,
                    secondaryLeadingAction: secondaryLeadingAction,
                    primaryTrailingAction: primaryTrailingAction,
                    secondaryTrailingAction: secondaryTrailingAction
                )
            )
        }
    }
}
