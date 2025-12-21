//
//  VentaViewModel.swift
//  CattleFyApp
//
//  Created by Victor Narazas on 21/12/25.
//


import Foundation

class VentaViewModel{
    
    // MARK: - Propiedades
    private var todosLosLotes: [LoteDisponibleVentaResponse] = []
    var lotesFiltrados: [LoteDisponibleVentaResponse] = []
    var tipoFiltroActual: TipoLote? = nil
    
    var onLotesActualizados: (() -> Void)?
    var onError: ((String) -> Void)?
    var onCargando: ((Bool) -> Void)?
    
    enum TipoLote: String {
        case engorde = "Engorde"
        case descarte = "Descarte"
        case reproduccion = "Reproduccion"
    }
    
    func cargarLotesDisponibles(granjaId: Int) {
        onCargando?(true)
        
        let filtroInicial = tipoFiltroActual?.rawValue
        
        VentaService.shared.obtenerLotesDisponibles(granjaId: granjaId, tipoLote: filtroInicial) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.onCargando?(false)
                
                switch result {
                case .success(let lotes):
                    self.todosLosLotes = lotes
                    self.aplicarFiltroActual()
                    print("ViewModel: Cargados \(lotes.count) lotes")
                    
                case .failure(let error):
                    self.onError?("Error al cargar lotes: \(error.localizedDescription)")
                    print("ViewModel: Error - \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Aplicar Filtros
    func aplicarFiltro(_ tipo: TipoLote?) {
        if tipoFiltroActual == tipo {
            tipoFiltroActual = nil
        } else {
            tipoFiltroActual = tipo
        }
        
        aplicarFiltroActual()
    }
    
    private func aplicarFiltroActual() {
        if let filtro = tipoFiltroActual {
            lotesFiltrados = todosLosLotes.filter { $0.tipoLote == filtro.rawValue }
            print("Filtro aplicado: \(filtro.rawValue) - Resultados: \(lotesFiltrados.count)")
        } else {
            lotesFiltrados = todosLosLotes
            print("Sin filtro - Mostrando todos: \(lotesFiltrados.count)")
        }
        
        onLotesActualizados?()
    }
    
    
    func obtenerLote(en index: Int) -> LoteDisponibleVentaResponse? {
        guard index >= 0 && index < lotesFiltrados.count else {
            return nil
        }
        return lotesFiltrados[index]
    }
    
    func obtenerEstadisticas() -> (total: Int, engorde: Int, descarte: Int, reproduccion: Int) {
        let engorde = todosLosLotes.filter { $0.tipoLote == "Engorde" }.count
        let descarte = todosLosLotes.filter { $0.tipoLote == "Descarte" }.count
        let reproduccion = todosLosLotes.filter { $0.tipoLote == "Reproduccion" }.count
        
        return (todosLosLotes.count, engorde, descarte, reproduccion)
    }
    
    func puedeIniciarVenta(conLote lote: LoteDisponibleVentaResponse?) -> (valido: Bool, mensaje: String?) {
        guard let lote = lote else {
            return (false, "Debes seleccionar un lote")
        }
        
        if lote.cantidadAnimalesVivos == 0 {
            return (false, "El lote no tiene animales vivos")
        }
        
        if lote.sumaTotalPesos == 0 {
            return (false, "El lote no tiene peso registrado")
        }
        
        return (true, nil)
    }
    
    func formatearDatosParaVenta(lote: LoteDisponibleVentaResponse) -> DatosVentaFormateados {
        let costoTotal = NSDecimalNumber(decimal: lote.costoTotalAcumulado).doubleValue
        let costoPorAnimal = costoTotal / Double(lote.cantidadAnimalesVivos)
        
        return DatosVentaFormateados(
            nombreLote: lote.loteNombre,
            totalAnimales: "\(lote.cantidadAnimalesVivos) animales",
            pesoTotal: String(format: "%.2f kg", lote.sumaTotalPesos),
            pesoPromedio: String(format: "%.2f kg", lote.pesoPromedioLote),
            costoTotal: String(format: "S/ %.2f", costoTotal),
            costoPromedioPorAnimal: String(format: "S/ %.2f", costoPorAnimal)
        )
    }
}

struct DatosVentaFormateados {
    let nombreLote: String
    let totalAnimales: String
    let pesoTotal: String
    let pesoPromedio: String
    let costoTotal: String
    let costoPromedioPorAnimal: String
}
