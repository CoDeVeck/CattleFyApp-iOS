//
//  ReporteProduccionEngordeDTO.swift
//  CattleFyApp
//
//  Created by Victor Narazas on 20/12/25.
//

import Foundation

struct ReporteProduccionEngordeDTO: Codable {
    let pesoPromedio: Double
    let gananciaKg: Double
   
        
    
    enum CodingKeys: String, CodingKey{
        case pesoPromedio = "peso_promedio"
        case gananciaKg = "ganancia_kg"
    }
}

