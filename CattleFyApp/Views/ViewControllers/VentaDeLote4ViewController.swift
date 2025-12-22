//
//  VentaDeLote4ViewController.swift
//  CattleFyApp
//
//  Created by Victor  on 11/12/25.
//

import UIKit

class VentaDeLote4ViewController: UIViewController {
    
    
    @IBOutlet weak var labelAnimalesVendidos: UILabel!
    
    @IBOutlet weak var labelPesoTotal: UILabel!
    
    @IBOutlet weak var labelPrecioKg: UILabel!
    
    @IBOutlet weak var labelIngresoTotal: UILabel!
    
    @IBOutlet weak var labelCvt: UILabel!
    @IBOutlet weak var labelRoiReal: UILabel!
    
    
    var datosVenta: DatosVentaCompletos?
    private var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("🔍 DEBUG PASO 4 - viewDidLoad")
        if let datos = datosVenta {
            print("✅ datosVenta recibidos correctamente")
            print("  - Lote ID: \(datos.loteData.loteId)")
            print("  - Cliente: \(datos.clienteNombre)")
            print("  - Precio/kg: \(datos.precioPorKg)")
        } else {
            print("❌ ERROR: datosVenta es NIL en Paso 4")
        }
        
        configurarUI()
        mostrarResumenFinal()
    }
    
    private func configurarUI() {
        title = "Confirmar Venta - Paso 4"
        
        //btnConfirmarVenta.layer.cornerRadius = 12
        //btnConfirmarVenta.backgroundColor = .systemGreen
        
        // Activity indicator
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    private func mostrarResumenFinal() {
        guard let datos = datosVenta else { return }
        
        let lote = datos.loteData
        
        // Conversiones
        let precioPorKg = NSDecimalNumber(decimal: datos.precioPorKg).doubleValue
        let precioTotal = NSDecimalNumber(decimal: datos.precioTotal).doubleValue
        let costoTotal = NSDecimalNumber(decimal: lote.costoTotalAcumulado).doubleValue
        let roiObjetivo = NSDecimalNumber(decimal: datos.roiObjetivo).doubleValue
        
        // Actualizar labels
        labelAnimalesVendidos.text = "\(lote.cantidadAnimalesVivos) animales"
        labelPesoTotal.text = String(format: "%.2f kg", lote.sumaTotalPesos)
        labelPrecioKg.text = String(format: "S/ %.2f/kg", precioPorKg)
        labelIngresoTotal.text = String(format: "S/ %.2f", precioTotal)
        labelCvt.text = String(format: "S/ %.2f", costoTotal)
        labelRoiReal.text = String(format: "%.0f%%", roiObjetivo)
        
        print("📊 Resumen Final:")
        print("  - Lote: \(lote.loteNombre)")
        print("  - Cliente: \(datos.clienteNombre)")
        print("  - Animales: \(lote.cantidadAnimalesVivos)")
        print("  - Ingreso: S/ \(precioTotal)")
        print("  - ROI: \(roiObjetivo)%")
    }
    @IBAction func btnConfirmarVenta(_ sender: UIButton) {
        guard let datos = datosVenta else {
            mostrarAlerta(titulo: "Error", mensaje: "No hay datos para registrar la venta")
            return
        }
        
        let alert = UIAlertController(
            title: "Confirmar Venta",
            message: "¿Estás seguro de registrar esta venta?\n\nCliente: \(datos.clienteNombre)\nMonto: S/ \(NSDecimalNumber(decimal: datos.precioTotal).doubleValue)",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Confirmar", style: .default) { [weak self] _ in
            self?.registrarVenta()
        })
        
        present(alert, animated: true)
    }
    
    private func registrarVenta() {
        guard let datos = datosVenta else { return }
        
        // Mostrar loading
        //btnConfirmarVenta.isEnabled = false
        //activityIndicator.startAnimating()
        
        // Formatear fecha a ISO8601
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        let fechaString = formatter.string(from: datos.fechaVenta)
        
        // Crear request
        let request = RegistroVentaRequest(
            loteId: datos.loteData.loteId,
            tipoAlcanceVenta: datos.tipoAlcanceVenta,
            tipoVenta: datos.loteData.tipoLote,
            cantidadAnimalesVender: datos.cantidadAnimales,
            animalesSeleccionados: nil,
            pesoTotalKg: Decimal(datos.loteData.sumaTotalPesos),
            precioPorKg: datos.precioPorKg,
            precioTotal: datos.precioTotal,
            roiMeta: datos.roiObjetivo,
            clienteNombre: datos.clienteNombre,
            fechaVenta: fechaString
        )
        
        print("🚀 Registrando venta...")
        
        // Llamar al service
        VentaService.shared.registrarVenta(request: request) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                //self?.btnConfirmarVenta = true
                
                switch result {
                case .success(let response):
                    self?.ventaRegistradaExitosamente(response: response)
                    
                case .failure(let error):
                    self?.mostrarError(error: error)
                }
            }
        }
    }
    
    private func ventaRegistradaExitosamente(response: VentaDetalleResponse) {
        print("✅ Venta registrada - ID: \(response.ventaId)")
        
        let roiReal = NSDecimalNumber(decimal: response.roiReal).doubleValue
        let gananciaNeta = NSDecimalNumber(decimal: response.gananciaNeta).doubleValue
        
        var mensaje = """
    Venta registrada exitosamente
    
    ID: \(response.ventaId)
    Cliente: \(response.clienteNombre)
    Animales vendidos: \(response.cantidadAnimalesVendidos)
    ROI Real: \(String(format: "%.2f%%", roiReal))
    Ganancia: S/ \(String(format: "%.2f", gananciaNeta))
    """
        
        if let advertencia = response.advertencia {
            mensaje += "\n\n⚠️ \(advertencia)"
        }
        
        if let recomendacion = response.recomendacion {
            mensaje += "\n\n💡 \(recomendacion)"
        }
        
        let alert = UIAlertController(
            title: "¡Venta Exitosa! 🎉",
            message: mensaje,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Ver Detalles", style: .default) { [weak self] _ in
            self?.mostrarDetalles(response: response)
        })
        
        alert.addAction(UIAlertAction(title: "Finalizar", style: .default) { [weak self] _ in
            self?.volverAlInicio()
        })
        
        present(alert, animated: true)
    }
    
    private func mostrarDetalles(response: VentaDetalleResponse) {
        let roiReal = NSDecimalNumber(decimal: response.roiReal).doubleValue
        let precioTotal = NSDecimalNumber(decimal: response.precioTotal).doubleValue
        let costoTotal = NSDecimalNumber(decimal: response.costoTotalInvertido).doubleValue
        let gananciaNeta = NSDecimalNumber(decimal: response.gananciaNeta).doubleValue
        
        var detalles = """
    📋 DETALLES COMPLETOS DE LA VENTA
    
    Lote: \(response.loteNombre)
    Tipo: \(response.tipoVenta)
    
    💰 FINANCIERO:
    • Ingreso Total: S/ \(String(format: "%.2f", precioTotal))
    • Costo Total: S/ \(String(format: "%.2f", costoTotal))
    • Ganancia Neta: S/ \(String(format: "%.2f", gananciaNeta))
    
    📊 ROI:
    • ROI Objetivo: \(response.roiObjetivo)%
    • ROI Real: \(String(format: "%.2f%%", roiReal))
    • Diferencia: \(response.diferenciaRoi)%
    
    🐄 ANIMALES:
    • Vendidos: \(response.cantidadAnimalesVendidos)
    • Peso Total: \(response.pesoTotalKg) kg
    
    👤 CLIENTE:
    • Nombre: \(response.clienteNombre)
    • Fecha: \(response.fechaVenta)
    """
        
        let alert = UIAlertController(
            title: "Detalles de Venta",
            message: detalles,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Finalizar", style: .default) { [weak self] _ in
            self?.volverAlInicio()
        })
        
        present(alert, animated: true)
    }
    
    private func mostrarError(error: Error) {
        print("❌ Error al registrar venta: \(error.localizedDescription)")
        
        let alert = UIAlertController(
            title: "Error al Registrar",
            message: "No se pudo registrar la venta:\n\n\(error.localizedDescription)\n\n¿Deseas reintentar?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Reintentar", style: .default) { [weak self] _ in
            self?.registrarVenta()
        })
        
        present(alert, animated: true)
    }
    
    private func volverAlInicio() {
        // Navegar al VentaComercialViewController
        if let ventaVC = storyboard?.instantiateViewController(withIdentifier: "VentaComercialViewController") {
            navigationController?.setViewControllers([ventaVC], animated: true)
            print("✅ Navegando al inicio")
        } else {
            // Fallback: volver al root
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    private func mostrarAlerta(titulo: String, mensaje: String) {
        let alert = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
