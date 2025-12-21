//
//  AnimalRequest.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/20/25.
//

import Foundation

struct AnimalRequest: Codable {
    let origen: String
    let idLote: Int
    let codigoQrMadre: String?
    let idEspecie: Int
    let fechaNacimiento: String
    let sexo: String
    let peso: Double?
    let precioCompra: Double?
}
