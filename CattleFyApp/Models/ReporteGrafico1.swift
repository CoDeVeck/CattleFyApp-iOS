//
//  ReporteGrafico1.swift
//  CattleFyApp
//
//  Created by Victor Narazas on 20/12/25.
//

import Foundation

struct ReporteGrafico1: Codable, Identifiable {
    let id = UUID()
    let fecha: String
    let pesoKg: Double
    
    
    enum CodingKeys: String, CodingKey{
        case fecha = "fecha"
        case pesoKg = "peso_kg"
    }
    
}
