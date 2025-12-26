//
//  DetalleDeVentaViewModel.swift
//  CattleFyApp
//
//  Created by Victor Manuel on 25/12/25.
//

import Foundation

class DetalleVentaViewModel {
    
    // MARK: - Properties
    private var detalleVenta: VentaDetalleResponse?
    private let ventaId: Int
    
    // MARK: - Callbacks
    var onDetalleActualizado: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoading: ((Bool) -> Void)?
    
    // MARK: - Computed Properties
    var numeroDeAnimales: Int {
        return detalleVenta?.animalesVendidos.count ?? 0
    }
    
    var tituloVenta: String {
        guard let detalle = detalleVenta else { return "Detalle de Venta" }
        return "\(detalle.especieNombre) - \(detalle.loteNombre)"
    }
    
    var informacionBasica: InfoBasicaVenta? {
        guard let detalle = detalleVenta else { return nil }
        return InfoBasicaVenta(
            loteNombre: detalle.loteNombre,
            especieNombre: detalle.especieNombre,
            categoriaManejoNombre: detalle.categoriaManejoNombre,
            tipoVenta: detalle.tipoVenta,
            tipoAlcance: detalle.tipoAlcanceVenta,
            clienteNombre: detalle.clienteNombre,
            fechaVenta: detalle.fechaVenta
        )
    }
    
    var estadisticas: EstadisticasVenta? {
        guard let detalle = detalleVenta else { return nil }
        return EstadisticasVenta(
            cantidadAnimales: detalle.cantidadAnimalesVendidos,
            pesoTotalKg: detalle.pesoTotalKg,
            precioPorKg: detalle.precioPorKg,
            precioTotal: detalle.precioTotal,
            costoTotalInvertido: detalle.costoTotalInvertido,
            gananciaNeta: detalle.gananciaNeta,
            roiReal: detalle.roiReal,
            roiObjetivo: detalle.roiObjetivo,
            diferenciaRoi: detalle.diferenciaRoi
        )
    }
    
    var tieneAdvertencia: Bool {
        return detalleVenta?.advertencia != nil
    }
    
    var advertencia: String? {
        return detalleVenta?.advertencia
    }
    
    var tieneRecomendacion: Bool {
        return detalleVenta?.recomendacion != nil
    }
    
    var recomendacion: String? {
        return detalleVenta?.recomendacion
    }
    
    // MARK: - Initialization
    init(ventaId: Int) {
        self.ventaId = ventaId
    }
    
    // MARK: - Data Methods
    func cargarDetalle() {
        onLoading?(true)
        
        VentaService.shared.obtenerDetalleVenta(ventaId: ventaId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.onLoading?(false)
                
                switch result {
                case .success(let detalle):
                    self.detalleVenta = detalle
                    print("✅ Detalle cargado: \(detalle.cantidadAnimalesVendidos) animales")
                    self.onDetalleActualizado?()
                    
                case .failure(let error):
                    let mensaje = "Error al cargar detalle: \(error.localizedDescription)"
                    print("❌ \(mensaje)")
                    self.onError?(mensaje)
                }
            }
        }
    }
    
    func animal(en index: Int) -> DetalleAnimalVendido? {
        guard let animales = detalleVenta?.animalesVendidos,
              index >= 0 && index < animales.count else {
            return nil
        }
        return animales[index]
    }
}

// MARK: - Helper Structs
struct InfoBasicaVenta {
    let loteNombre: String
    let especieNombre: String
    let categoriaManejoNombre: String
    let tipoVenta: String
    let tipoAlcance: String
    let clienteNombre: String
    let fechaVenta: String
}

struct EstadisticasVenta {
    let cantidadAnimales: Int
    let pesoTotalKg: Decimal
    let precioPorKg: Decimal
    let precioTotal: Decimal
    let costoTotalInvertido: Decimal
    let gananciaNeta: Decimal
    let roiReal: Decimal
    let roiObjetivo: Decimal
    let diferenciaRoi: Decimal
    
    var cumplioObjetivo: Bool {
        return roiReal >= roiObjetivo
    }
    
    var porcentajeGanancia: Decimal {
        guard costoTotalInvertido > 0 else { return 0 }
        return (gananciaNeta / costoTotalInvertido) * 100
    }
}
