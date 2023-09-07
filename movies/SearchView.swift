//
//  Search.swift
//  movies
//
//  Created by Dan Engel on 9/6/23.
//

import SwiftUI

struct SearchView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: MoviesViewModel
    @State var movieInput: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Enter a movie", text: $viewModel.movieInput)
                    .frame(height: 32)
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 8).stroke(.black, lineWidth: 0.5))
                    .fontWeight(.bold)
                    .font(.title3)
                NavigationLink(destination: MovieResultsView(viewModel: viewModel), label: {
                    Text("Submit")
                        .font(.title)
                        .frame(height: 50)
                        .frame(maxWidth: 400)
                        .foregroundColor(.white)
                        .background(.blue)
                        .cornerRadius(.infinity)
                        .padding(.top, 32)
                    }
                )
                .disabled(viewModel.movieInput.count == 0)
            }
            .navigationTitle("Movie Search")
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("Oops there was an issue") , message: Text("it looks like you didn't enter anything"))
            }
            .padding()
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(viewModel: MoviesViewModel(movies: nil))
    }
}
