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
    @Default(.showOriginalURL) var showOriginalURL
    @Default(.redirectToPrivateSites) var redirectToPrivateSites
    @Default(.removeTrackingParams) var removeTrackingParams
    @EnvironmentObject var trackingParamRemover: TrackingParamRemover
    
    @State var currentAppIcon: String = "AppIcon"
    @State var currentBlockedAmount: Int = 0
    @State var showingSuccessfullUpdateAlert: Bool = false
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
            
            Section{
                Toggle("Redirect to Private Websites", isOn: $redirectToPrivateSites)
                Toggle("Display Original URL", isOn: $showOriginalURL)
                    .disabled(!redirectToPrivateSites)
                Toggle("Remove Tracking Parameter", isOn: $removeTrackingParams)
                //least confusing nested if
                    .onChange(of: removeTrackingParams){ toggle in
                        toggle ? trackingParamRemover.updateTrackingList{ res in
                            if res {
                                currentBlockedAmount = trackingParamRemover.trackinglistLength
                            }
                        } : trackingParamRemover.unloadTrackingList()
                    }
                Button{
                    trackingParamRemover.unloadTrackingList()
                    trackingParamRemover.updateTrackingList{ res in
                        if res {
                            currentBlockedAmount = trackingParamRemover.trackinglistLength
                        }
                        showingSuccessfullUpdateAlert = res
                    }
                } label: {
                    Label("Update Blocklist", systemImage: "arrow.triangle.2.circlepath")
                }
                .alert(isPresented: $showingSuccessfullUpdateAlert, content: {
                    Alert(title: Text("Successfully Updated Blocklist!"))
                })
            } header: {
                Text("Privacy")
            } footer: {
                removeTrackingParams ? Text("\(currentBlockedAmount) blocklable Parameters loaded from [Adguard Tracking Params blocklist](https://github.com/AdguardTeam/AdguardFilters/blob/master/TrackParamFilter/sections/general_url.txt).") : Text("Enabling Remove Tracking Parameter will download the [Adguard Tracking Params blocklist](https://github.com/AdguardTeam/AdguardFilters/blob/master/TrackParamFilter/sections/general_url.txt).")
            }
            
        }
        .preferredColorScheme(preferredThemeMode.id == 0 ? nil : preferredThemeMode.id == 1 ? .light : .dark)
        .navigationTitle("Settings")
        .onAppear{
            currentAppIcon = AppIconManager().getCurrentIconName()
            currentBlockedAmount = trackingParamRemover.trackinglistLength
        }
    }
    
}



