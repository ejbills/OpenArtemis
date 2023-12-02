//
//  SettingsView.swift
//  OpenArtemis
//
//  Created by daniel on 02/12/23.
//

import SwiftUI
import Defaults

struct SettingsView: View {
  @Default(.preferredThemeMode) var preferredThemeMode
  @Default(.accentColor) var accentColor
  @State var currentAppIcon: String = "AppIcon"
  var body: some View {
    List{
      Section("Theming"){
        Picker("Preferred Theme", selection: Binding(get: {
          preferredThemeMode
        }, set: { val, _ in
          preferredThemeMode = val
        })){
          Text("Automatic").tag(PreferredThemeMode.automatic)
          Text("Light").tag(PreferredThemeMode.light)
          Text("Dark").tag(PreferredThemeMode.dark)
        }
        ColorPicker("Accent Color", selection: $accentColor)
        
        NavigationLink(destination: ChangeAppIconView(), label: {
          HStack{
            Image(uiImage: UIImage(named: currentAppIcon)!)
              .resizable()
              .frame(width: 24, height: 24)
              .mask(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5)))
            Text("App Icon")
          }
        })
      }
    }
    .preferredColorScheme(preferredThemeMode.id == 0 ? nil : preferredThemeMode.id == 1 ? .light : .dark)
    .navigationTitle("Settings")
    .onAppear{
      currentAppIcon = AppIconManager().getCurrentIconName()
    }
  }

}

#Preview {
  SettingsView()
}


