//
//  MovieResultsView.swift
//  movies
//
//  Created by Dan and Beth Engel on 9/6/23.
//

import SwiftUI

struct MovieResultsView: View {
    @ObservedObject var viewModel: MoviesViewModel
    var body: some View {
        VStack {
            if viewModel.loading {
                
            } else if let movies = viewModel.movies {
                ForEach(movies, id: \.self) { movie in
                    MovieView(movie: movie)
                }
            }
        }
            .navigationTitle("Movie Results")
            .task {
                do {
                    try await viewModel.getMovies()
                } catch {
                    print("error")
                }
            }
    }
}

struct MovieView: View {
    let movie: Movie
    
    var body: some View {
        VStack {
            Text(movie.title)
            
        }
    }
}

struct MovieResultsView_Previews: PreviewProvider {
    static var previews: some View {
        MovieResultsView(viewModel: MoviesViewModel(movies: nil))
    }
}
