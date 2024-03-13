//
//  DefaultSubredditRowView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 12/2/23.
//

import SwiftUI
import CachedImage

struct DefaultSubredditRowView: View {
    var title: String
    var iconSystemName: String?
    var iconURL: String?
    var iconColor: Color
    var editMode: Bool?
    var removeMulti: (() -> Void)? = nil
    
    @State var avgImageColor: UIColor? = nil
    
    var body: some View {
        HStack {
            if let editMode, editMode, let removeMulti = removeMulti {
                Button(action: {
                    removeMulti()
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 20))
                }
            }
            
            Label(
                title: { 
                    Text(title)
                        .foregroundStyle(avgImageColor != nil ? Color(uiColor: avgImageColor!).isDark ? .white : .black : .black)
                },
                icon: {
                    Image(systemName: iconSystemName ?? "square.3.layers.3d")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color.white)
                        .padding(6)
                        .frame(maxWidth: 30, maxHeight: 30)
                        .background{
                            RoundedRectangle(cornerSize: CGSize(width: 7, height: 7))
                                .foregroundStyle(iconColor)
                                .frame(width: 30, height: 30)
                        }
                }
            )
            .labelStyle(DefaultLabelStyle())
            .foregroundColor(.primary)
        }
        .if(iconURL != nil) { content in
            content.listRowBackground(
                GeometryReader { geometry in
                    if let iconURL = iconURL, let url = URL(string: iconURL) {
                        CachedImage(
                            url: url,
                            content: { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .clipped()
                                    .brightness(-0.2)
                                    .opacity(0.8)
                                    .onAppear{
                                        avgImageColor = image.asUIImage().averageColor
                                    }
                            },
                            placeholder: {
                                Color.clear
                            }
                        )
                        
                    }
                }
            )
        }
    }
}

