//
//  AuthResponseDTO.swift
//  CattleFyApp
//
//  Created by Andy Yahir Valdivia Centeno on 16/12/25.
//
struct AuthResponseDTO: Codable {
    let usuarioId: Int
    let firebaseUid: String
    let email: String
    let nombres: String
    let apellidos: String
    let token: String
    let rol: String
}
