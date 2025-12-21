//
//  AplicacionesRecientesDTO.swift
//  CattleFyApp
//
//  Created by Victor Narazas on 20/12/25.
//

import Foundation

struct DetalleAplicacion : Codable {
    let nombreProducto: String
    let protocoloTipo: String
    let loteId: Int?
    let animalId: Int?
    let costoPorDosis: Double
    let fechaAplicacion: String
    
    
    enum CodingKeys: String, CodingKey{
        case nombreProducto = "nombre_producto"
        case protocoloTipo = "protocolo_tipo"
        case loteId = "lote_id"
        case animalId = "animal_id"
        case costoPorDosis = "costo_por_dosis"
        case fechaAplicacion = "fecha_aplicacion"
    }
    
}

struct AplicacionesFiltros{
    var loteId: Int?
    var protocoloTipo: String?
    var fechaInicio: String?
    var fechaFin: String?
}
