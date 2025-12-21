//
//  LoteDetalleResponse.swift
//  CattleFyApp
//
//  Created by Andy Yahir Valdivia Centeno on 21/12/25.
//

struct LoteDetalleResponse: Codable {
    let loteId: Int
    let nombre: String?
    let codigo: String?
    let numeroLote: String?
    let estado: String?
    let tipoLote: String?
    
    let granjaNombre: String?
    let granjaId: Int?
    let especieNombre: String?
    let especieId: Int?
    
    let cantidadInicial: Int?
    let cantidadActual: Int?
    let fechaInicio: String?
    
    let pesoPromedio: Double?
    let pesoTotal: Double?
    let precioEstimado: Double?
    
    let cantidadRegistrosBajas: Int?
}
