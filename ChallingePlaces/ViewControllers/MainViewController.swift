//
//  MainViewController.swift
//  ChallingePlaces
//
//  Created by Maxim Spiridonov on 08/05/2019.
//  Copyright © 2019 Maxim Spiridonov. All rights reserved.
//

import UIKit
import RealmSwift


class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var places: Results<Place>!
    private var filteredPlaces: Results<Place>!
    private var ascendingSorting = true
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    
    @IBOutlet var tableView: UITableView!
    
    let editButton: UIButton = {
        let button = UIButton.getCustomtButton(imageName: "plus")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        button.backgroundColor = UIColor(hexValue: "#43B05C", alpha: 1)
        
        return button
    }()
    
    @objc func editTapped(_ sender: UIButton) {
        sender.flash()
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewChallingeViewController") as? NewChallingeViewController {
            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    let infoButton: UIButton = {
        let button = UIButton.getCustomtButton(imageName: "info")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        button.backgroundColor = UIColor(hexValue: "#18BDF6", alpha: 1)
        return button
    }()
    
    @objc func infoButtonTapped(_ sender: UIButton) {
        sender.flash()
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InfoViewController") as? InfoViewController {
            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        places = realm.objects(Place.self)
        tableView.tableFooterView = UIView()
        
        
//        setup search controller
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        
       //        setup editButton controller
        
        view.addSubview(editButton)
        editButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        editButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        editButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        editButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        view.addSubview(infoButton)
        infoButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        infoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        infoButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        infoButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        
    }

    // MARK: - Table view data source

  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering {
            return filteredPlaces.count
        }
        return places.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChallingeTableViewCell
        let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        cell.cosmosView.rating = place.rating

        return cell
    }
    
    
    // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let place = places[indexPath.row]
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (_, _) in
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        return [deleteAction]
    }
    
//    убираем выделение с ячейки
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
  
    
    // MARK: - Navigation

 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
            let newPlaceVC = segue.destination as! NewChallingeViewController
            newPlaceVC.currentPlace = place
        }
    }
 
    

    @IBAction func unwindSegue(_ segue: UIStoryboardSegue){
        guard let newPlaceVC = segue.source as? NewChallingeViewController else { return }
        newPlaceVC.savePlace()
        tableView.reloadData()
    }
}



extension MainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        
        tableView.reloadData()
    }
}

