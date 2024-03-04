//
//  ImportURLSheet.swift
//  OpenArtemis
//
//  Created by daniel on 03/12/23.
//

import SwiftUI
import CoreData

struct ImportURLSheet: View {
    @State var url: String = ""
    @State var subreddits: [String] = []
    @State var displayImport: Bool = false
    
    @Binding var showingThisSheet: Bool
    
    let appTheme: AppThemeSettings
    let textSizePreference: TextSizePreference
    
    var body: some View {
        ZStack {
            if displayImport {
                ThemedList(appTheme: appTheme, textSizePreference: textSizePreference) {
                    Spacer()
                        .frame(height: 50)
                    
                    ForEach(subreddits, id: \.self){ sub in
                        HStack {
                            Button {
                                subreddits = subreddits.filter{ $0 != sub }
                            } label: {
                                Label("Delete", systemImage: "minus.circle.fill")
                                    .labelStyle(.iconOnly)
                                    .foregroundColor(.red)
                            }
                            Text(sub)
                        }
                    }
                    
                    Spacer()
                        .frame(height: 50)
                }
            }
            
            
            VStack {
                HStack{
                    TextField("Multireddit URL", text: $url)
                        .padding()
                        .textFieldStyle(.roundedBorder)
                }
                .frame(width: UIScreen.screenWidth)
                .if(displayImport){ view in
                    view.background(
                        Material.ultraThinMaterial
                    )
                }
                if !displayImport{
                    Text("Paste your Multireddit URL in here")
                        .opacity(0.5)
                }
                if displayImport {
                    Spacer()
                }
            }
            
            
            if displayImport {
                VStack {
                    Spacer()
                    Button {
                        for sub in subreddits {
                            let tempSubreddit = LocalSubreddit(context: PersistenceController.shared.container.viewContext)
                            tempSubreddit.name = sub
                        }
                        PersistenceController.shared.save()
                        showingThisSheet = false
                    } label: {
                        Label("Import", systemImage: "plus")
                            .labelStyle(.titleOnly)
                    }
                    .padding()
                    .font(textSizePreference.sizeWithMult(fontSize: 20))
                    .buttonBorderShape(.roundedRectangle)
                    .buttonStyle(.borderedProminent)
                    .frame(width: UIScreen.screenWidth)
                    .background(
                        Material.ultraThinMaterial
                    )
                }
            }
            
        }
        .onChange(of: url){ oldURL, newURL in
            subreddits = parseSubreddits(string: newURL)
            
            withAnimation{
                displayImport = !subreddits.isEmpty
            }
            
        }
        
    }
    
    func parseSubreddits(string: String) -> [String] {
        if let url = URL(string: string) {
            // Path components
            var path = url.pathComponents
            // Drop the first two components which are / and r
            if path.count >= 2 {
                path.removeFirst(2)
            }
            // Join remaining path components and split by "+"
            let subreddits = path.joined(separator: "").split(separator: "+").map { String($0) }
            
            return subreddits
        } else {
            return []
        }
    }
    
}

