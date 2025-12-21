//
//  SanidadEstadisticasDTO.swift
//  CattleFyApp
//
//  Created by Victor Narazas on 20/12/25.
//

import Foundation

struct SanidadEstadisticasDTO: Codable {
    
    let cantidadTotalDosis: Double
    let costoTotal: Double
    let animalesTratados: Int
    let medicamentoMasUsado: String
    
    
    enum CodingKeys: String, CodingKey{
        case cantidadTotalDosis = "cantidad_total_dosis"
        case costoTotal = "costo_total"
        case animalesTratados = "animales_tratados"
        case medicamentoMasUsado = "medicamente_mas_usado"
    }
    
}
