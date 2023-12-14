//
//  OnboardingView.swift
//  OpenArtemis
//
//  Created by daniel on 13/12/23.
//

import SwiftUI
import Defaults
struct OnboardingView: View {
    @State var currentPage = 0
    @State var done: Bool = true
    @Environment(\.dismiss) private var dismiss
    @Default(.showingOOBE) var showingOOBE
    var body: some View {
        ZStack{
            VStack {
                switch currentPage {
                case 0: OOBE_WelcomeView()
                case 1: OOBE_PrivacySelector()
                case 2: OOBE_SubsImporter()
                case 3: ImportURLSheet(showingThisSheet: $done)
                default: OOBE_WelcomeView()
                }
                
            }
            
            if currentPage != 3 {
                VStack{
                    Spacer()
                    PageControl(currentPage: $currentPage)
                        .padding()
                        .background(
                            currentPage != 0 ?
                            Rectangle()
                                .foregroundStyle(.ultraThinMaterial)
                                .frame(width: UIScreen.screenWidth)
                            : nil
                        )
                }
                .padding(.bottom, currentPage != 0 ? 0 : 100)
                .ignoresSafeArea()
            }
        }
        .onChange(of: done){ _ in
            dismiss()
        }
        .onDisappear{
            showingOOBE = false
        }
    }
}

struct PageControl: View {
    @Binding var currentPage: Int
    var buttonNames = ["Begin your Journey", "Next", "Got it!"]
    var body: some View {
        VStack{
            Button{
                withAnimation{
                    currentPage += 1
                }
            } label: {
                Label(buttonNames[max(min(currentPage, buttonNames.count - 1), 0)], systemImage: "pencil")
                    .labelStyle(.titleOnly)
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            if currentPage != 0 {
                Button {
                    withAnimation{
                        currentPage -= currentPage <= 0 ? 0 : 1
                    }
                } label: {
                    Label("Back", systemImage: "pencil")
                        .labelStyle(.titleOnly)
                        .font(.subheadline)
                }
                .buttonStyle(.borderless)
            }
        }
    }
}
