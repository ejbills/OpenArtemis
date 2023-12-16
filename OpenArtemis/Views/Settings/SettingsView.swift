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
    @Default(.darkBackground) var darkBackground
    @Default(.lightBackground) var lightBackground
    @Default(.compactMode) var compactMode
    @Default(.tagBackground) var tagBackground
    @Default(.showOriginalURL) var showOriginalURL
    @Default(.redirectToPrivateSites) var redirectToPrivateSites
    @Default(.removeTrackingParams) var removeTrackingParams
    @Default(.over18) var over18
    
    @Default(.showJumpToNextCommentButton) var showJumpToNextCommentButton
    
    @FetchRequest(sortDescriptors: [ SortDescriptor(\.name) ]) var localFavorites: FetchedResults<LocalSubreddit>
    
    @State var currentAppIcon: String = "AppIcon"
    
    @State var showingImportDalog: Bool = false
    @State var showingURLImportSheet: Bool = false
    
    @State var exportedURL: String? = nil
    @State var presentingFileMover: Bool = false
    @State var doImport: Bool = false
    
    
    @State var showToast: Bool = false
    @State var toastTitle: String = "Success!"
    @State var toastIcon: String = "checkmark.circle.fill"
    var body: some View {
        ThemedList {
            Section("Appearance"){
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
                ColorPicker("Light Mode Background Color", selection: $lightBackground)
                ColorPicker("Dark Mode Background Color", selection: $darkBackground)
                Toggle("Compact mode", isOn: $compactMode)
                Toggle("Show tags with background", isOn: $tagBackground)
                
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
            Section("Comments"){
                Toggle("Jump to Next Comment Button", isOn: $showJumpToNextCommentButton)
            }
            Section("Subreddits"){
                Picker("Are you over 18 (Allow NSFW content)?", selection: $over18) {
                    Text("No").tag(false)
                    Text("Yes").tag(true)
                }
                Button{
                    exportedURL = SubredditIOManager().exportSubs(fileName: "artemis_subs.json", subreddits: localFavorites.compactMap { $0.name })
                    presentingFileMover = exportedURL != nil
                } label: {
                    Label("Export Subreddits", systemImage: "arrowshape.turn.up.left")
                }
                Button{
                    showingImportDalog.toggle()
                } label: {
                    Label("Import Subreddits", systemImage: "arrowshape.turn.up.right")
                }
                .confirmationDialog("What do you want to Import?", isPresented: $showingImportDalog, titleVisibility: .automatic, actions: {
                    Button{
                        showingURLImportSheet.toggle()
                    } label: {
                        Label("Import Subreddits From URL", systemImage: "link")
                    }
                    Button {
                        doImport.toggle()
                    } label: {
                        Label("Import Subreddits From File", systemImage: "doc")
                    }
                })
                .sheet(isPresented: $showingURLImportSheet, content: {
                    ImportURLSheet(showingThisSheet: $showingURLImportSheet)
                    
                })
                .fileMover(isPresented: $presentingFileMover, file: URL(string: exportedURL ?? ""), onCompletion: { _ in })
                .fileImporter(isPresented: $doImport, allowedContentTypes: [.json], allowsMultipleSelection: false, onCompletion: { result in
                    switch result {
                    case .success(let file):
                        let success = SubredditIOManager().importSubreddits(jsonFilePath: file[0])
                        if success {
                            showToast.toggle()
                        } else {
                            toastTitle = "There was an Error importing"
                            toastIcon = "xmark.circle.fill"
                            showToast.toggle()
                        }
                    case .failure(_):
                        toastTitle = "There was an Error importing"
                        toastIcon = "xmark.circle.fill"
                        showToast.toggle()
                    }
                    
                })
            }
            
            
            
        }
        .preferredColorScheme(preferredThemeMode.id == 0 ? nil : preferredThemeMode.id == 1 ? .light : .dark)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear{
            currentAppIcon = AppIconManager().getCurrentIconName()
           
        }
        .toast(isPresented: $showToast, style: .popup, title: toastTitle,systemIcon: toastIcon, speed: 1.5, tapToDismiss: false, onAppear: {})
    }
}



