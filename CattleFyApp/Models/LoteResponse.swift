//
//  LoteResponse.swift
//  CattleFyApp
//
//  Created by Andy Yahir Valdivia Centeno on 16/12/25.
//

struct LoteResponse: Codable {
    let idLote: Int
    let codigoQr: String
    let nombre: String
    let idEspecie: Int
    let especie: String
    let idCategoria: Int
    let categoria: String
    let tipoLote: String
    let fechaCreacion: String
    let diasDesdeCreacion: Int
    let estado: String
    let capacidadMax: Int
    let animalesVivos: Int
    let cvt: Double?
    let pesoPromedio: Double?
}
