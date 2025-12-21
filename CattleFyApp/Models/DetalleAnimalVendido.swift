//
//  DetalleAnimalVendido.swift
//  CattleFyApp
//
//  Created by Victor Narazas on 21/12/25.
//

import Foundation

struct DetalleAnimalVendido: Codable {
    let animalId: Int
    let numeroIdentificacion: String
    let pesoActual: Double
    let edad: Int?
    let sexo: String?
}
