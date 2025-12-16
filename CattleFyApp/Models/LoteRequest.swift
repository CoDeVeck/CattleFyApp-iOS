//
//  LoteRequest.swift
//  CattleFyApp
//
//  Created by Andy Yahir Valdivia Centeno on 16/12/25.
//
struct LoteRequest: Codable {
    let idGranja: Int
    let nombre: String
    let idEspecie: Int
    let idCategoria: Int
    let diasDesdeCreacion: Int
    let capacidadMax: Int
}
