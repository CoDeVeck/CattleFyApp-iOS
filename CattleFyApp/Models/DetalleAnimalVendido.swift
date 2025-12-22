//
//  DetalleAnimalVendido.swift
//  CattleFyApp
//
//  Created by Victor Narazas on 21/12/25.
//


struct DetalleAnimalVendido: Codable {
    let animalId: Int
    let numeroIdentificacion: String
    let pesoActual: Double
    let edad: Int?
    let sexo: String?

    enum CodingKeys: String, CodingKey {
           case animalId = "idAnimal"
            case numeroIdentificacion = "numeroIdentificacion"
            case pesoActual = "pesoActual"
            case edad = "edad"
            case sexo = "sexo"
       }
}
