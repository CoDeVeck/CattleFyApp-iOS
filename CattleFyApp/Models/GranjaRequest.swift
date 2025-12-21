//
//  GranjaRequest.swift
//  CattleFyApp
//
//  Created by Fernando on 20/12/25.
//


struct GranjaRequest: Codable {
    let usuarioId: Int
    let nombre: String
    let direccion: String
    let latitud: Double
    let longitud: Double
}
