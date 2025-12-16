//
//  EspecieResponse.swift
//  CattleFyApp
//
//  Created by Andy Yahir Valdivia Centeno on 16/12/25.
//
struct EspecieResponse: Codable, Identifiable {
    let especieId: Int
    let nombre: String

    var id: Int { especieId }
}
