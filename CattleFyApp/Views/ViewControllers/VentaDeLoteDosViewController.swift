//
//  VentaDeLoteDosViewController.swift
//  CattleFyApp
//
//  Created by Victor Narazas on 16/12/25.
//

import UIKit

class VentaDeLoteDosViewController: UIViewController {
    
    
    @IBOutlet weak var sliderMargenDeUtilidad: UISlider!
    @IBOutlet weak var labelPrecioSugerido: UILabel!
    @IBOutlet weak var labelIngresoTotalEstimado: UILabel!
    @IBOutlet weak var labelRoiEstimado: UILabel!
    @IBOutlet weak var labelUtilidadNeta: UILabel!
    @IBOutlet weak var labelPrecioAcordado: UILabel!
    
    
    
    var datosVenta: DatosVentaCompletos?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarUI()
        calcularPrecios()
    }
    
    private func configurarUI() {
        title = "Precio y ROI - Paso 2"
        
        
        sliderMargenDeUtilidad.minimumValue = 0
        sliderMargenDeUtilidad.maximumValue = 100
        sliderMargenDeUtilidad.value = 30
        sliderMargenDeUtilidad.addTarget(self, action: #selector(sliderCambiado), for: .valueChanged)
        
        
        labelPrecioSugerido.font = UIFont.boldSystemFont(ofSize: 20)
        labelIngresoTotalEstimado.font = UIFont.boldSystemFont(ofSize: 18)
        labelRoiEstimado.font = UIFont.boldSystemFont(ofSize: 18)
    }
    
    @objc private func sliderCambiado() {
        calcularPrecios()
    }
    
    private func calcularPrecios() {
        guard let datos = datosVenta else { return }
        
        let roiObjetivo = Decimal(Double(sliderMargenDeUtilidad.value))
        let lote = datos.loteData
        
        
        let costoTotal = lote.costoTotalAcumulado
        let pesoTotal = Decimal(lote.sumaTotalPesos)
        
        let precioBase = lote.precioSugeridoPorKgBase
        let factorROI = (1 + (roiObjetivo / 100))
        let precioPorKg = precioBase * factorROI
        
        
        let ingresoTotal = precioPorKg * pesoTotal
        
        
        let utilidadNeta = ingresoTotal - costoTotal
        
        
        datosVenta?.precioPorKg = precioPorKg
        datosVenta?.precioTotal = ingresoTotal
        datosVenta?.roiObjetivo = roiObjetivo
        
        
        actualizarLabels(
            precioBase: precioBase,
            precioPorKg: precioPorKg,
            ingresoTotal: ingresoTotal,
            roiObjetivo: roiObjetivo,
            utilidadNeta: utilidadNeta
        )
    }
    
    private func actualizarLabels(
        precioBase: Decimal,
        precioPorKg: Decimal,
        ingresoTotal: Decimal,
        roiObjetivo: Decimal,
        utilidadNeta: Decimal
    ) {
        let precioBaseDouble = NSDecimalNumber(decimal: precioBase).doubleValue
        let precioPorKgDouble = NSDecimalNumber(decimal: precioPorKg).doubleValue
        let ingresoTotalDouble = NSDecimalNumber(decimal: ingresoTotal).doubleValue
        let utilidadNetaDouble = NSDecimalNumber(decimal: utilidadNeta).doubleValue
        
        labelPrecioSugerido.text = String(format: "Precio base: S/ %.2f/kg", precioBaseDouble)
        labelPrecioAcordado.text = String(format: "S/ %.2f/kg", precioPorKgDouble)
        labelIngresoTotalEstimado.text = String(format: "S/ %.2f", ingresoTotalDouble)
        labelRoiEstimado.text = String(format: "%.0f%%", NSDecimalNumber(decimal: roiObjetivo).doubleValue)
        
        if utilidadNeta > 0 {
            labelUtilidadNeta.textColor = .systemGreen
            labelUtilidadNeta.text = String(format: "+S/ %.2f", utilidadNetaDouble)
        } else {
            labelUtilidadNeta.textColor = .systemRed
            labelUtilidadNeta.text = String(format: "S/ %.2f", utilidadNetaDouble)
        }
        
        print("💰 Cálculos actualizados:")
        print("  - ROI objetivo: \(roiObjetivo)%")
        print("  - Precio/kg: S/ \(precioPorKgDouble)")
        print("  - Ingreso total: S/ \(ingresoTotalDouble)")
    }
    
    
    @IBAction func siguientePaso3Pressed(_ sender: Any) {
        guard let datos = datosVenta else {
            mostrarAlerta(titulo: "Error", mensaje: "No hay datos disponibles")
            return
        }
        
        if datos.precioPorKg <= 0 {
            mostrarAlerta(titulo: "Error", mensaje: "El precio debe ser mayor a 0")
            return
        }
        
        print("➡️ Navegando al Paso 3")
        performSegue(withIdentifier: "seguePaso3", sender: datos)
    }
    
    @IBAction func cancelarVentaPressed(_ sender: Any) {
        confirmarCancelacion()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "seguePaso3",
           let destinoVC = segue.destination as? VentaDeLote3ViewController,
           let datos = sender as? DatosVentaCompletos {
            destinoVC.datosVenta = datos
        }
    }
    
    private func confirmarCancelacion() {
        let alert = UIAlertController(
            title: "Cancelar Venta",
            message: "¿Deseas cancelar el proceso?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        alert.addAction(UIAlertAction(title: "Sí", style: .destructive) { [weak self] _ in
            self?.navigationController?.popToRootViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    private func mostrarAlerta(titulo: String, mensaje: String) {
        let alert = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
