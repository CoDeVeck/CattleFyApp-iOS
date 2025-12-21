//
//  AnimalHistTraslado.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/20/25.
//

import Foundation

struct AnimalHistTraslado: Codable {
    let idAnimal: Int
    let especie: String
    let loteOrigen: String
    let loteTraslado: String
    let motivo: String
}
