import SwiftUI
import CoreLocation

// Extension to dismiss keyboard when tapping outside
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var posts: [PostModel] = []
    @State private var dummyLocations: [UUID: String] = [:]
    @State private var showComposeModal = false
    @State private var editingPost: PostModel? = nil
    @State private var showFilterModal = false
    @State private var filterCategory: String = "All"
    @State private var filterTag: String = ""

    private let userId = "current_user_id"
    private let suburbs = [
        ("Sydney CBD", "2000"),
        ("Bondi", "2026"),
        ("Manly", "2095"),
        ("Parramatta", "2150"),
        ("Newtown", "2042")
    ]
    private let categories = ["Daily Life", "Second-hand Trading", "Study", "Entertainment & Games", "Work & Career"]
    private let availableTags = ["Deals", "Wanted", "Notes", "Share", "Job Search"]

    private var filteredPosts: [PostModel] {
        posts.filter { post in
            (filterCategory == "All" || post.category == filterCategory) &&
            (filterTag.isEmpty || post.tags.contains(filterTag))
        }
    }

    var body: some View {
        NavigationStack {
            List(filteredPosts) { post in
                NavigationLink(destination: PostDetailView(post: post)) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(post.content)
                            .font(.body)
                        Text(dummyLocations[post.id] ?? post.locationName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack(spacing: 6) {
                            Text(post.category)
                                .font(.caption2)
                                .padding(4)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(4)
                            ForEach(post.tags, id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                        }
                        HStack {
                            Text("By: \(post.userId)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(post.createdAt, style: .time)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .swipeActions(edge: .leading) {
                    if post.userId == userId {
                        Button("Edit") {
                            editingPost = post
                            showComposeModal = true
                        }
                        .tint(.blue)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Nearby Posts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showComposeModal = true } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button { showFilterModal = true } label: {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
            .onAppear(perform: loadSavedOrDummy)
            .sheet(isPresented: $showComposeModal) {
                ComposePostView(
                    isPresented: Binding(get: { showComposeModal }, set: { new in
                        showComposeModal = new
                        if !new { editingPost = nil }
                    }),
                    categories: ["All"] + categories,
                    availableTags: availableTags,
                    initialContent: editingPost?.content,
                    initialCategory: editingPost?.category,
                    initialTags: editingPost?.tags
                ) { content, category, tags in
                    if let edit = editingPost,
                       let idx = posts.firstIndex(where: { $0.id == edit.id }) {
                        posts[idx].content = content
                        posts[idx].category = category
                        posts[idx].tags = tags
                    } else {
                        createPost(with: content, category: category, tags: tags)
                    }
                    PostStorageManager.shared.savePosts(posts)
                }
            }
            .sheet(isPresented: $showFilterModal) {
                FilterView(
                    isPresented: $showFilterModal,
                    categories: ["All"] + categories,
                    tags: [""] + availableTags,
                    selectedCategory: $filterCategory,
                    selectedTag: $filterTag
                )
            }
        }
    }

    private func loadSavedOrDummy() {
        let loaded = PostStorageManager.shared.loadPosts()
        posts = loaded.isEmpty ? generateDummyPosts() : loaded
        if loaded.isEmpty {
            let dummyMapping = Dictionary(uniqueKeysWithValues: generateDummyPosts().map { ($0.id, $0.locationName) })
            dummyLocations = dummyMapping
            PostStorageManager.shared.savePosts(posts)
        }
    }

    private func createPost(with content: String, category: String, tags: [String]) {
        let coord = locationManager.lastLocation ?? CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093)
        let (suburb, code) = suburbs.randomElement()!
        let newPost = PostModel(
            userId: userId,
            content: content,
            latitude: coord.latitude,
            longitude: coord.longitude,
            locationName: "\(suburb) \(code)",
            category: category,
            tags: tags
        )
        posts.insert(newPost, at: 0)
    }

    private func generateDummyPosts() -> [PostModel] {
        var list: [PostModel] = []
        let users = ["Alice", "Bob", "Carol", "Dave", "Eve"]
        let texts = [
            "Exploring the park!", "Just grabbed a coffee ☕️",
            "Anyone up for a walk?", "Beautiful day outside.",
            "Checking in from downtown."
        ]
        let coord = locationManager.lastLocation ?? CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093)
        for i in 0..<users.count {
            let (suburb, code) = suburbs[i]
            let post = PostModel(
                userId: users[i],
                content: texts[i],
                latitude: coord.latitude,
                longitude: coord.longitude,
                locationName: "\(suburb) \(code)",
                category: categories[i % categories.count],
                tags: [availableTags[i % availableTags.count]]
            )
            list.append(post)
        }
        return list
    }
}
