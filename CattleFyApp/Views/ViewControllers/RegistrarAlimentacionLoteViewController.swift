//
//  RegistrarAlimentacionLoteViewController.swift
//  
//
//  Created by Andy Yahir Valdivia Centeno on 11/12/25.
//

import UIKit

class RegistrarAlimentacionLoteViewController: UIViewController {
    
    @IBOutlet weak var lotesPicker: UIPickerView!
    
    @IBOutlet weak var fechaDatePicker: UIDatePicker!
    
    @IBOutlet weak var dietaTextField: UITextField!
    
    @IBOutlet weak var cantidadTextField: UITextField!
    
    @IBOutlet weak var costoTextField: UITextField!
    
    @IBOutlet weak var calculoLabel: UILabel!
    
    @IBOutlet weak var guardarButton: UIButton!
    
    var lotes: [LoteSimpleDTO] = []
    var loteSeleccionado: LoteSimpleDTO?
    var fechaActual = Date()
<<<<<<< HEAD
    
=======
    var lotePreseleccionado: LoteSimpleDTO?

>>>>>>> c5222b3 (Subindo ultimos cambios)
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarUI()
        cargarLotes()
        mostrarFechaActual()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func configurarUI() {
        lotesPicker.delegate = self
        lotesPicker.dataSource = self
        
        cantidadTextField.keyboardType = .decimalPad
        costoTextField.keyboardType = .decimalPad
        
        cantidadTextField.addTarget(self, action: #selector(calcularCostoTotal), for: .editingChanged)
        costoTextField.addTarget(self, action: #selector(calcularCostoTotal), for: .editingChanged)
        
        calculoLabel.text = "S/ 0.00"
    }
    
    // MARK: - Mostrar fecha actual
    func mostrarFechaActual() {
        let peruTimeZone = TimeZone(identifier: "America/Lima")!
        
        fechaDatePicker.timeZone = peruTimeZone
        fechaDatePicker.calendar = Calendar.current
        fechaDatePicker.calendar.timeZone = peruTimeZone
        
        fechaDatePicker.date = Date()
    }
    
    // MARK: - Cargar lotes
    func cargarLotes() {
<<<<<<< HEAD
        
        LoteService.shared.obtenerLotesSimples { [weak self] result in
            DispatchQueue.main.async {
=======
        LoteService.shared.obtenerLotesSimples { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
>>>>>>> c5222b3 (Subindo ultimos cambios)
                
                switch result {
                case .success(let lotes):
                    print("Lotes cargados: \(lotes.count)")
<<<<<<< HEAD
                    self?.lotes = lotes
                    self?.lotesPicker.reloadAllComponents()
                    
                    if let primero = lotes.first {
                        self?.loteSeleccionado = primero
=======
                    self.lotes = lotes
                    self.lotesPicker.reloadAllComponents()
                    
                    // 👇 AHORA SÍ FUNCIONA
                    if let lotePreseleccionado = self.lotePreseleccionado,
                       let index = lotes.firstIndex(where: { $0.loteId == lotePreseleccionado.loteId }) {
                        self.lotesPicker.selectRow(index, inComponent: 0, animated: false)
                        self.loteSeleccionado = lotes[index]
>>>>>>> c5222b3 (Subindo ultimos cambios)
                    }
                    
                case .failure(let error):
                    print("Error cargando lotes: \(error.localizedDescription)")
<<<<<<< HEAD
                    self?.mostrarAlerta(mensaje: "Error al cargar lotes: \(error.localizedDescription)")
=======
                    self.mostrarAlerta(mensaje: "Error al cargar lotes: \(error.localizedDescription)")
>>>>>>> c5222b3 (Subindo ultimos cambios)
                }
            }
        }
    }
    
    @objc func calcularCostoTotal() {
        guard let cantidadStr = cantidadTextField.text?.replacingOccurrences(of: ",", with: "."),
              let cantidad = Double(cantidadStr),
              let costoStr = costoTextField.text?.replacingOccurrences(of: ",", with: "."),
              let costo = Double(costoStr) else {
            calculoLabel.text = "S/ 0.00"
            return
        }
        
        let total = cantidad * costo
        calculoLabel.text = String(format: "S/ %.2f", total)
    }
    @IBAction func guardarButtonTapped(_ sender: UIButton) {
        print("Guardando registro de alimentación...")
        guard let lote = loteSeleccionado else {
            mostrarAlerta(mensaje: "Selecciona un lote")
            return
        }
        
        guard let tipoDieta = dietaTextField.text, !tipoDieta.isEmpty else {
            mostrarAlerta(mensaje: "Ingresa el tipo de dieta")
            return
        }
        
        guard let cantidadStr = cantidadTextField.text?.replacingOccurrences(of: ",", with: "."),
              let cantidad = Double(cantidadStr), cantidad > 0 else {
            mostrarAlerta(mensaje: "Ingresa una cantidad válida")
            return
        }
        
        guard let costoStr = costoTextField.text?.replacingOccurrences(of: ",", with: "."),
              let costo = Double(costoStr), costo > 0 else {
            mostrarAlerta(mensaje: "Ingresa un costo válido")
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone.current
        let fechaFormateada = formatter.string(from: fechaActual)
        
        let request = RegistroAlimentacionRequestDTO(
            loteId: lote.loteId,
            cantidadKg: cantidad,
            costoPorKg: costo,
            dietaTipo: tipoDieta
        )
        
        print("Request: idLote=\(lote.loteId), fecha=\(fechaFormateada), tipo=\(tipoDieta), cantidad=\(cantidad), costo=\(costo)")
        
        guardarButton.isEnabled = false
        guardarButton.setTitle("Guardando...", for: .normal)
        
        RegistroAlimentacionService.shared.registrarAlimentacion(request: request) { [weak self] result in
            DispatchQueue.main.async {
                self?.guardarButton.isEnabled = true
                self?.guardarButton.setTitle("Guardar", for: .normal)
                
                switch result {
                case .success(let response):
                    print("   Registro guardado exitosamente")
                    print("   ID: \(response.alimentacionId)")
                    print("   Costo Total: S/ \(response.costoTotal)")
                    
                    self?.mostrarExito(response: response)
                    
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                    
                    if (error as NSError).code == 401 {
                        self?.mostrarAlerta(mensaje: "Sesión expirada")
                    } else {
                        self?.mostrarAlerta(mensaje: "Error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func mostrarExito(response: RegistroAlimentacionResponse) {
        let alert = UIAlertController(
            title: "Registro Guardado",
            message: """
                Lote: \(loteSeleccionado?.nombre ?? "")
                Cantidad: \(response.cantidadKg) KG
                Costo Total: \(response.costoTotal)
                """,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            // Limpiar campos
            self.limpiarCampos()
            // O volver atrás
            // self.dismiss(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Limpiar campos
    func limpiarCampos() {
        dietaTextField.text = ""
        cantidadTextField.text = ""
        costoTextField.text = ""
        calculoLabel.text = "S/ 0.00"
        
        fechaActual = Date()
        mostrarFechaActual()
    }
}
extension RegistrarAlimentacionLoteViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return lotes.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard row < lotes.count else { return nil}
        return lotes[row].nombre
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard row < lotes.count else { return }
        loteSeleccionado = lotes[row]
    }

}

