//
//  ContentView.swift
//  movies
//
//  Created by Dan Engel on 9/6/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        SearchView(viewModel: MoviesViewModel(movies: nil))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
