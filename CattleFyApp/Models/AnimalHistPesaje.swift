//
//  AnimalHistPesaje.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/20/25.
//

import Foundation

struct AnimalHistPesaje: Codable {
    let idAnimal: Int
    let peso: Double
    let fecha: String
    let dieta: String?
    let gananciaPeso: Double?
}
