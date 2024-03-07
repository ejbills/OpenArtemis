//
//  PostTagsPill.swift
//  OpenArtemis
//
//  Created by Igor Marcossi on 06/03/24.
//

import SwiftUI

struct PostTagsPill: View {
  var active = true
  var infos: [TagPillInfo]
  let appTheme: AppThemeSettings
  let textSizePreference: TextSizePreference
    var body: some View {
      HStack {
        ForEach(Array(infos.enumerated()), id: \.element) { i, info in
          DetailTagView(icon: info.icon, data: info.label, appTheme: appTheme, textSizePreference: textSizePreference)
            .highPriorityGesture(info.onTap == nil ? nil : TapGesture().onEnded { info.onTap?() } )
          
          if (infos.count - 1) > i {
            Color.primary.opacity(0.1).frame(maxWidth: 1, maxHeight: .infinity)
          }
        }
      }
      .fixedSize(horizontal: false, vertical: true)
      .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
      .background(Capsule(style: .continuous).fill(.primary.opacity(0.10)))
      .compositingGroup()
      .opacity(active ? 1 : 0.75)
      .background(Capsule(style: .continuous).fill(Color.invertedPrimary.shadow(.drop(color: .black.opacity(active ? 0.3 : 0), radius: 16, y: 12))))
    }
  
  struct TagPillInfo: Identifiable, Hashable {
    static func == (lhs: PostTagsPill.TagPillInfo, rhs: PostTagsPill.TagPillInfo) -> Bool { lhs.id == rhs.id }
    var id: String { self.icon + self.label }
    let icon: String
    let label: String
    var onTap: (() -> ())? = nil
    
    public func hash(into hasher: inout Hasher) {
      hasher.combine(self.id)
    }
  }
}
