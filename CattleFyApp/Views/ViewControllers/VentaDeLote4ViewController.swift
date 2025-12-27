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
        
<<<<<<< HEAD
        print("🔍 DEBUG PASO 4 - viewDidLoad")
        if let datos = datosVenta {
            print("✅ datosVenta recibidos correctamente")
=======
        
        if let datos = datosVenta {
            print("datosVenta recibidos correctamente")
>>>>>>> c5222b3 (Subindo ultimos cambios)
            print("  - Lote ID: \(datos.loteData.loteId)")
            print("  - Cliente: \(datos.clienteNombre)")
            print("  - Precio/kg: \(datos.precioPorKg)")
        } else {
<<<<<<< HEAD
            print("❌ ERROR: datosVenta es NIL en Paso 4")
=======
            print("ERROR: datosVenta es NIL en Paso 4")
>>>>>>> c5222b3 (Subindo ultimos cambios)
        }
        
        configurarUI()
        mostrarResumenFinal()
    }
    
    private func configurarUI() {
        title = "Confirmar Venta - Paso 4"
        
<<<<<<< HEAD
        //btnConfirmarVenta.layer.cornerRadius = 12
        //btnConfirmarVenta.backgroundColor = .systemGreen
        
        // Activity indicator
=======
>>>>>>> c5222b3 (Subindo ultimos cambios)
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    private func mostrarResumenFinal() {
        guard let datos = datosVenta else { return }
        
        let lote = datos.loteData
        
<<<<<<< HEAD
        // Conversiones
=======
>>>>>>> c5222b3 (Subindo ultimos cambios)
        let precioPorKg = NSDecimalNumber(decimal: datos.precioPorKg).doubleValue
        let precioTotal = NSDecimalNumber(decimal: datos.precioTotal).doubleValue
        let costoTotal = NSDecimalNumber(decimal: lote.costoTotalAcumulado).doubleValue
        let roiObjetivo = NSDecimalNumber(decimal: datos.roiObjetivo).doubleValue
        
<<<<<<< HEAD
        // Actualizar labels
=======
>>>>>>> c5222b3 (Subindo ultimos cambios)
        labelAnimalesVendidos.text = "\(lote.cantidadAnimalesVivos) animales"
        labelPesoTotal.text = String(format: "%.2f kg", lote.sumaTotalPesos)
        labelPrecioKg.text = String(format: "S/ %.2f/kg", precioPorKg)
        labelIngresoTotal.text = String(format: "S/ %.2f", precioTotal)
        labelCvt.text = String(format: "S/ %.2f", costoTotal)
        labelRoiReal.text = String(format: "%.0f%%", roiObjetivo)
        
<<<<<<< HEAD
        print("📊 Resumen Final:")
=======
        print("Resumen Final:")
>>>>>>> c5222b3 (Subindo ultimos cambios)
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
        
<<<<<<< HEAD
        present(alert, animated: true)
=======
        
        present(alert, animated: true)
        volverAlInicio()
>>>>>>> c5222b3 (Subindo ultimos cambios)
    }
    
    private func registrarVenta() {
        guard let datos = datosVenta else { return }
        
<<<<<<< HEAD
        // Mostrar loading
        //btnConfirmarVenta.isEnabled = false
        //activityIndicator.startAnimating()
        
        // Formatear fecha a ISO8601
=======
        
>>>>>>> c5222b3 (Subindo ultimos cambios)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        let fechaString = formatter.string(from: datos.fechaVenta)
        
<<<<<<< HEAD
        // Crear request
=======
>>>>>>> c5222b3 (Subindo ultimos cambios)
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
        
<<<<<<< HEAD
        print("🚀 Registrando venta...")
        
        // Llamar al service
        VentaService.shared.registrarVenta(request: request) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                //self?.btnConfirmarVenta = true
=======
        print("Registrando venta...")
        
        
        VentaService.shared.registrarVenta(request: request) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
>>>>>>> c5222b3 (Subindo ultimos cambios)
                
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
<<<<<<< HEAD
        print("✅ Venta registrada - ID: \(response.ventaId)")
=======
        print("Venta registrada - ID: \(response.ventaId)")
>>>>>>> c5222b3 (Subindo ultimos cambios)
        
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
<<<<<<< HEAD
            mensaje += "\n\n⚠️ \(advertencia)"
        }
        
        if let recomendacion = response.recomendacion {
            mensaje += "\n\n💡 \(recomendacion)"
        }
        
        let alert = UIAlertController(
            title: "¡Venta Exitosa! 🎉",
=======
            mensaje += "\n\n \(advertencia)"
        }
        
        if let recomendacion = response.recomendacion {
            mensaje += "\n\n \(recomendacion)"
        }
        
        let alert = UIAlertController(
            title: "¡Venta Exitosa!",
>>>>>>> c5222b3 (Subindo ultimos cambios)
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
    
<<<<<<< HEAD
    💰 FINANCIERO:
=======
    FINANCIERO:
>>>>>>> c5222b3 (Subindo ultimos cambios)
    • Ingreso Total: S/ \(String(format: "%.2f", precioTotal))
    • Costo Total: S/ \(String(format: "%.2f", costoTotal))
    • Ganancia Neta: S/ \(String(format: "%.2f", gananciaNeta))
    
<<<<<<< HEAD
    📊 ROI:
=======
     ROI:
>>>>>>> c5222b3 (Subindo ultimos cambios)
    • ROI Objetivo: \(response.roiObjetivo)%
    • ROI Real: \(String(format: "%.2f%%", roiReal))
    • Diferencia: \(response.diferenciaRoi)%
    
<<<<<<< HEAD
    🐄 ANIMALES:
    • Vendidos: \(response.cantidadAnimalesVendidos)
    • Peso Total: \(response.pesoTotalKg) kg
    
    👤 CLIENTE:
=======
     ANIMALES:
    • Vendidos: \(response.cantidadAnimalesVendidos)
    • Peso Total: \(response.pesoTotalKg) kg
    
     CLIENTE:
>>>>>>> c5222b3 (Subindo ultimos cambios)
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
<<<<<<< HEAD
        print("❌ Error al registrar venta: \(error.localizedDescription)")
=======
        print(" Error al registrar venta: \(error.localizedDescription)")
>>>>>>> c5222b3 (Subindo ultimos cambios)
        
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
<<<<<<< HEAD
        // Navegar al VentaComercialViewController
        if let ventaVC = storyboard?.instantiateViewController(withIdentifier: "VentaComercialViewController") {
            navigationController?.setViewControllers([ventaVC], animated: true)
            print("✅ Navegando al inicio")
        } else {
            // Fallback: volver al root
=======
        
        if let ventaVC = storyboard?.instantiateViewController(withIdentifier: "VentaComercialViewController") {
            navigationController?.setViewControllers([ventaVC], animated: true)
            print(" Navegando al inicio")
        } else {
>>>>>>> c5222b3 (Subindo ultimos cambios)
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
<<<<<<< HEAD
   
=======
    
>>>>>>> c5222b3 (Subindo ultimos cambios)
}
