//
//  Animal.swift
//  AnimalSpotter
//
//  Created by Dongwoo Pae on 6/12/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

struct Animal: Codable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let timeSeen: Date
    let description: String
    let imageURL: String
}
