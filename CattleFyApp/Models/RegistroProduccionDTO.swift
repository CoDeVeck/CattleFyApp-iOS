//
//  RegistroProduccionDTO.swift
//  CattleFyApp
//
//  Created by Andy Yahir Valdivia Centeno on 20/12/25.
//

import Foundation

struct RegistroProduccionDTO: Codable {
    let produccionId: Int?
    let fechaRegistro: Date?
    let tipoProduccion: String?
    let cantidad: Decimal?
    let loteId: Int?
    let nombreLote: String?
}
