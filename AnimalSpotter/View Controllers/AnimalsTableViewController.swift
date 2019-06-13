//
//  AnimalsTableViewController.swift
//  AnimalSpotter
//
//  Created by Ben Gohlke on 4/16/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class AnimalsTableViewController: UITableViewController {
    
    private var animalNames: [String] = []
    var apiController = APIController()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // transition to login view if conditions require
        if self.apiController.bearer == nil {
            performSegue(withIdentifier: "LoginViewModalSegue", sender: self)
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return animalNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnimalCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = animalNames[indexPath.row]

        return cell
    }

    // MARK: - Actions
    @IBAction func getAnimals(_ sender: UIBarButtonItem) {
        // fetch all animals from API
        self.apiController.fetchAllAnimalNames { (result) in
            if let names = try? result.get() {       //becuase we used Result as closure parameter completion(.success(result))
                DispatchQueue.main.async {
                    self.animalNames = names
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowAnimalDetailSegue" {
            // inject dependencies
            guard let detailVC = segue.destination as? AnimalDetailViewController,
                let selectedRow = self.tableView.indexPathForSelectedRow else {return}
            detailVC.apiController = self.apiController
            detailVC.animalName = self.animalNames[selectedRow.row]
            
        } else if segue.identifier == "LoginViewModalSegue" {
            //inject dependencies
            if let loginVC = segue.destination as? LoginViewController {
                loginVC.apiController = self.apiController  //passig this to loginViewController
            }
        }
    }
}
