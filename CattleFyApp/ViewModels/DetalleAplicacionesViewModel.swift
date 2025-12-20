//
//  DetalleAplicacionesViewModel.swift
//  CattleFyApp
//
//  Created by Victor Narazas on 20/12/25.
//

import Foundation

class DetalleAplicacionesViewModel {
    private var aplicaciones: [DetalleAplicacion] = []
    private var granjaId: Int
    var filtrosActuales = AplicacionesFiltros()
    
    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    var isLoading: ((Bool) -> Void)?
    
    var numberOfRows: Int {
        return aplicaciones.count
    }
    
    init(granjaId: Int) {
        self.granjaId = granjaId
    }
    
    
    func fetchAplicaciones(filtros: AplicacionesFiltros? = nil) {
        if let filtros = filtros {
            self.filtrosActuales = filtros
        }
        
        isLoading?(true)
        
        AplicacionesService.shared.fetchDetalleAplicaciones(
            granjaId: granjaId,
            filtros: filtrosActuales
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading?(false)
                
                switch result {
                case .success(let aplicaciones):
                    self?.aplicaciones = aplicaciones
                    self?.onDataUpdated?()
                case .failure(let error):
                    self?.onError?("Error al cargar datos: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    func aplicarFiltros(loteId: Int? = nil, protocoloTipo: String? = nil, fechaInicio: String? = nil, fechaFin: String? = nil) {
        let filtros = AplicacionesFiltros(
            loteId: loteId,
            protocoloTipo: protocoloTipo,
            fechaInicio: fechaInicio,
            fechaFin: fechaFin
        )
        fetchAplicaciones(filtros: filtros)
    }
    
    
    func limpiarFiltros() {
        filtrosActuales = AplicacionesFiltros()
        fetchAplicaciones()
    }
    
    func getAplicacion(at index: Int) -> DetalleAplicacion? {
        guard index < aplicaciones.count else { return nil }
        return aplicaciones[index]
    }
    
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
    
    
    func getColorProtocolo(at index: Int) -> UIColor {
        guard let aplicacion = getAplicacion(at: index) else { return .systemBlue }
        
        switch aplicacion.protocoloTipo.lowercased() {
        case "tratamiento":
            return .systemRed
        case "prevencion", "prevención":
            return .systemGreen
        case "vacunacion", "vacunación":
            return .systemBlue
        default:
            return .systemGray
        }
    }
}
