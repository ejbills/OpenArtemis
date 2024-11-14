import SwiftUI
import Defaults

struct FilterView: View {
    let appTheme: AppThemeSettings
    let textSizePreference: TextSizePreference
    
    @Default(.subredditFilters) private var subredditFilters: [String]
    @Default(.keywordFilters) private var keywordFilters: [String]
    @Default(.userFilters) private var userFilters: [String]
    
    @State private var newSubreddit: String = ""
    @State private var newKeyword: String = ""
    @State private var newUser: String = ""
    
    @State private var showingAddSubredditAlert = false
    @State private var showingAddKeywordAlert = false
    @State private var showingAddUserAlert = false
    @State private var showingClearConfirmation = false
    
    var body: some View {
        ThemedList(appTheme: appTheme, textSizePreference: textSizePreference) {
            Section {
                Text("Filtered content will be hidden from your feed and search results. Filters are case-insensitive.")
                    .font(textSizePreference.caption)
                    .foregroundColor(.secondary)
            }
            
            Section("Filtered Keywords") {
                ForEach(keywordFilters, id: \.self) { keyword in
                    HStack {
                        Text(keyword)
                        Spacer()
                    }
                }
                .onDelete { indexSet in
                    keywordFilters.remove(atOffsets: indexSet)
                }
                
                Button(action: {
                    showingAddKeywordAlert = true
                }) {
                    Label("Add Keyword", systemImage: "plus.circle.fill")
                        .foregroundStyle(Color.artemisAccent)
                }
            }
            
            Section("Filtered Subreddits") {
                ForEach(subredditFilters, id: \.self) { subreddit in
                    HStack {
                        Text(subreddit)
                        Spacer()
                    }
                }
                .onDelete { indexSet in
                    subredditFilters.remove(atOffsets: indexSet)
                }
                
                Button(action: {
                    showingAddSubredditAlert = true
                }) {
                    Label("Add Subreddit", systemImage: "plus.circle.fill")
                        .foregroundStyle(Color.artemisAccent)
                }
            }
            
            Section("Filtered Users") {
                ForEach(userFilters, id: \.self) { user in
                    HStack {
                        Text(user)
                        Spacer()
                    }
                }
                .onDelete { indexSet in
                    userFilters.remove(atOffsets: indexSet)
                }
                
                Button(action: {
                    showingAddUserAlert = true
                }) {
                    Label("Add User", systemImage: "plus.circle.fill")
                        .foregroundStyle(Color.artemisAccent)
                }
            }
        }
        .navigationTitle("Content Filters")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !subredditFilters.isEmpty || !keywordFilters.isEmpty || !userFilters.isEmpty {
                    Button(action: {
                        showingClearConfirmation = true
                    }) {
                        Text("Clear All")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .alert("Add Subreddit Filter", isPresented: $showingAddSubredditAlert) {
            TextField("Subreddit name", text: $newSubreddit)
            Button("Cancel", role: .cancel) {
                newSubreddit = ""
            }
            Button("Add") {
                if !newSubreddit.isEmpty && !subredditFilters.contains(where: { $0.lowercased() == newSubreddit.lowercased() }) {
                    subredditFilters.append(newSubreddit.lowercased())
                    newSubreddit = ""
                }
            }
        }
        .alert("Add Keyword Filter", isPresented: $showingAddKeywordAlert) {
            TextField("Keyword", text: $newKeyword)
            Button("Cancel", role: .cancel) {
                newKeyword = ""
            }
            Button("Add") {
                if !newKeyword.isEmpty && !keywordFilters.contains(where: { $0.lowercased() == newKeyword.lowercased() }) {
                    keywordFilters.append(newKeyword.lowercased())
                    newKeyword = ""
                }
            }
        }
        .alert("Add User Filter", isPresented: $showingAddUserAlert) {
            TextField("Username", text: $newUser)
            Button("Cancel", role: .cancel) {
                newUser = ""
            }
            Button("Add") {
                if !newUser.isEmpty && !userFilters.contains(where: { $0.lowercased() == newUser.lowercased() }) {
                    userFilters.append(newUser.lowercased())
                    newUser = ""
                }
            }
        }
        .alert("Clear All Filters", isPresented: $showingClearConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Clear All", role: .destructive) {
                subredditFilters.removeAll()
                keywordFilters.removeAll()
                userFilters.removeAll()
            }
        } message: {
            Text("Are you sure you want to clear all filters? This action cannot be undone.")
        }
    }
}
