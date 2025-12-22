//
//  RegistroCompraAnimal2ViewController.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/19/25.
//

import UIKit

class RegistroCompraAnimal2ViewController: UIViewController {
    
    @IBOutlet weak var pickerLotes: UIPickerView!
    @IBOutlet weak var proveedorTextField: UITextField!
    
    var animalData: RegistroAnimalData?
    
    private var lotes: [LoteSimpleDTO] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerLotes.delegate = self
        pickerLotes.dataSource = self
        
        cargarLotes()
    }
    
    // MARK: - Cargar lotes desde el servicio
    private func cargarLotes() {
        
        LoteService.shared.obtenerLotesSimples { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let lotesObtenidos):
                    self?.lotes = lotesObtenidos
                    self?.pickerLotes.reloadAllComponents()
                    
                    if !lotesObtenidos.isEmpty {
                        self?.pickerLotes.selectRow(0, inComponent: 0, animated: false)
                    }
                    
                case .failure(let error):
                    self?.mostrarError(mensaje: "Error al cargar lotes: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Mostrar error
    private func mostrarError(mensaje: String) {
        let alert = UIAlertController(title: "Error", message: mensaje, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @IBAction func continuarButton(_ sender: UIButton) {
        guard !lotes.isEmpty else {
            mostrarError(mensaje: "No hay lotes disponibles")
            return
        }
        
        guard let proveedor = proveedorTextField.text, !proveedor.isEmpty else {
            mostrarError(mensaje: "Debe llenar el campo proveedor")
            return
        }
        
        let indiceSeleccionado = pickerLotes.selectedRow(inComponent: 0)
        let loteSeleccionado = lotes[indiceSeleccionado]
        
        animalData?.idLote = loteSeleccionado.loteId
        animalData?.nombreLote = loteSeleccionado.nombre
        animalData?.proveedor = proveedor
        
        let storyboard = UIStoryboard(name: "RegistroAnimal", bundle: nil)
        if let confirmacionVC = storyboard.instantiateViewController(withIdentifier: "RegistroCompraAnimal3ViewController") as? RegistroCompraAnimal3ViewController {
            confirmacionVC.animalData = animalData
            navigationController?.pushViewController(confirmacionVC, animated: true)
        }
    }
}

// MARK: - UIPickerView DataSource & Delegate
extension RegistroCompraAnimal2ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return lotes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return lotes[row].nombre
    }
}
