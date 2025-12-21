//
//  GranjaResponse.swift
//  CattleFyApp
//
//  Created by Fernando on 21/12/25.
//

struct GranjaResponse: Codable {
    let granjaId: Int
    let usuarioId: Int
    let nombre: String
    let direccion: String
    let latitud: Double
    let longitud: Double
    let imagenUrl: String?
}

