//
//  RegistroSanitarioMasivoPt2ViewController.swift
//  CattleFyApp
//
//  Created by Andy Yahir Valdivia Centeno on 11/12/25.
//

import UIKit

class RegistroSanitarioMasivoPt2ViewController: UIViewController {
    
    @IBOutlet weak var protocoloPickerView: UIPickerView!
    
    @IBOutlet weak var nombreProductoTextField: UITextField!
    
    @IBOutlet weak var dosisTextField: UITextField!
    
    @IBOutlet weak var animalesTextField: UITextField!
    
    @IBOutlet weak var costoUnitTextField: UITextField!
    
    @IBOutlet weak var fechaAplicacionPicker: UIDatePicker!
    
    @IBOutlet weak var costoTotalTextField: UILabel!
    
    @IBOutlet weak var siguienteButton: UIButton!
    
    var registroData: RegistroSanitarioUIData!
    
    private let protocoloOpciones = ["Vacunación", "Tratamiento"]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        protocoloPickerView.delegate = self
        protocoloPickerView.dataSource = self
        fechaAplicacionPicker.datePickerMode = .date
        fechaAplicacionPicker.isUserInteractionEnabled = false
        dosisTextField.addTarget(self, action: #selector(actualizarCostoTotal), for: .editingChanged)
        animalesTextField.addTarget(self, action: #selector(actualizarCostoTotal), for: .editingChanged)
        costoUnitTextField.addTarget(self, action: #selector(actualizarCostoTotal), for: .editingChanged)
    }
    
    @objc private func actualizarCostoTotal() {
        
        let dosis = Decimal(string: dosisTextField.text ?? "") ?? 0
        let animales = Decimal(string: animalesTextField.text ?? "") ?? 0
        let costoUnit = Decimal(string: costoUnitTextField.text ?? "") ?? 0
        
        let costoTotal = dosis * animales * costoUnit
        
        costoTotalTextField.text = "S/ \(costoTotal)"
    }
    
    private func validarDatos() -> Bool {
        guard let nombreProducto = nombreProductoTextField.text, !nombreProducto.isEmpty else {
            mostrarAlerta(mensaje: "Debe ingresar el nombre del producto")
            return false
        }
        
        guard let dosisStr = dosisTextField.text,
              let _ = Decimal(string: dosisStr),
              !dosisStr.isEmpty else {
            mostrarAlerta(mensaje: "Debe ingresar una dosis válida")
            return false
        }
        
        guard let animalesStr = animalesTextField.text,
              let _ = Int(animalesStr),
              !animalesStr.isEmpty else {
            mostrarAlerta(mensaje: "Debe ingresar la cantidad de animales tratados")
            return false
        }
        
        guard let costoStr = costoUnitTextField.text,
              let _ = Decimal(string: costoStr),
              !costoStr.isEmpty else {
            mostrarAlerta(mensaje: "Debe ingresar el costo por dosis")
            return false
        }
        
        return true
    }
    
    @IBAction func siguienteButtonTapped(_ sender: UIButton) {
        guard validarDatos() else { return }
        
        registroData.protocoloTipo = protocoloOpciones[protocoloPickerView.selectedRow(inComponent: 0)]
        registroData.nombreProducto = nombreProductoTextField.text
        registroData.cantidadDosis = Decimal(string: dosisTextField.text ?? "0")
        registroData.animalesTratados = Int(animalesTextField.text ?? "0")
        registroData.costoPorDosis = Decimal(string: costoUnitTextField.text ?? "0")
        registroData.fechaAplicacion = fechaAplicacionPicker.date
        registroData.tipoAplicacion = "Masivo"
        // 🔥 CALCULO REAL
        let dosis = registroData.cantidadDosis ?? 0
        let animales = Decimal(registroData.animalesTratados ?? 0)
        let costoUnit = registroData.costoPorDosis ?? 0
        
        registroData.costoTotal = dosis * animales * costoUnit
        
        // Ir a la siguiente pantalla
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let resumenVC = storyboard.instantiateViewController(
            withIdentifier: "RegistroSanitarioMasivoPt3ViewController"
        ) as! RegistroSanitarioMasivoPt3ViewController
        
        resumenVC.registroData = registroData
        
        print("✔️ DATA LISTA:", registroData)
        
        navigationController?.pushViewController(resumenVC, animated: true)
    }
}

extension RegistroSanitarioMasivoPt2ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return protocoloOpciones.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return protocoloOpciones[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        registroData.protocoloTipo = protocoloOpciones[row]
    }
}
