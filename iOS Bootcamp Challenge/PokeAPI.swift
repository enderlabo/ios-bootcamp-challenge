//
//  PokeAPI.swift
//  iOS Bootcamp Challenge
//
//  Created by Jorge Benavides on 26/09/21.
//

import Foundation

enum PokemonApiResponse {
    case success(pokemon: [Pokemon])
    case failed
}

class PokeAPI {

    static let shared = PokeAPI()
    static var baseURL = "https://pokeapi.co/api/v2/"
    
    

    //MARK: - Generic method to fetch data.
        @discardableResult
        func get<T:Decodable>(url: String, onCompletion: @escaping (T) -> ()) -> URLSessionDataTask? {
               let path = url.replacingOccurrences(of: PokeAPI.baseURL, with: "")
               let task = URLSession.mock.dataTask(with: PokeAPI.baseURL + path, completionHandler: { data, _, error in
                   guard let data = data else {return}
                   do {
                       let entity = try JSONDecoder().decode(T.self, from: data)
                       onCompletion(entity)
                   } catch let JSONError {
                       print("Failed to decode json", JSONError)
                   }
               })
               task?.resume()
               return task
           }
    
}
