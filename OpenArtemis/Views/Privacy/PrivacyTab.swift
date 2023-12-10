//
//  PrivacyTab.swift
//  OpenArtemis
//
//  Created by daniel on 09/12/23.
//

import SwiftUI
import Defaults

struct PrivacyTab: View {
    
    @Default(.showOriginalURL) var showOriginalURL
    @Default(.redirectToPrivateSites) var redirectToPrivateSites
    @Default(.removeTrackingParams) var removeTrackingParams
    @EnvironmentObject var trackingParamRemover: TrackingParamRemover
    
    @State var currentBlockedAmount: Int = 0
    @State var showingSuccessfullUpdateAlert: Bool = false
    var body: some View {
        List {
            Section{
                Toggle("Redirect to Private Websites", isOn: $redirectToPrivateSites)
                Toggle("Display Original URL", isOn: $showOriginalURL)
                    .disabled(!redirectToPrivateSites)
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
                .alert(isPresented: $showingSuccessfullUpdateAlert, content: {
                    Alert(title: Text("Successfully Updated Blocklist!"))
                })
            } header: {
                Text("Privacy")
            } footer: {
                removeTrackingParams ? Text("\(currentBlockedAmount) blocklable Parameters loaded from [Adguard Tracking Params blocklist](https://github.com/AdguardTeam/AdguardFilters/blob/master/TrackParamFilter/sections/general_url.txt).") : Text("Enabling Remove Tracking Parameter will download the [Adguard Tracking Params blocklist](https://github.com/AdguardTeam/AdguardFilters/blob/master/TrackParamFilter/sections/general_url.txt).")
            }
        }
        .onAppear{
            currentBlockedAmount = trackingParamRemover.trackinglistLength
        }
    }
}

#Preview {
    PrivacyTab()
}
