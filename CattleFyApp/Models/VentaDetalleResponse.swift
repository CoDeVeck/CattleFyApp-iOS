//
//  VentaDetalleResponse.swift
//  CattleFyApp
//
//  Created by Victor Narazas on 21/12/25.
//

import Foundation

struct VentaDetalleResponse: Codable {
    let ventaId: Int
    let loteId: Int
    let loteNombre: String
    let especieNombre: String
    let categoriaManejoNombre: String
    let tipoAlcanceVenta: String
    let tipoVenta: String
    let pesoTotalKg: Decimal
    let precioPorKg: Decimal
    let precioTotal: Decimal
    let roiReal: Decimal
    let roiObjetivo: Decimal
    let diferenciaRoi: Decimal
    let clienteNombre: String
    let fechaVenta: String
    let cantidadAnimalesVendidos: Int
    let animalesVendidos: [DetalleAnimalVendido]
    let costoTotalInvertido: Decimal
    let gananciaNeta: Decimal
    let advertencia: String?
    let recomendacion: String?
}
