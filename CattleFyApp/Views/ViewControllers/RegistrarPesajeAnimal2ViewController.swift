//
//  RegistrarPesajeAnimal2ViewController.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/19/25.
//

import UIKit

class RegistrarPesajeAnimal2ViewController: UIViewController {
    
    @IBOutlet weak var pesoTextField: UITextField!
    
    var registroData: RegistroPesoAnimalData?
    private let animalesService = AnimalesService()
    private var qrAnimal: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarTextField()
        validarDatosRecibidos()
    }
    
    private func configurarTextField() {
        pesoTextField.placeholder = "Ingrese el peso en kg"
        pesoTextField.keyboardType = .decimalPad
        pesoTextField.borderStyle = .roundedRect
        pesoTextField.delegate = self
        
        // Agregar toolbar con botón "Listo" para cerrar el teclado
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(cerrarTeclado))
        toolbar.items = [flexSpace, doneButton]
        pesoTextField.inputAccessoryView = toolbar
    }
    
    @objc private func cerrarTeclado() {
        view.endEditing(true)
    }
    
    private func validarDatosRecibidos() {
        guard let data = registroData, data.idAnimal != 0 else {
            mostrarAlerta(mensaje: "Error: No se recibieron datos del animal") {
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
        
        print("ID Animal recibido: \(data.idAnimal)")
    }
    
    @IBAction func registrarPesoAnimal(_ sender: UIButton) {
        guard let data = registroData else {
            mostrarAlerta(mensaje: "Error: No hay datos del animal")
            return
        }
        
        guard let pesoText = pesoTextField.text?.trimmingCharacters(in: .whitespaces),
              !pesoText.isEmpty else {
            mostrarAlerta(mensaje: "Por favor ingrese el peso del animal")
            return
        }
        
        // Convertir el texto a Double (manejar tanto punto como coma)
        let pesoString = pesoText.replacingOccurrences(of: ",", with: ".")
        guard let peso = Double(pesoString), peso > 0 else {
            mostrarAlerta(mensaje: "Por favor ingrese un peso válido")
            return
        }
        
        // Actualizar el registro con el peso
        registroData?.peso = peso
        
        // Crear el request body
        let requestBody = AnimalPesoReq(
            idAnimal: data.idAnimal,
            peso: peso
        )
        
        // Llamar al servicio
        registrarPesoEnServicio(requestBody: requestBody)
    }
    
    private func registrarPesoEnServicio(requestBody: AnimalPesoReq) {
        // Cerrar el teclado
        view.endEditing(true)
        
        // Mostrar indicador de carga
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        // Deshabilitar el botón mientras se procesa
        view.isUserInteractionEnabled = false
        
        animalesService.registrarPeso(requestBody: requestBody) { [weak self] result in
            DispatchQueue.main.async {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                self?.view.isUserInteractionEnabled = true
                
                switch result {
                case .success(let animalResponse):
                    // Guardar el QR del animal para enviarlo a DetalleViewController
                    self?.qrAnimal = animalResponse.codigoQr
                    self?.mostrarConfirmacionYNavegar(qrAnimal: animalResponse.codigoQr ?? "")
                    
                case .failure(let error):
                    self?.mostrarAlerta(mensaje: "Error al registrar el peso: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func mostrarConfirmacionYNavegar(qrAnimal: String) {
        let alert = UIAlertController(
            title: "Éxito",
            message: "El peso se registró correctamente",
            preferredStyle: .alert
        )
        
        let verDetalleAction = UIAlertAction(title: "Ver Detalle", style: .default) { [weak self] _ in
            self?.navegarADetalleAnimal(qrAnimal: qrAnimal)
        }
        
        let volverAction = UIAlertAction(title: "Registrar Otro", style: .default) { [weak self] _ in
            self?.navigationController?.popToRootViewController(animated: true)
        }
        
        alert.addAction(verDetalleAction)
        alert.addAction(volverAction)
        
        present(alert, animated: true)
    }
    
    private func navegarADetalleAnimal(qrAnimal: String) {
        guard !qrAnimal.isEmpty else {
            mostrarAlerta(mensaje: "Error: No se pudo obtener el código QR del animal")
            return
        }
        
<<<<<<< HEAD
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
=======
        let storyboard = UIStoryboard(name: "FarmFlow", bundle: nil)
>>>>>>> c5222b3 (Subindo ultimos cambios)
        guard let detalleVC = storyboard.instantiateViewController(
            withIdentifier: "DetalleAnimalViewController"
        ) as? DetalleAnimalViewController else {
            mostrarAlerta(mensaje: "Error al cargar la vista de detalle")
            return
        }
        
        // Enviar el QR del animal
        detalleVC.codigoQR = qrAnimal
        
        navigationController?.pushViewController(detalleVC, animated: true)
    }
    
    private func mostrarAlerta(mensaje: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(
            title: "Atención",
            message: mensaje,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        }
        
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension RegistrarPesajeAnimal2ViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Permitir solo números, punto y coma para decimales
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.,")
        let characterSet = CharacterSet(charactersIn: string)
        
        // Permitir borrar
        if string.isEmpty {
            return true
        }
        
        // Validar caracteres permitidos
        guard allowedCharacters.isSuperset(of: characterSet) else {
            return false
        }
        
        // Obtener el texto resultante
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else {
            return false
        }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // Permitir solo un punto o coma decimal
        let decimalCount = updatedText.filter { $0 == "." || $0 == "," }.count
        return decimalCount <= 1
    }
}
