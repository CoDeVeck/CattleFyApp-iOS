//
//  RegistroNacimientoAnimal2ViewController.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/19/25.
//

import UIKit

class RegistroNacimientoAnimal2ViewController: UIViewController {
    
    @IBOutlet weak var imageViewAnimal: UIImageView!
    @IBOutlet weak var pickerDate: UIDatePicker!
    @IBOutlet weak var pesoTextField: UITextField!
    @IBOutlet weak var segmentSexoAnimal: UISegmentedControl!
    
    var registroAnimalData: RegistroAnimalData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerDate.maximumDate = Date()
        
        pesoTextField.keyboardType = .decimalPad
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cerrarTeclado))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func cerrarTeclado() {
        view.endEditing(true)
    }
    
    @IBAction func escogerFotoDeAnimal(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        let alertController = UIAlertController(title: "Seleccionar foto", message: "¿De dónde quieres obtener la foto?", preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(UIAlertAction(title: "Cámara", style: .default) { _ in
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true)
            })
        }
        
        alertController.addAction(UIAlertAction(title: "Galería", style: .default) { _ in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true)
        })
        
        alertController.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        
        present(alertController, animated: true)
    }
    
    @IBAction func siguienteButton(_ sender: UIButton) {
        guard let pesoTexto = pesoTextField.text,
              !pesoTexto.isEmpty,
              let peso = Double(pesoTexto) else {
            mostrarAlerta(mensaje: "Debe ingresar el peso del animal")
            return
        }
        
        guard peso > 0 && peso < 200 else {
            mostrarAlerta(mensaje: "El peso debe ser un valor válido (entre 0 y 200 kg)")
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        registroAnimalData?.fechaNacimiento = dateFormatter.string(from: pickerDate.date)
        
        registroAnimalData?.peso = peso
        registroAnimalData?.sexo = segmentSexoAnimal.selectedSegmentIndex == 0 ? "Macho" : "Hembra"
        registroAnimalData?.imagen = imageViewAnimal.image
        
        if let siguienteVC = storyboard?.instantiateViewController(
            withIdentifier: "RegistroNacimientoAnimal3ViewController"
        ) as? RegistroNacimientoAnimal3ViewController {
            siguienteVC.registroAnimalData = registroAnimalData
            navigationController?.pushViewController(siguienteVC, animated: true)
        }
    }
    
    func mostrarAlerta(mensaje: String) {
        let alert = UIAlertController(title: "Atención", message: mensaje, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension RegistroNacimientoAnimal2ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imagenEditada = info[.editedImage] as? UIImage {
            imageViewAnimal.image = imagenEditada
        } else if let imagenOriginal = info[.originalImage] as? UIImage {
            imageViewAnimal.image = imagenOriginal
        }
        
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
