//
//  PrivacyTab.swift
//  OpenArtemis
//
//  Created by daniel on 09/12/23.
//

import SwiftUI
import Defaults

struct PrivacyTab: View {
    
    // Stats
    @Default(.trackStats) var trackStats
    @Default(.trackersRemoved) var trackersRemoved
    @Default(.URLsRedirected) var URLsRedirected
    
    let appTheme: AppThemeSettings
    
    var body: some View {
        ThemedList(appTheme: appTheme) {
            
            if trackStats {
                Section{
                    HStack(spacing: 12) {
                        HeroBox(bigText: "\(trackersRemoved)", littleText: "Trackers removed")
                        HeroBox(bigText: "\(URLsRedirected)", littleText: "Websites redirected")
                    }
                }
                .frame(maxWidth: .infinity)
                .id("bigButtons")
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
            
            RemoveTrackinParamsView()
            
            
            RedirectWebsitesView()
            
            Section("Other") {
                Toggle("Track Stats", isOn: $trackStats)
            }
        }
       
        .navigationTitle("Privacy")
    }
}

struct RedirectWebsitesView: View {
    // Redirects
    
    @Default(.youtubeRedirect) var youtubeRedirect
    @Default(.twitterRedirect) var twitterRedirect
    @Default(.mediumRedirect) var mediumRedirect
    @Default(.imgurRedirect) var imgurRedirect
    @Default(.redirectToPrivateSites) var redirectToPrivateSites
    @Default(.appTheme) var appTheme
    var body: some View {
        Section("Redirect Websites"){
            Toggle("Redirect to Private Websites", isOn: Binding(get: {
                redirectToPrivateSites
            }, set: { val in
                withAnimation{
                    redirectToPrivateSites = val
                    appTheme.showOriginalURL = false
                }
            }))
            Toggle("Display Original URL", isOn: $appTheme.showOriginalURL)
                .disabled(!redirectToPrivateSites)
            
            if redirectToPrivateSites {
                RedirectElement(text: $youtubeRedirect, originalName: "Youtube", redirectName: "Invidious")
                RedirectElement(text: $twitterRedirect, originalName: "Twitter / X", redirectName: "Nitter")
                RedirectElement(text: $mediumRedirect, originalName: "Medium", redirectName: "Scribe")
                RedirectElement(text: $imgurRedirect, originalName: "Imgur", redirectName: "Rimgo")
            }
        }
    }
}

struct RemoveTrackinParamsView: View {
    
    @Default(.removeTrackingParams) var removeTrackingParams
    @EnvironmentObject var trackingParamRemover: TrackingParamRemover
    
    @State var currentBlockedAmount: Int = 0
    @State var showingSuccessfullUpdateAlert: Bool = false
    
    var body: some View {
        Section{
            Toggle("Remove Tracking Parameter", isOn: $removeTrackingParams)
            //least confusing nested if
                .onChange(of: removeTrackingParams) { oldToggle, newToggle in
                    newToggle ? trackingParamRemover.updateTrackingList{ res in
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
            .disabled(!removeTrackingParams)
            .alert(isPresented: $showingSuccessfullUpdateAlert, content: {
                Alert(title: Text("Successfully Updated Blocklist!"))
            })
        } header: {
            Text("Tracking")
        } footer: {
            removeTrackingParams ? Text("\(currentBlockedAmount) blocklable Parameters loaded from [Adguard Tracking Params blocklist](https://github.com/AdguardTeam/AdguardFilters/blob/master/TrackParamFilter/sections/general_url.txt).") : Text("Enabling Remove Tracking Parameter will download the [Adguard Tracking Params blocklist](https://github.com/AdguardTeam/AdguardFilters/blob/master/TrackParamFilter/sections/general_url.txt).")
        }
         .onAppear{
            currentBlockedAmount = trackingParamRemover.trackinglistLength
        }
    }
}

struct RedirectElement: View {
    @Binding var text: String
    var originalName: String
    var redirectName: String
    var body: some View {
        VStack{
            HStack{
                Text(originalName)
                Image(systemName: "arrow.right")
                Text(redirectName)
                Spacer()
            }
            .font(.caption)
            .opacity(0.5)
            TextField(text: $text, label: {
                Text(redirectName)
            })
            
        }
    }
}
