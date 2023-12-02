//
//  ChangeAppIconView.swift
//  OpenArtemis
//
//  Created by daniel on 02/12/23.
//

import SwiftUI

struct ChangeAppIconView: View {
  var appIconManager = AppIconManager()
  @State var currentAppicon: String = "Default"
  var body: some View {
    List{
      ForEach(appIconManager.getIcons().sorted(), id: \.self){ icon in
        AppIconElement(icon: icon, currentAppIcon: $currentAppicon)
      }
    }
    .onAppear{
      currentAppicon = appIconManager.getCurrentIconName()
    }
  }
}

struct AppIconElement: View {
  let icon: String
  @Binding var currentAppIcon: String //pass the icon as a Binding so we dont have to query the AppIcon Manager for ever alternate Icon
  @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

  var body: some View {
    HStack{
      Image(uiImage: UIImage(named: icon)!)
        .resizable()
        .frame(width: 48, height: 48)
        .mask(RoundedRectangle(cornerSize: CGSize(width: 15, height: 15)))
      Text(icon.localizedCapitalized)
        .font(.headline)
      Spacer()
      
      if currentAppIcon == icon {
        Image(systemName: "checkmark")
          .foregroundColor(Color.artemisAccent)
      }
    }
    .onTapGesture {
      AppIconManager().setAppIconWithoutAlert(to: icon)
      currentAppIcon = icon
      self.presentationMode.wrappedValue.dismiss()

    }
  }
}
