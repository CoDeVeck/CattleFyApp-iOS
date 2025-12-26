//
//  RegistroSanitarioRequest.swift
//  CattleFyApp
//
//  Created by Andy Yahir Valdivia Centeno on 17/12/25.
//

import Foundation

struct RegistroSanitarioRequest: Codable {
    var qrLote: String?
    var idLote: Int?
    var qrAnimal: String?
    
    var tipoAplicacion: String?
    var protocoloTipo: String?
    var nombreProducto: String?
    
<<<<<<< HEAD
    var costoPorDosis: Decimal?
    var cantidadDosis: Decimal?
=======
    var costoPorDosis: Double?
    var cantidadDosis: Double?
>>>>>>> c5222b3 (Subindo ultimos cambios)
    
    var animalesTratados: Int?
}
