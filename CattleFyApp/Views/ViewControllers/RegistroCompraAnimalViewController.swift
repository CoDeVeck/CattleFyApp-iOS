//
//  RegistroCompraAnimalViewController.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/19/25.
//

import UIKit

class RegistroCompraAnimalViewController: UIViewController {
    
    @IBOutlet weak var imageViewAnimal: UIImageView!
    @IBOutlet weak var especiePicker: UIPickerView!
    @IBOutlet weak var precioCompraTextField: UITextField!
    @IBOutlet weak var pesoTextField: UITextField!
    @IBOutlet weak var pickerFecha: UIDatePicker!
    
    var animalData = RegistroAnimalData()
    let especies = ["Vacuno", "Porcino", "Caprino", "Pavino", "Avícola"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        especiePicker.delegate = self
        especiePicker.dataSource = self
        
    }
    
    @IBAction func elegirFotoAnimalGaleriaButton(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    @IBAction func siguienteButton(_ sender: UIButton) {

        animalData.idEspecie = especiePicker.selectedRow(inComponent: 0) + 1
        animalData.precioCompra = Double(precioCompraTextField.text ?? "")
        animalData.peso = Double(pesoTextField.text ?? "")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        animalData.fechaNacimiento = formatter.string(from: pickerFecha.date)
        
        let storyboard = UIStoryboard(name: "RegistroAnimal", bundle: nil)
        if let siguienteVC = storyboard.instantiateViewController(withIdentifier: "RegistroCompraAnimal2ViewController") as? RegistroCompraAnimal2ViewController {
            siguienteVC.animalData = animalData
            navigationController?.pushViewController(siguienteVC, animated: true)
        }
    }
}

// MARK: - UIPickerView
extension RegistroCompraAnimalViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        especies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        especies[row]
    }
}

// MARK: - UIImagePickerController
extension RegistroCompraAnimalViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imagenSeleccionada = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            imageViewAnimal.image = imagenSeleccionada
            animalData.imagen = imagenSeleccionada
        }
        picker.dismiss(animated: true)
    }
}
