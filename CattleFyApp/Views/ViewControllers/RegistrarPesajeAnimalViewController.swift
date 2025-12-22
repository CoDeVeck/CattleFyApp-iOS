//
//  RegistrarPesajeAnimalViewController.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/19/25.
//

import UIKit

class RegistrarPesajeAnimalViewController: UIViewController {
    
    @IBOutlet weak var codigoQRAnimalLabel: UILabel!
    
    
    @IBOutlet weak var especieLabel: UILabel!
    
    
    @IBOutlet weak var edadEnDiasLabel: UILabel!
    
    
    @IBOutlet weak var nombreLoteLabel: UILabel!
    
    
    
    
    
    @IBOutlet weak var pesoKgLabel: UILabel!
    
    
    @IBOutlet weak var codifoQRTextField: UITextField!
    
    private let animalesService = AnimalesService()
    private var registro = RegistroPesoAnimalData()
    
    var codigoQR: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        limpiarLabels()
        configurarTextField()
    }
    
    private func configurarTextField() {
        codifoQRTextField.placeholder = "Ingrese código QR"
        codifoQRTextField.borderStyle = .roundedRect
        codifoQRTextField.clearButtonMode = .whileEditing
        codifoQRTextField.returnKeyType = .search
        codifoQRTextField.delegate = self
    }
    
    @IBAction func EscanearQRAnimal(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true)
    }
    
    private func procesarImagenQR(_ image: UIImage) {
        guard let ciImage = CIImage(image: image) else {
            mostrarAlerta(mensaje: "Error al procesar la imagen")
            return
        }
        
        let context = CIContext()
        let detector = CIDetector(
            ofType: CIDetectorTypeQRCode,
            context: context,
            options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        )
        
        guard let features = detector?.features(in: ciImage) as? [CIQRCodeFeature],
              let qrFeature = features.first,
              let qrString = qrFeature.messageString else {
            mostrarAlerta(mensaje: "No se detectó ningún código QR en la imagen")
            return
        }
        
        // Actualizar el TextField con el código escaneado
        codifoQRTextField.text = qrString
        buscarAnimalPorQR(qrString)
    }
    
    private func buscarAnimalPorQR(_ codigoQr: String) {
        // Cerrar el teclado
        view.endEditing(true)
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        animalesService.obtenerAnimalPorQR(qrAnimal: codigoQr) { [weak self] result in
            DispatchQueue.main.async {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                
                switch result {
                case .success(let animal):
                    self?.configurarDatosAnimal(animal)
                case .failure(let error):
                    self?.mostrarAlerta(mensaje: "Error al buscar el animal: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @IBAction func buscadorManualQRButton(_ sender: UIButton) {
        guard let codigoQR = codifoQRTextField.text?.trimmingCharacters(in: .whitespaces),
              !codigoQR.isEmpty else {
            mostrarAlerta(mensaje: "Por favor ingrese un código QR válido")
            return
        }
        
        buscarAnimalPorQR(codigoQR)
    }
    
    @IBAction func siguienteButton(_ sender: UIButton) {
        guard registro.idAnimal != 0 else {
            mostrarAlerta(mensaje: "Por favor busque un animal primero")
            return
        }
        
        let storyboard = UIStoryboard(name: "FarmFlow", bundle: nil)
        guard let siguienteVC = storyboard.instantiateViewController(
            withIdentifier: "RegistrarPesajeAnimal2ViewController"
        ) as? RegistrarPesajeAnimal2ViewController else {
            mostrarAlerta(mensaje: "Error al cargar la siguiente vista")
            return
        }
        
        siguienteVC.registroData = registro
        navigationController?.pushViewController(siguienteVC, animated: true)
    }
    
    private func configurarDatosAnimal(_ animal: AnimalResponse) {
        // Guardar el ID del animal en el registro
        registro.idAnimal = animal.idAnimal ?? 0
        
        // Mostrar los datos en los labels
        codigoQRAnimalLabel.text = animal.codigoQr ?? "N/A"
        especieLabel.text = animal.especie ?? "N/A"
        let edadDias = String(animal.edadEnDias ?? 0)
        edadEnDiasLabel.text = "\(edadDias) días"
        nombreLoteLabel.text = animal.lote ?? "N/A"
        
        // El peso actual del animal (si existe en la respuesta)
        if let pesoActual = animal.peso {
            pesoKgLabel.text = "\(pesoActual) kg"
        } else {
            pesoKgLabel.text = "Sin registro"
        }
    }
    
    private func limpiarLabels() {
        codigoQRAnimalLabel.text = "-"
        especieLabel.text = "-"
        edadEnDiasLabel.text = "-"
        nombreLoteLabel.text = "-"
        pesoKgLabel.text = "-"
    }
    
    private func mostrarAlerta(mensaje: String) {
        let alert = UIAlertController(
            title: "Atención",
            message: mensaje,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension RegistrarPesajeAnimalViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage else {
            mostrarAlerta(mensaje: "Error al obtener la imagen")
            return
        }
        
        procesarImagenQR(image)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension RegistrarPesajeAnimalViewController: UITextFieldDelegate {
    // Permite buscar al presionar "Enter" en el teclado
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == codifoQRTextField {
            buscadorManualQRButton(UIButton()) // Simula el tap del botón
        }
        return true
    }
}
