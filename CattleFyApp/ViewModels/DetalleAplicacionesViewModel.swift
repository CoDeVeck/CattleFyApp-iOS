//
//  DetalleAplicacionesViewModel.swift
//  CattleFyApp
//
//  Created by Victor Narazas on 20/12/25.
//

import Foundation
import UIKit

class DetalleAplicacionesViewModel {
    
    // MARK: - Properties
       private var granjaId: Int
       private var lotes: [LoteSimpleDTO] = []
       private var aplicaciones: [DetalleAplicacion] = []
       private var estadisticas: SanidadEstadisticasDTO?
       
       var filtrosActuales = AplicacionesFiltros()
       
       // MARK: - Callbacks
       var onLotesUpdated: (() -> Void)?
       var onAplicacionesUpdated: (() -> Void)?
       var onError: ((String) -> Void)?
       var isLoading: ((Bool) -> Void)?
       var onEstadisticasActualizadas: ((SanidadEstadisticasDTO) -> Void)?
       
       init(granjaId: Int) {
           self.granjaId = granjaId
           print("✅ ViewModel inicializado con granjaId: \(granjaId)")
       }
       
       // MARK: - Lotes
       var numberOfLotes: Int {
           print("✅ ViewModel inicializado con granjaId: \(granjaId)")
           return lotes.count + 1
       }
       
       func getLoteNombre(at index: Int) -> String {
           if index == 0 {
               return "Todos los lotes"
           }
           guard index - 1 < lotes.count else { return "" }
           return lotes[index - 1].nombre
       }
       
       func getLoteId(at index: Int) -> Int? {
           if index == 0 {
               return nil
           }
           guard index - 1 < lotes.count else { return nil }
           return lotes[index - 1].loteId
       }
       
       func fetchLotes() {
           isLoading?(true)
           
           ReporteService.shared.fetchLotesPorGranja(granjaId: granjaId) { [weak self] result in
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
       
       // MARK: - Estadísticas
       func fetchEstadisticas() {
           isLoading?(true)
           
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "yyyy-MM-dd"
           
           let fechaInicio = filtrosActuales.fechaInicio
           let fechaFin = filtrosActuales.fechaFin
           
           ReporteService.shared.fetchEstadisticasSanidad(
               granjaId: granjaId,
               loteId: filtrosActuales.loteId,
               fechaInicio: fechaInicio,
               fechaFin: fechaFin
           ) { [weak self] result in
               DispatchQueue.main.async {
                   self?.isLoading?(false)
                   
                   switch result {
                   case .success(let estadisticas):
                       self?.estadisticas = estadisticas
                       self?.onEstadisticasActualizadas?(estadisticas)
                   case .failure(let error):
                       self?.onError?("Error al cargar estadísticas: \(error.localizedDescription)")
                   }
               }
           }
       }
       
       // MARK: - Aplicaciones
       var numberOfAplicaciones: Int {
           return aplicaciones.count
       }
       
       func getAplicacion(at index: Int) -> DetalleAplicacion? {
           guard index < aplicaciones.count else { return nil }
           return aplicaciones[index]
       }
       
       func fetchAplicaciones() {
           isLoading?(true)
           
           ReporteService.shared.fetchDetalleAplicaciones(
               granjaId: granjaId,
               filtros: filtrosActuales
           ) { [weak self] result in
               DispatchQueue.main.async {
                   self?.isLoading?(false)
                   
                   switch result {
                   case .success(let aplicaciones):
                       self?.aplicaciones = aplicaciones
                       self?.onAplicacionesUpdated?()
                   case .failure(let error):
                       self?.onError?("Error al cargar aplicaciones: \(error.localizedDescription)")
                   }
               }
           }
       }
       
       // MARK: - Cargar todo
       func cargarTodosLosDatos() {
           
           fetchEstadisticas()
           fetchAplicaciones()
       }
       
       // MARK: - Filtros
       func aplicarFiltros(
           loteId: Int? = nil,
           protocoloTipo: String? = nil,
           fechaInicio: Date? = nil,
           fechaFin: Date? = nil
       ) {
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "yyyy-MM-dd"
           
           filtrosActuales = AplicacionesFiltros(
               loteId: loteId,
               protocoloTipo: protocoloTipo,
               fechaInicio: fechaInicio != nil ? dateFormatter.string(from: fechaInicio!) : nil,
               fechaFin: fechaFin != nil ? dateFormatter.string(from: fechaFin!) : nil
           )
           
           cargarTodosLosDatos() 
       }
       
       func limpiarFiltros() {
           filtrosActuales = AplicacionesFiltros()
           cargarTodosLosDatos()
       }
       
       // MARK: - Métodos auxiliares para la tabla
       func getLoteAnimalText(at index: Int) -> String {
           guard let aplicacion = getAplicacion(at: index) else { return "" }
           
           if let animalId = aplicacion.animalId {
               return "Lote \(aplicacion.loteId) - Animal #\(animalId)"
           } else {
               return "Lote \(aplicacion.loteId) - Todo el lote"
           }
       }
       
       func getCostoText(at index: Int) -> String {
           guard let aplicacion = getAplicacion(at: index) else { return "" }
           return String(format: "S/ %.2f", aplicacion.costoPorDosis)
       }
       
       func getFechaFormateada(at index: Int) -> String {
           guard let aplicacion = getAplicacion(at: index) else { return "" }
           
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "yyyy-MM-dd"
           
           if let date = dateFormatter.date(from: aplicacion.fechaAplicacion) {
               dateFormatter.dateFormat = "dd/MM/yyyy"
               return dateFormatter.string(from: date)
           }
           
           return aplicacion.fechaAplicacion
       }
       
       func getImagenProducto(at index: Int) -> String {
           guard let aplicacion = getAplicacion(at: index) else { return "syringe" }
           
           let nombreLower = aplicacion.nombreProducto.lowercased()
           
           if nombreLower.contains("antiinflamatorio") {
               return "cross.case.fill"
           } else if nombreLower.contains("antibiotico") || nombreLower.contains("antibiótico") {
               return "pills.fill"
           } else if nombreLower.contains("suplemento") {
               return "leaf.fill"
           } else if nombreLower.contains("desparasitante") {
               return "circle.hexagongrid.fill"
           } else if nombreLower.contains("vacuna") {
               return "cross.vial.fill"
           } else {
               return "syringe.fill"
           }
       }
}
