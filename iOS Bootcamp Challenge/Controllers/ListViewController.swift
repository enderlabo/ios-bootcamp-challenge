//
//  ListViewController.swift
//  iOS Bootcamp Challenge
//
//  Created by Jorge Benavides on 26/09/21.
//

import UIKit
import SVProgressHUD

class ListViewController: UICollectionViewController {

    private var pokemons: [Pokemon] = []
    private var resultPokemons: [Pokemon] = []
    var pokemonsData: [Pokemon] = []
    var selectedPokemon: Pokemon?
    
    

    // TODO: Use UserDefaults to pre-load the latest search at start

    private var latestSearch: String?

    lazy private var searchController: SearchBar = {
        let searchController = SearchBar("Search a pokemon", delegate: nil)
        searchController.text = latestSearch
        searchController.showsCancelButton = !searchController.isSearchBarEmpty
        return searchController
    }()

    private var isFirstLauch: Bool = true

    //MARK: - Loading indicator when the app first launches and has no pokemons.
    func loadSpinner() {
        let child = SpinnerViewController()

           // add the spinner view controller
           addChild(child)
           child.view.frame = view.frame
           view.addSubview(child.view)
           child.didMove(toParent: self)

           // wait two seconds to simulate some work happening
//        if(pokemons.count > 0){
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
               child.willMove(toParent: nil)
               child.view.removeFromSuperview()
               child.removeFromParent()
            
        }
    }
    private var shouldShowLoader: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setup()
        setupUI()
        
        loadSpinner()
           
    }

    // MARK: Setup

    private func setup() {
        title = "Pokédex"

        // Customize navigation bar.
        guard let navbar = self.navigationController?.navigationBar else { return }

        navbar.tintColor = .black
        navbar.titleTextAttributes = [.foregroundColor: UIColor.black]
        navbar.prefersLargeTitles = true

        // Set up the searchController parameters.
        navigationItem.searchController = searchController
        definesPresentationContext = true

        refresh()
    }

    private func setupUI() {

        // Set up the collection view.
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.indicatorStyle = .white

        // Set up the refresh control as part of the collection view when it's pulled to refresh.
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        collectionView.sendSubviewToBack(refreshControl)
    }

    // MARK: - UISearchViewController

    private func filterContentForSearchText(_ searchText: String) {
        // filter with a simple contains searched text
        resultPokemons = pokemons
            .filter {
                searchText.isEmpty || $0.name.lowercased().contains(searchText.lowercased())
            }
            .sorted {
                $0.id < $1.id
            }

        collectionView.reloadData()
    }

    // TODO: Implement the SearchBar

    // MARK: - UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return resultPokemons.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PokeCell.identifier, for: indexPath) as? PokeCell
        else { preconditionFailure("Failed to load collection view cell") }
        cell.pokemon = resultPokemons[indexPath.item]
        return cell
    }
    //MARK: - Show detail from selected Pokemon with issue
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedPokemon = pokemonsData[indexPath.item]
        performSegue(withIdentifier: "goDetailViewControllerSegue", sender: self)
    }
    
        
    // MARK: - Handle navigation to detail view controller
    func transitionToDetail() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "goDetailViewControllerSegue", sender: self)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let listVC = segue.destination as? DetailViewController {
            listVC.pokemon = selectedPokemon
//            listVC.selectedPokemon = selectedPokemon
        }
    }

    // MARK: - UI Hooks

    @objc func refresh() {
        shouldShowLoader = true
        
        let dispatch = DispatchGroup()

        //MARK: - Waiting until the task finishes and update UI

        PokeAPI.shared.get(url: "pokemon?limit=150", onCompletion: { (list: PokemonList?) in
            guard let list = list else { return }
            list.results.forEach { result in
                dispatch.enter()
                PokeAPI.shared.get(url: "/pokemon/\(result.id)/", onCompletion: { (pokemon: Pokemon?) in
                    guard let pokemon = pokemon else { return }
                    self.pokemonsData.append(pokemon)
                    dispatch.leave()
                })
            }
            dispatch.notify(queue: .main){
                self.pokemons = self.pokemonsData
                self.didRefresh()
            }
        })
    }

    private func didRefresh() {
        shouldShowLoader = false

        guard
            let collectionView = collectionView,
            let refreshControl = collectionView.refreshControl
        else { return }

        refreshControl.endRefreshing()

        filterContentForSearchText("")
    }

}
