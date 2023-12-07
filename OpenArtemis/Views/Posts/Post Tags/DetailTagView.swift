//
//  DetailTagView.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 11/28/23.
//

import SwiftUI

struct DetailTagView: View {
    let icon: String
    let data: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 15, height: 15)
            
            Text(data)
                .font(.footnote)
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(RoundedRectangle(cornerRadius: 6).foregroundColor(tagBgColor))
    }
}
