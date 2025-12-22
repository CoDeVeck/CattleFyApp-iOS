//
//  AnimalHistSanitario.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/20/25.
//

import Foundation

struct AnimalHistSanitario: Codable {
    let idAnimal: Int
    let nombreTrat: String
    let tipoProtocolo: String
    let fecha: String
    let dosis: Double
    let precio: Double
}
