//
//  DatosVentaCompletos .swift
//  CattleFyApp
//
//  Created by Victor Narazas on 21/12/25.
//

import Foundation

struct DatosVentaCompletos {
    
    let loteData: LoteDisponibleVentaResponse
    
    
    var precioPorKg: Decimal
    var precioTotal: Decimal
    var roiObjetivo: Decimal
    
    
    var clienteNombre: String
    var fechaVenta: Date
    
    
    let tipoAlcanceVenta: String
    let cantidadAnimales: Int?
    
    init(loteData: LoteDisponibleVentaResponse) {
        self.loteData = loteData
        self.precioPorKg = 0
        self.precioTotal = 0
        self.roiObjetivo = 0
        self.clienteNombre = ""
        self.fechaVenta = Date()
        self.tipoAlcanceVenta = "Total"
        self.cantidadAnimales = nil
    }
}
