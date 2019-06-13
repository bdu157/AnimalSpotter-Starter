//
//  AnimalDetailViewController.swift
//  AnimalSpotter
//
//  Created by Ben Gohlke on 4/16/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class AnimalDetailViewController: UIViewController {
    
    var apiController: APIController?
    var animalName: String?
    
    @IBOutlet weak var timeSeenLabel: UILabel!
    @IBOutlet weak var coordinatesLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var animalImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // fetch animal details
        self.getDetails()
    }
    
    func getDetails() {
        // make network call to API for animal details
        guard let apiController = self.apiController,
            let animalName = self.animalName else {return}
        apiController.fetchDetailsForAnimal(for: animalName) { (result) in
            if let animal = try? result.get() {   //because we used Result as a parameter
                DispatchQueue.main.async {
                    self.updateViews(with: animal)
                }
                self.apiController?.fetchImage(at: animal.imageURL, completion: { (result) in
                    if let image = try? result.get() {
                        DispatchQueue.main.sync {
                            self.animalImageView.image = image
                        }
                    }
                })
            }
        }
    }
    
    func updateViews(with animal: Animal) {
        self.title = animal.name
        self.descriptionLabel.text = animal.description
        self.coordinatesLabel.text = "lat: \(animal.latitude), long:\(animal.longitude)"
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        self.timeSeenLabel.text = df.string(from: animal.timeSeen)
    }
}
