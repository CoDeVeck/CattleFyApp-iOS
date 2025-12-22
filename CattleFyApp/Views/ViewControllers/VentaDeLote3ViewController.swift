//
//  VentaDeLote3ViewController.swift
//  CattleFyApp
//
//  Created by Victor  on 11/12/25.
//

import UIKit

class VentaDeLote3ViewController: UIViewController {
    
    
    @IBOutlet weak var labelPrecioKgAcordado: UILabel!
    
    @IBOutlet weak var datePickerFechaVenta: UIDatePicker!
    
    @IBOutlet weak var labelNombreCliente: UITextField!
    
    
    
    var datosVenta: DatosVentaCompletos?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarUI()
        mostrarResumen()
    }
    
    private func configurarUI() {
        title = "Cliente y Fecha - Paso 3"
        
        // Configurar date picker
        datePickerFechaVenta.datePickerMode = .dateAndTime
        datePickerFechaVenta.minimumDate = Date()
        datePickerFechaVenta.maximumDate = Calendar.current.date(byAdding: .month, value: 3, to: Date())
        
        // Configurar text field
        labelNombreCliente.placeholder = "Nombre del cliente"
        labelNombreCliente.borderStyle = .roundedRect
        labelNombreCliente.autocapitalizationType = .words
        labelNombreCliente.returnKeyType = .done
        labelNombreCliente.delegate = self
        
        // Agregar gesture para ocultar teclado
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ocultarTeclado))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func ocultarTeclado() {
        view.endEditing(true)
    }
    
    private func mostrarResumen() {
        guard let datos = datosVenta else { return }
        
        let precioPorKg = NSDecimalNumber(decimal: datos.precioPorKg).doubleValue
        labelPrecioKgAcordado?.text = String(format: "Precio acordado: S/ %.2f/kg", precioPorKg)
        
        print("📋 Paso 3 - Resumen:")
        print("  - Lote: \(datos.loteData.loteNombre)")
        print("  - Precio/kg: S/ \(precioPorKg)")
        print("  - ROI objetivo: \(datos.roiObjetivo)%")
    }
    @IBAction func btnSiguientePaso4Pressed(_ sender: UIButton) {
        // Validar nombre del cliente
        guard let nombreCliente = labelNombreCliente.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !nombreCliente.isEmpty else {
            mostrarAlerta(titulo: "Campo requerido", mensaje: "Debes ingresar el nombre del cliente")
            return
        }
        
        guard nombreCliente.count >= 3 else {
            mostrarAlerta(titulo: "Nombre inválido", mensaje: "El nombre debe tener al menos 3 caracteres")
            return
        }
        
        // Validar fecha
        let fechaSeleccionada = datePickerFechaVenta.date
        
        // Actualizar datos
        datosVenta?.clienteNombre = nombreCliente
        datosVenta?.fechaVenta = fechaSeleccionada
        
        print("✅ Datos del cliente guardados:")
        print("  - Cliente: \(nombreCliente)")
        print("  - Fecha: \(fechaSeleccionada)")
        
        guard let datos = datosVenta else {
            print("❌ ERROR: datosVenta es nil en Paso 3")
            mostrarAlerta(titulo: "Error", mensaje: "Error interno: datos perdidos")
            return
        }
        
        print("🚀 INTENTANDO SEGUE A PASO 4")
        print("  - Lote ID: \(datos.loteData.loteId)")
        print("  - Cliente: \(datos.clienteNombre)")
        print("  - Precio/kg: \(datos.precioPorKg)")
        
        performSegue(withIdentifier: "seguePaso4", sender: datos)
        
    }
    
    @IBAction func cancelarVentaPressed(_ sender: UIButton) {
        confirmarCancelacion()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "seguePaso4",
           let destinoVC = segue.destination as? VentaDeLote4ViewController,
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
    
   
}



// MARK: - UITextFieldDelegate
extension VentaDeLote3ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
