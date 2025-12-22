//
//  ReporteProduccionReproduccion.swift
//  CattleFyApp
//
//  Created by Victor Narazas on 20/12/25.
//

import Foundation

struct ReporteProduccionReproduccion: Codable {
  let totalDeLecha: Double
  let totalDeHuevos: Double
  let promedioLechesPorDia: Double
  let promedioHuevosPorDia: Double
  let totalNacimientos: Int
  
  enum CodingKeys: String, CodingKey {
    case totalDeLecha = "total_de_lecha"
    case totalDeHuevos = "total_de_huevos"
    case promedioLechesPorDia = "promedio_leches_por_dia"
    case promedioHuevosPorDia = "promedio_huevos_por_dia"
    case totalNacimientos = "total_nacimientos"
  }
}
