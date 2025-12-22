//
//  CrearNuevoLoteViewController.swift
//  
//
//  Created by Andy Yahir Valdivia Centeno on 11/12/25.
//

import UIKit

class CrearNuevoLoteViewController: UIViewController {

    @IBOutlet weak var nombreTextField: UITextField!
    
    @IBOutlet weak var especiesPicker: UIPickerView!
    
    @IBOutlet weak var categoriaPicker: UIPickerView!
    
    @IBOutlet weak var capacidadTextField: UITextField!
    
    @IBOutlet weak var siguienteButton: UIButton!
    
    var idGranjaSeleccionada: Int = 1
    
    var especies: [EspecieResponse] = []
    var categorias: [CategoriaManejoResponse] = []

    var especieSeleccionada: EspecieResponse?
    var categoriaSeleccionada: CategoriaManejoResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        especiesPicker.delegate = self
            especiesPicker.dataSource = self

            categoriaPicker.delegate = self
            categoriaPicker.dataSource = self

            cargarEspecies()
    }

    func cargarEspecies() {
        EspecieService.shared.obtenerEspecies { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let lista):
                    self.especies = lista
                    self.especiesPicker.reloadAllComponents()

                    // Selección por defecto
                    if let primera = lista.first {
                        self.especieSeleccionada = primera
                        self.cargarCategorias(especieId: primera.especieId!)
                    }

                case .failure(let error):
                    print("Error cargando especies:", error.localizedDescription)
                }
            }
        }
    }
    
    func cargarCategorias(especieId: Int) {
        CategoriaManejoService.shared.obtenerCategorias(especieId: especieId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let lista):
                    self.categorias = lista
                    self.categoriaPicker.reloadAllComponents()

                    // Selección por defecto
                    self.categoriaSeleccionada = lista.first

                case .failure(let error):
                    print("Error cargando categorías:", error.localizedDescription)
                    self.categorias = []
                    self.categoriaPicker.reloadAllComponents()
                }
            }
        }
    }
    
    @IBAction func siguienteButtonTapped(_ sender: UIButton) {
        
        guard let nombre = nombreTextField.text, !nombre.isEmpty else {
                    mostrarAlerta(mensaje: "Ingresa el nombre del lote")
                    return
                }
                
                guard let capacidadStr = capacidadTextField.text,
                      let capacidad = Int(capacidadStr),
                      capacidad > 0 else {
                    mostrarAlerta(mensaje: "Ingresa una capacidad válida")
                    return
                }
                
                guard let especie = especieSeleccionada else {
                    mostrarAlerta(mensaje: "Selecciona una especie")
                    return
                }
                
                guard let categoria = categoriaSeleccionada else {
                    mostrarAlerta(mensaje: "Selecciona una categoría")
                    return
                }
                
                navegarAPaso2(
                    nombre: nombre,
                    especie: especie,
                    categoria: categoria,
                    capacidad: capacidad
                )
    }
    func navegarAPaso2(nombre: String, especie: EspecieResponse, categoria: CategoriaManejoResponse, capacidad: Int) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            guard let paso2VC = storyboard.instantiateViewController(withIdentifier: "CrearNuevoLotePt2ViewController") as? CrearNuevoLotePt2ViewController else {
                print("No se pudo cargar ConfirmarLoteViewController")
                return
            }
            
            paso2VC.nombre = nombre
            paso2VC.especie = especie
            paso2VC.categoria = categoria
            paso2VC.capacidadMax = capacidad
            paso2VC.idGranja = idGranjaSeleccionada
            
            navigationController?.pushViewController(paso2VC, animated: true)
        }
        
        func mostrarAlerta(mensaje: String) {
            let alert = UIAlertController(title: "Aviso", message: mensaje, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }}

extension CrearNuevoLoteViewController: UIPickerViewDataSource, UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == especiesPicker {
            return especies.count
        } else {
            return categorias.count
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == especiesPicker {
            return especies[row].nombre
        } else {
            return categorias[row].nombre
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        if pickerView == especiesPicker {
            let especie = especies[row]
            especieSeleccionada = especie

            cargarCategorias(especieId: especie.especieId!)

        } else if pickerView == categoriaPicker {
            categoriaSeleccionada = categorias[row]
        }
    }
}
