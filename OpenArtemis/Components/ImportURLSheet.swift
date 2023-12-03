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
    @State var showingImportStuff: Bool = false
    
    @Binding var showingThisSheet: Bool
    var body: some View {
        ZStack {
            
            
            if showingImportStuff {
                List {
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
                .if(showingImportStuff){ view in
                    view.background(
                        Material.ultraThinMaterial
                    )
                }
                if showingImportStuff {
                    Spacer()
                }
            }
            
            
            if showingImportStuff {
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
                    .font(.system(size: 20, weight: .medium))
                    .buttonBorderShape(.roundedRectangle)
                    .buttonStyle(.borderedProminent)
                    .frame(width: UIScreen.screenWidth)
                    .background(
                        Material.ultraThinMaterial
                    )
                }
            }
            
        }
        .onChange(of: url){ url in
            subreddits = parseSubreddits(string: url)
            withAnimation{
                showingImportStuff = !subreddits.isEmpty
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

