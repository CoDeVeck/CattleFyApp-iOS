//
//  ReporteFiltros.swift
//  CattleFyApp
//
//  Created by Victor Narazas on 20/12/25.
//

import Foundation

struct ReporteProduccionFiltros {
  var loteId: Int?
  var categoriaId: Int?
  var fechaInicio: String?
  var fechaFin: String?
  
  init(loteId: Int? = nil, categoriaId: Int? = nil, fechaInicio: String? = nil, fechaFin: String? = nil) {
    self.loteId = loteId
    self.categoriaId = categoriaId
    self.fechaInicio = fechaInicio
    self.fechaFin = fechaFin
  }
}
