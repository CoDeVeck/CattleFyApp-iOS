//
//  GranjaSimpleDTO.swift
//  CattleFyApp
//
//  Created by Fernando on 21/12/25.
//

struct GranjaSimpleDTO: Codable, Identifiable {
    let id: Int
    let nombre: String
    let direccion: String?
}
