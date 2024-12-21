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
    
    private func sanitizeSubreddit(_ input: String) -> String {
        var sanitized = input.trimmingCharacters(in: .whitespacesAndNewlines)
        if sanitized.hasPrefix("r/") {
            sanitized = String(sanitized.dropFirst(2))
        } else if sanitized.hasPrefix("/r/") {
            sanitized = String(sanitized.dropFirst(3))
        }
        return sanitized.lowercased()
    }
    
    private func sanitizeUsername(_ input: String) -> String {
        var sanitized = input.trimmingCharacters(in: .whitespacesAndNewlines)
        if sanitized.hasPrefix("u/") || sanitized.hasPrefix("/u/") {
            sanitized = String(sanitized.dropFirst(sanitized.hasPrefix("u/") ? 2 : 3))
        }
        return sanitized.lowercased()
    }
    
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
                let sanitized = sanitizeSubreddit(newSubreddit)
                if !sanitized.isEmpty && !subredditFilters.contains(where: { $0 == sanitized }) {
                    subredditFilters.append(sanitized)
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
                let sanitized = newKeyword.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                if !sanitized.isEmpty && !keywordFilters.contains(where: { $0 == sanitized }) {
                    keywordFilters.append(sanitized)
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
                let sanitized = sanitizeUsername(newUser)
                if !sanitized.isEmpty && !userFilters.contains(where: { $0 == sanitized }) {
                    userFilters.append(sanitized)
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
