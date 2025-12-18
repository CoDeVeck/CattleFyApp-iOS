//
//  RegistroSanitarioResponse.swift
//  CattleFyApp
//
//  Created by Andy Yahir Valdivia Centeno on 17/12/25.
//

import Foundation

struct RegistroSanitarioResponse: Codable {
    var sanitarioId: Int?
    
    var idLote: Int?
    var nombreLote: String?
    
    var idAnimal: Int?
    var codigoQrAnimal: String?
    
    var tipoAplicacion: String?
    var protocoloTipo: String?
    var nombreProducto: String?
    
    var costoTotal: Decimal?
    var costoPorDosis: Decimal?
    var cantidadDosis: Decimal?
    var animalesTratados: Int?
    

}
