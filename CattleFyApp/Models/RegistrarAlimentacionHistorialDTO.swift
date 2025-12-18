//
//  RegistrarAlimentacionHistorialDTO.swift
//  CattleFyApp
//
//  Created by Andy Yahir Valdivia Centeno on 17/12/25.
//

import Foundation

struct RegistrarAlimentacionHistorialDTO: Codable {
    var alimentacionId: Int?
    var fecha: String?
    var dieta: String?
    var cantidadKg: Decimal?
    var costoTotal: Decimal?
    var loteId: Int?
    var nombreLote: String?
}
