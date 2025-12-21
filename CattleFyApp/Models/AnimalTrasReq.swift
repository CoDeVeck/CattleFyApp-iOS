//
//  AnimalTrasReq.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/20/25.
//

import Foundation

struct AnimalTrasReq: Codable {
    let idAnimal: Int
    let idLoteDestino: Int
    let motivo: String
}
