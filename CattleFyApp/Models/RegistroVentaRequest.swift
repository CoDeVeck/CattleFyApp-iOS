//
//  RegistroVentaRequest.swift
//  CattleFyApp
//
//  Created by Victor Narazas on 21/12/25.
//

import Foundation

struct RegistroVentaRequest: Codable {
    let loteId: Int
    let tipoAlcanceVenta: String
    let tipoVenta: String
    let cantidadAnimalesVender: Int?
    let animalesSeleccionados: [Int]?
    var pesoTotalKg: Decimal
    let precioPorKg: Decimal
    let precioTotal: Decimal
    let roiMeta: Decimal
    let clienteNombre: String
    let fechaVenta: String 
}
