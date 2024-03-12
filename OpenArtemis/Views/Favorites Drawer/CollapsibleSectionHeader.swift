//
//  CollapsibleSectionHeader.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 3/12/24.
//

import SwiftUI

struct CollapsibleSectionHeader: View {
    
    @State var title: String
    @Binding var isOn: Bool
    @State var onLabel: String
    @State var offLabel: String
    
    var textSizePreference: TextSizePreference
    
    var body: some View {
        Button(action: {
            withAnimation {
                isOn.toggle()
            }
        }, label: {
            HStack {
                if isOn {
                    Text(onLabel)
                    Image(systemName: "arrowshape.up.fill")
                } else {
                    Text(offLabel)
                    Image(systemName: "arrowshape.down.fill")
                }
            }
        })
        .font(textSizePreference.body)
        .foregroundColor(.gray)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .overlay(
            Text(title),
            alignment: .leading
        )
    }
}
