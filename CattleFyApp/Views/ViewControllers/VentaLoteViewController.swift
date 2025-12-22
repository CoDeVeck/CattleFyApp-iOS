//
//  VentaLoteViewController.swift
//  CattleFyApp
//
//  Created by Victor  on 10/12/25.
//

import UIKit

class VentaLoteViewController: UIViewController {
    
    @IBOutlet weak var labelNombreLoteVentaLote: UILabel!
    @IBOutlet weak var labelVentaTotalAnimalesVentaLote: UILabel!
    @IBOutlet weak var labelPesoTotalVentaLote: UILabel!
    @IBOutlet weak var labelPesoPromedioVentaLote: UILabel!
    @IBOutlet weak var labeCvtTotalVentaLote: UILabel!
    @IBOutlet weak var labelCostoDeCompraVentaLote: UILabel!
    
    
    var	loteData: LoteDisponibleVentaResponse?
    var ventaLoteNombreLote: String?
    var ventaLoteTotalAnimales: String?
    var ventaLotePesoTotal: String?
    var ventaLotePesoPromedio: String?
    var ventaLoteCvtTotal: String?
    var ventaLoteCostoDeCompra: String?
    
    
    private var datosVenta: DatosVentaCompletos?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarUI()
        mostrarDatos()
        inicializarDatosVenta()
    }
    
    // MARK: - Configuración UI
    private func configurarUI() {
        title = "Detalles de Venta - Paso 1"
        
        labelNombreLoteVentaLote.font = UIFont.boldSystemFont(ofSize: 24)
        labelNombreLoteVentaLote.textColor = .label
        
        view.subviews.compactMap { $0 as? UIButton }.forEach { button in
            button.layer.cornerRadius = 8
        }
    }
    
    // MARK: - Mostrar Datos
    private func mostrarDatos() {
        labelNombreLoteVentaLote.text = ventaLoteNombreLote ?? "Sin nombre"
        labelVentaTotalAnimalesVentaLote.text = ventaLoteTotalAnimales ?? "0"
        labelPesoTotalVentaLote.text = ventaLotePesoTotal ?? "0 kg"
        labelPesoPromedioVentaLote.text = ventaLotePesoPromedio ?? "0 kg"
        labeCvtTotalVentaLote.text = ventaLoteCvtTotal ?? "S/ 0.00"
        labelCostoDeCompraVentaLote.text = ventaLoteCostoDeCompra ?? "S/ 0.00"
        
        print("📋 Paso 1 - Mostrando datos:")
        print("  - Lote: \(ventaLoteNombreLote ?? "N/A")")
        print("  - Animales: \(ventaLoteTotalAnimales ?? "N/A")")
        
        if let lote = loteData {
            print("  - Especie: \(lote.especieNombre)")
            print("  - Tipo: \(lote.tipoLote)")
        }
    }
    
    private func inicializarDatosVenta() {
        guard let lote = loteData else {
            print("⚠️ No hay datos del lote")
            return
        }
        datosVenta = DatosVentaCompletos(loteData: lote)
    }
    
    @IBAction func siguientePaso2VentaLote(_ sender: UIButton) {
        
        guard let datos = datosVenta else {
            mostrarAlerta(titulo: "Error", mensaje: "No hay datos del lote")
            return
        }
        
        print("➡️ Navegando al Paso 2")
        performSegue(withIdentifier: "seguePaso2", sender: datos)
    }
    
    @IBAction func cancelarVentaPressed(_ sender: Any) {
        let alert = UIAlertController(
            title: "Cancelar Venta",
            message: "¿Estás seguro de que deseas cancelar el proceso de venta?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Sí, cancelar", style: .destructive) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
            print("Venta cancelada por el usuario")
        })
        
        present(alert, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "seguePaso2",
           let destinoVC = segue.destination as? VentaDeLoteDosViewController,
           let datos = sender as? DatosVentaCompletos {
            destinoVC.datosVenta = datos
        }
    }
    
    private func mostrarAlerta(titulo: String, mensaje: String) {
        let alert = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
