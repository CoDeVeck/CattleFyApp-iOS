//
//  RegistroAlimentacionRequestDTO.swift
//  CattleFyApp
//
//  Created by Andy Yahir Valdivia Centeno on 16/12/25.
//

struct RegistroAlimentacionRequestDTO: Codable {
    let loteId: Int
    let cantidadKg: Double
    let costoPorKg: Double
    let dietaTipo: String?
}
