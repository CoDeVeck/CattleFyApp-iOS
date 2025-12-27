//
//  ListadoDeVentasViewModel.swift
//  CattleFyApp
//
//  Created by Victor Manuel on 25/12/25.
//

import Foundation


class ListadoVentasViewModel {
    
    private var todasLasVentas: [VentaListadoResponse] = []
    private var ventasFiltradas: [VentaListadoResponse] = []
    private let granjaId: Int
    
    var filtroActual: TipoVentaFiltro = .engorde

    var onVentasActualizadas: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoading: ((Bool) -> Void)?
    
    var numeroDeVentas: Int {
        return ventasFiltradas.count
    }
    
    var roiPromedio: Double {
        guard !ventasFiltradas.isEmpty else { return 0.0 }
        let suma = ventasFiltradas.reduce(0.0) { $0 + $1.roiReal }
        return suma / Double(ventasFiltradas.count)
    }
    
    var totalAnimalesVendidos: Int {
        return ventasFiltradas.reduce(into: 0) { $0 + $1.cantidadAnimalesVivos }
    }
    
    var ingresosTotales: Decimal {
        return ventasFiltradas.reduce(0) { $0 + $1.costoTotalVenta }
    }
    
    // MARK: - Initialization
    init(granjaId: Int) {
        self.granjaId = granjaId
    }
    
    // MARK: - Data Methods
    func cargarVentas() {
        onLoading?(true)
        
        VentaService.shared.listarVentas(granjaId: granjaId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.onLoading?(false)
                
                switch result {
                case .success(let ventas):
                    self.todasLasVentas = ventas
                    self.aplicarFiltro(self.filtroActual)
                    print("✅ Ventas cargadas: \(ventas.count)")
                    
                case .failure(let error):
                    let mensaje = "Error al cargar ventas: \(error.localizedDescription)"
                    print("❌ \(mensaje)")
                    self.onError?(mensaje)
                }
            }
        }
    }
    
    func aplicarFiltro(_ filtro: TipoVentaFiltro) {
        filtroActual = filtro
        
        switch filtro {
        case .engorde:
            ventasFiltradas = todasLasVentas.filter { $0.tipoVenta.lowercased() == "engorde" }
        case .descarte:
            ventasFiltradas = todasLasVentas.filter { $0.tipoVenta.lowercased() == "descarte" }
        case .reproduccion:
            ventasFiltradas = todasLasVentas.filter { $0.tipoVenta.lowercased() == "reproduccion" }
        }
        
        print("🔎 Filtro '\(filtro.rawValue)' aplicado: \(ventasFiltradas.count) ventas")
        onVentasActualizadas?()
    }
    
    func venta(en index: Int) -> VentaListadoResponse? {
        guard index >= 0 && index < ventasFiltradas.count else { return nil }
        return ventasFiltradas[index]
    }
    
    func ventaId(en index: Int) -> Int? {
        return venta(en: index)?.ventaId
    }
}

// MARK: - Enums
enum TipoVentaFiltro: String {
    case engorde = "Engorde"
    case descarte = "Descarte"
    case reproduccion = "Reproducción"
}
