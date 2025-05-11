//
//  NetworkManager.swift
//  NoteApp
//
//  Created by yuchen on 11/5/2025.
//

// NetworkManager.swift
import Foundation

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}

    private let baseURL = URL(string: "https://api.example.com")!  // 替换为你的后端地址

    func sendPost(_ post: PostModel, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = baseURL.appendingPathComponent("/posts")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            req.httpBody = try JSONEncoder().encode(post)
        } catch {
            return completion(.failure(error))
        }

        URLSession.shared.dataTask(with: req) { _, resp, err in
            if let e = err { return completion(.failure(e)) }
            completion(.success(()))
        }.resume()
    }

    func fetchPosts(
        for userId: String,
        near coordinate: (lat: Double, lng: Double),
        radiusKm: Double = 5,
        completion: @escaping (Result<[PostModel], Error>) -> Void
    ) {
        var components = URLComponents(url: baseURL.appendingPathComponent("/posts"), resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "userId", value: userId),
            URLQueryItem(name: "lat", value: String(coordinate.lat)),
            URLQueryItem(name: "lng", value: String(coordinate.lng)),
            URLQueryItem(name: "radius", value: String(radiusKm))
        ]
        let req = URLRequest(url: components.url!)

        URLSession.shared.dataTask(with: req) { data, _, err in
            if let e = err { return completion(.failure(e)) }
            guard let d = data else {
                return completion(.success([]))
            }
            do {
                let posts = try JSONDecoder().decode([PostModel].self, from: d)
                completion(.success(posts))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
