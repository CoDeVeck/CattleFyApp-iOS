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
    let precioCompra: String? // Nota: viene como String "180.00"
    let estado: String?
    let fotoUrl: String?
    let mensaje: String?
    
    // AGREGAR ESTE ENUM PARA MAPEAR SNAKE_CASE A CAMELCASE
    enum CodingKeys: String, CodingKey {
        case idAnimal
        case codigoQr
        case idEspecie
        case especie
        case idLote
        case lote
        case idMadre
        case codigoQrMadre
        case origen
        case fechaIngreso
        case fechaNacimiento
        case edadEnDias
        case sexo
        case peso
        case precioCompra
        case estado
        case fotoUrl = "foto_url"  // ← Mapea foto_url a fotoUrl
        case mensaje
    }
}
