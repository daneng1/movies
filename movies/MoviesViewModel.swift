//
//  MoviesViewModel.swift
//  movies
//
//  Created by Dan Engel on 9/6/23.
//

import Foundation

class MoviesViewModel: ObservableObject {
    @Published var showAlert: Bool = false
    @Published var isShowingMovie: Bool = false
    @Published var movieInput: String = ""
    @Published var movies: [Movie]?
    @Published var loading: Bool = false
    
    init(movies: [Movie]?) {
        self.movies = movies
    }
    
    func submitMovieRequest() {
        if movieInput.count < 1 {
            showAlert = true
            return
        } else {
            setIsShowingMovie()
        }
    }
    
    func setIsShowingMovie() {
        isShowingMovie = !isShowingMovie
    }
    
    func getMovies() async throws {
        loading = true
        let urlString = "https://movie-database-alternative.p.rapidapi.com/?s=\(movieInput)&r=json&page=1"
        
        guard let url = URL(string: urlString) else {
            throw MovieError.invalidURL
        }
        
        var request = URLRequest(url: url)
        if let moviesAPIKey = Secrets.moviesAPIKey {
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = [
                "X-RapidAPI-Key": moviesAPIKey,
                "X-RapidAPI-Host": "movie-database-alternative.p.rapidapi.com"
            ]
        }
        print(request)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse, response.statusCode > 199 && response.statusCode < 300 else {
            throw MovieError.invalidResponse
        }
        
        print(response)
        
        do {
            let decoder = JSONDecoder()
            let movies = try decoder.decode(MovieResponse.self, from: data)
            DispatchQueue.main.async { [weak self] in
                self?.movies = movies.search
                self?.loading = false
            }
        } catch {
            throw MovieError.invalidData
        }
    }
}

struct Movie: Codable, Hashable {
    let title: String
    let year: String
    let poster: String
    let type: String
    let imdbID: String
    
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case poster = "Poster"
        case type = "Type"
        case imdbID
    }
    
    static func == (lhs: Movie, rhs: Movie) -> Bool {
        return lhs.imdbID == rhs.imdbID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(imdbID)
    }
}

enum MovieError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}

struct MovieResponse: Codable {
    let search: [Movie]
    let totalResults: String
    let response: String
    
    enum CodingKeys:String, CodingKey {
        case totalResults
        case search = "Search"
        case response = "Response"
    }
}

struct Secrets {
    private static func secrets() -> [String: Any]? {
        let fileName = "Secrets"
        guard let path = Bundle.main.path(forResource: fileName, ofType: "json") else {
            print("Error: 'Secrets.json' not found")
            return nil
        }

        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                return jsonObject
            } else {
                print("Error: Couldn't deserialize 'Secrets.json' into a dictionary")
                return nil
            }
        } catch {
            print("Error: \(error)")
            return nil
        }
    }

    static var moviesAPIKey: String? {
        guard let secrets = secrets(), let moviesAPIKey = secrets["MOVIES_API_KEY"] as? String else {
            print("Error: 'MOVIES_API_KEY' not found in 'Secrets.json'")
            return nil
        }
        return moviesAPIKey
    }
}
