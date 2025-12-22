//
//  ReporteGrafico2.swift
//  CattleFyApp
//
//  Created by Victor Narazas on 20/12/25.
//

import Foundation

struct ReporteGrafico2: Codable, Identifiable {
  let id = UUID()
  let fecha: String
  let tipoProduccion: String
  let cantidadTotal: Double
  
  enum CodingKeys: String, CodingKey {
    case fecha
    case tipoProduccion = "tipo_produccion"
    case cantidadTotal = "cantidad_total"
  }
}
