//
//  LoteDisponibleVentaResponse.swift
//  CattleFyApp
//
//  Created by Victor Narazas on 21/12/25.
//

import Foundation

struct LoteDisponibleVentaResponse: Codable {
  let loteId: Int
  let loteNombre: String
  let especieNombre: String
  let categoriaManejoNombre: String
  let tipoLote: String
    let cantidadAnimalesVivos: Int
    let pesoPromedioLote: Double
    let sumaTotalPesos: Double
    let costoTotalAcumulado: Decimal
    let precioSugeridoPorKgBase: Decimal
    let roiEstimadoPorcentaje: Decimal
    
    
  enum CodingKeys: String, CodingKey {
    case loteId = "loteId"
    case loteNombre = "loteNombre"
    case especieNombre = "especieNombre"
    case categoriaManejoNombre = "categoriaManejoNombre"
    case tipoLote = "tipoLote"
    case cantidadAnimalesVivos = "cantidadAnimalesVivos"
    case pesoPromedioLote = "pesoPromedioLote"
    case sumaTotalPesos = "sumaTotalPesos"
    case costoTotalAcumulado = "costoTotalAcumulado"
    case precioSugeridoPorKgBase = "precioSugeridoPorKgBase"
    case roiEstimadoPorcentaje = "roiEstimadoPorcentaje"
  }
}
