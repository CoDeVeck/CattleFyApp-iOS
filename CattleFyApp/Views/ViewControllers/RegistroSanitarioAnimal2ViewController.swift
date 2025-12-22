//
//  RegistroSanitarioAnimal2ViewController.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/19/25.
//

import UIKit

class RegistroSanitarioAnimal2ViewController: UIViewController {
    
    @IBOutlet weak var tipoProtocolo: UISegmentedControl!
    @IBOutlet weak var nombreProducto: UITextField!
    @IBOutlet weak var dosisAplicada: UITextField!
    @IBOutlet weak var costoUnitario: UITextField!
    @IBOutlet weak var fechaAplicacion: UIDatePicker!
    
    private let dataModel = RegistroSanitarioData.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarVista()
        cargarDatosGuardados()
    }
    
    private func configurarVista() {
        title = "Protocolo Sanitario"
        
        // Configurar segmented control
        tipoProtocolo.setTitle("Vacuna", forSegmentAt: 0)
        tipoProtocolo.setTitle("Tratamiento", forSegmentAt: 1)
        tipoProtocolo.selectedSegmentIndex = 0
        
        // Configurar date picker
        fechaAplicacion.datePickerMode = .dateAndTime
        fechaAplicacion.maximumDate = Date()
        fechaAplicacion.preferredDatePickerStyle = .wheels
        
        // Configurar text fields
        nombreProducto.placeholder = "Ej: Vacuna Triple, Ivermectina"
        dosisAplicada.placeholder = "Ej: 1.5"
        dosisAplicada.keyboardType = .decimalPad
        costoUnitario.placeholder = "Ej: 25.50"
        costoUnitario.keyboardType = .decimalPad
        
        // Delegates
        nombreProducto.delegate = self
        dosisAplicada.delegate = self
        costoUnitario.delegate = self
        
        // Agregar toolbar para teclado numérico
        agregarToolbarATeclado(dosisAplicada)
        agregarToolbarATeclado(costoUnitario)
    }
    
    private func cargarDatosGuardados() {
        // Si ya hay datos guardados, cargarlos
        if let tipo = dataModel.tipoProtocolo {
            tipoProtocolo.selectedSegmentIndex = tipo == "Vacuna" ? 0 : 1
        }
        
        nombreProducto.text = dataModel.nombreProducto
        
        if let dosis = dataModel.dosisAplicada {
            dosisAplicada.text = "\(dosis)"
        }
        
        if let costo = dataModel.costoUnitario {
            costoUnitario.text = "\(costo)"
        }
        
        if let fecha = dataModel.fechaAplicacion {
            fechaAplicacion.date = fecha
        }
    }
    
    private func agregarToolbarATeclado(_ textField: UITextField) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(cerrarTeclado))
        
        toolbar.items = [flexSpace, doneButton]
        textField.inputAccessoryView = toolbar
    }
    
    @objc private func cerrarTeclado() {
        view.endEditing(true)
    }
    
    @IBAction func siguienteButton(_ sender: UIButton) {
        // Validar campos
        guard validarCampos() else {
            return
        }
        
        // Guardar datos en el modelo
        guardarDatos()
        
        // Navegar al paso 3
        if let paso3 = storyboard?.instantiateViewController(
            withIdentifier: "RegistroSanitarioAnimal3ViewController"
        ) as? RegistroSanitarioAnimal3ViewController {
            navigationController?.pushViewController(paso3, animated: true)
        }
    }
    
    private func validarCampos() -> Bool {
        // Validar nombre producto
        guard let producto = nombreProducto.text?.trimmingCharacters(in: .whitespaces),
              !producto.isEmpty else {
            mostrarError("Debe ingresar el nombre del producto")
            return false
        }
        
        // Validar dosis
        guard let dosisText = dosisAplicada.text?.trimmingCharacters(in: .whitespaces),
              !dosisText.isEmpty,
              let dosis = Decimal(string: dosisText),
              dosis > 0 else {
            mostrarError("Debe ingresar una dosis válida mayor a 0")
            return false
        }
        
        // Validar costo
        guard let costoText = costoUnitario.text?.trimmingCharacters(in: .whitespaces),
              !costoText.isEmpty,
              let costo = Decimal(string: costoText),
              costo > 0 else {
            mostrarError("Debe ingresar un costo válido mayor a 0")
            return false
        }
        
        // Validar fecha (no puede ser futura)
        if fechaAplicacion.date > Date() {
            mostrarError("La fecha de aplicación no puede ser futura")
            return false
        }
        
        return true
    }
    
    private func guardarDatos() {
        // Guardar tipo de protocolo
        dataModel.tipoProtocolo = tipoProtocolo.selectedSegmentIndex == 0 ? "Vacuna" : "Tratamiento"
        
        // Guardar nombre producto
        dataModel.nombreProducto = nombreProducto.text?.trimmingCharacters(in: .whitespaces)
        
        // Guardar dosis
        if let dosisText = dosisAplicada.text?.trimmingCharacters(in: .whitespaces),
           let dosis = Decimal(string: dosisText) {
            dataModel.dosisAplicada = dosis
        }
        
        // Guardar costo
        if let costoText = costoUnitario.text?.trimmingCharacters(in: .whitespaces),
           let costo = Decimal(string: costoText) {
            dataModel.costoUnitario = costo
        }
        
        // Guardar fecha
        dataModel.fechaAplicacion = fechaAplicacion.date
    }
    
    private func mostrarError(_ mensaje: String) {
        let alert = UIAlertController(
            title: "Validación",
            message: mensaje,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension RegistroSanitarioAnimal2ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nombreProducto {
            dosisAplicada.becomeFirstResponder()
        } else if textField == dosisAplicada {
            costoUnitario.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    // Validar entrada numérica para campos decimales
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Solo para campos numéricos
        guard textField == dosisAplicada || textField == costoUnitario else {
            return true
        }
        
        // Permitir borrar
        if string.isEmpty {
            return true
        }
        
        // Validar caracteres numéricos y punto decimal
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
        let characterSet = CharacterSet(charactersIn: string)
        
        guard allowedCharacters.isSuperset(of: characterSet) else {
            return false
        }
        
        // Validar solo un punto decimal
        let currentText = textField.text ?? ""
        if string == "." && currentText.contains(".") {
            return false
        }
        
        return true
    }
}
