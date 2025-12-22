//
//  RegistroViewController.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/7/25.
//

import UIKit

class RegistroViewController: UIViewController {

    @IBOutlet weak var nombreTextField: UITextField!
    
    @IBOutlet weak var apellidoPaTextField: UITextField!
    
    @IBOutlet weak var apellidoMaTextField: UITextField!
    
    @IBOutlet weak var dniTextField: UITextField!
    
    @IBOutlet weak var correoTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var telefonoTextField: UITextField!
    
    @IBOutlet weak var generoPicker: UIPickerView!
    
    @IBOutlet weak var registrarButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func registarButtonTapped(_ sender: UIButton) {
        guard let nombre = nombreTextField.text, !nombre.isEmpty,
              let apellidoPA = apellidoPaTextField.text, !apellidoPA.isEmpty,
              let apellidoMA = apellidoMaTextField.text, !apellidoMA.isEmpty,
              let dni = dniTextField.text, !dni.isEmpty,
              let email = correoTextField.text, !email.isEmpty,
              let telefono = telefonoTextField.text, !telefono.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            mostrarAlerta(mensaje: "Por favor completa los campos obligatorios")
            return
        }
        
        let request = RegistroRequestDTO(
            nombres: nombre,
            apePat: apellidoPA,
            apeMat: apellidoMA,
            documento: dni,
            email: email,
            contra: password,
            telefono: telefono
        )
        
        registrarButton.isEnabled = false

        AuthService.shared.registrar(request: request) { [weak self] result in
            DispatchQueue.main.async {
                self?.registrarButton.isEnabled = true
                
                switch result {
                case .success(let authResponse):
                    print("Registro exitoso: \(authResponse.email)")
                    self?.mostrarAlerta(mensaje: "Usuario registrado exitosamente") {
                        self?.navigationController?.popViewController(animated: true)
                    }
                    
                case .failure(let error):
                    self?.mostrarAlerta(mensaje: "Error: \(error.localizedDescription)")
                }
            }
        }
    }
}
