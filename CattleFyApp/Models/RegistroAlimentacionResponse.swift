//
//  RegistroAlimentacionResponse.swift
//  CattleFyApp
//
//  Created by Andy Yahir Valdivia Centeno on 16/12/25.
//

struct RegistroAlimentacionResponse: Codable {
    let alimentacionId: Int
    let loteId: Int
    let fechaRegistro: String
    let cantidadKg: Double
    let costoPorKg: Double
    let dietaTipo: String?
    let costoTotal: String
}
