//
//  ReporteProduccionViewModel.swift
//  CattleFyApp
//
//  Created by Victor Narazas on 20/12/25.
//

import Foundation
	

class ReporteProduccionViewModel {
  
  // MARK: - Properties
  private let granjaId: Int
  private let service = ReporteService.shared
  
  private var lotes: [LoteSimpleDTO] = []
  private var categorias: [CategoriaSimpleDTO] = []
  private var datosGrafico: [ReporteGrafico2] = []
  
  // MARK: - Callbacks
  var onLotesUpdated: (() -> Void)?
  var onCategoriasUpdated: (() -> Void)?
  var onReporteUpdated: ((ReporteProduccionReproduccion) -> Void)?
  var onGraficoUpdated: (([ReporteGrafico2]) -> Void)?
  var onError: ((String) -> Void)?
  var isLoading: ((Bool) -> Void)?
  
  // MARK: - Computed Properties
  var numberOfLotes: Int {
    return lotes.count
  }
  
  var numberOfCategorias: Int {
    return categorias.count
  }
  
  // MARK: - Inicializador
  init(granjaId: Int) {
    self.granjaId = granjaId
  }
  
  // MARK: - Fetch Lotes
  func fetchLotes() {
    isLoading?(true)
    
    service.fetchLotesPorGranja(granjaId: granjaId) { [weak self] result in
      DispatchQueue.main.async {
        self?.isLoading?(false)
        
        switch result {
        case .success(let lotes):
          self?.lotes = lotes
          self?.onLotesUpdated?()
          
        case .failure(let error):
          self?.onError?("Error al cargar lotes: \(error.localizedDescription)")
        }
      }
    }
  }
  
  // MARK: - Aplicar Filtros
  func aplicarFiltros(
    loteId: Int?,
    categoriaId: Int?,
    fechaInicio: Date,
    fechaFin: Date
  ) {
    let filtros = ReporteProduccionFiltros(
      loteId: loteId,
      categoriaId: categoriaId,
      fechaInicio: formatDate(fechaInicio),
      fechaFin: formatDate(fechaFin)
    )
    
    // Fetch datos del reporte (estadísticas de producción)
    fetchReporteProduccion(filtros: filtros)
    
    // Fetch datos del gráfico (producción por tipo)
    fetchGraficoProduccion(filtros: filtros)
  }
  
  // MARK: - Fetch Reporte Producción
  private func fetchReporteProduccion(filtros: ReporteProduccionFiltros) {
    isLoading?(true)
    
    service.fetchReporteProduccion(granjaId: granjaId, filtros: filtros) { [weak self] result in
      DispatchQueue.main.async {
        self?.isLoading?(false)
        
        switch result {
        case .success(let reportes):
          if let primerReporte = reportes.first {
            self?.onReporteUpdated?(primerReporte)
          } else {
            self?.onError?("No hay datos disponibles para este periodo")
          }
          
        case .failure(let error):
          self?.onError?("Error al cargar reporte: \(error.localizedDescription)")
        }
      }
    }
  }
  
  // MARK: - Fetch Gráfico Producción
  private func fetchGraficoProduccion(filtros: ReporteProduccionFiltros) {
    isLoading?(true)
    
    service.fetchGraficoProduccion(granjaId: granjaId, filtros: filtros) { [weak self] result in
      DispatchQueue.main.async {
        self?.isLoading?(false)
        
        switch result {
        case .success(let datos):
          self?.datosGrafico = datos
          self?.onGraficoUpdated?(datos)
          
        case .failure(let error):
          self?.onError?("Error al cargar gráfico: \(error.localizedDescription)")
        }
      }
    }
  }
  
  // MARK: - Helpers para Lotes
  func getLoteNombre(at index: Int) -> String {
    guard index >= 0 && index < lotes.count else { return "Todos" }
    return lotes[index].nombre
  }
  
  func getLoteId(at index: Int) -> Int? {
    guard index >= 0 && index < lotes.count else { return nil }
    return lotes[index].loteId
  }
  
  // MARK: - Helpers para Categorías
  func getCategoriaNombre(at index: Int) -> String {
    guard index >= 0 && index < categorias.count else { return "Todas" }
    return categorias[index].nombre
  }
  
  func getCategoriaId(at index: Int) -> Int? {
    guard index >= 0 && index < categorias.count else { return nil }
    return categorias[index].categoriaId
  }
  
  // MARK: - Helper Date Formatter
  private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
  }
}
