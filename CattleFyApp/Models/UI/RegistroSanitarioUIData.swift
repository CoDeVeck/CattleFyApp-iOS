//
//  RegistroSanitarioUIData.swift
//  CattleFyApp
//
//  Created by Andy Yahir Valdivia Centeno on 17/12/25.
//
import Foundation

struct RegistroSanitarioUIData {
    var idLote: Int?
    var qrLote: String?
    
    var tipoAplicacion: String?
    var protocoloTipo: String?
    var nombreProducto: String?
    
    var costoPorDosis: Decimal?
    var cantidadDosis: Decimal?
    
    var animalesTratados: Int?
    var fechaAplicacion: Date?
    
    var costoTotal: Decimal?
}
