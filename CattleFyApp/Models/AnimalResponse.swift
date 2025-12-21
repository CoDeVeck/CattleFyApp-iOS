//
//  AnimalResponse.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/20/25.
//

import Foundation

struct AnimalResponse: Codable {
    let idAnimal: Int?
    let codigoQr: String?
    let idEspecie: Int?
    let especie: String?
    let idLote: Int?
    let lote: String?
    let idMadre: Int?
    let codigoQrMadre: String?
    let origen: String?
    let fechaIngreso: String?
    let fechaNacimiento: String?
    let edadEnDias: Int?
    let sexo: String?
    let peso: Double?
    let precioCompra: Double?
    let estado: String?
    let fotoUrl: String?
    let mensaje: String?
}

