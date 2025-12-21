//
//  LoginViewController.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/7/25.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var inicarButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func iniciarButtonTapped(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            mostrarAlerta(mensaje: "Por favor completa todos los campos")
            return
        }
        
        let request = LoginRequestDTO(email: email, contra: password)
        
        inicarButton.isEnabled = false
        
        AuthService.shared.login(request: request) { [weak self] result in
            DispatchQueue.main.async {
                self?.inicarButton.isEnabled = true
                
                switch result {
                case .success(let authResponse):
                    print("Login exitoso: \(authResponse.email)")
                    print("Token: \(authResponse.token)")
                    
                    UserDefaults.standard.set(authResponse.token, forKey: "authToken")
                    
                    self?.navegarAHome()
                    
                case .failure(let error):
                    self?.mostrarAlerta(mensaje: "Error: \(error.localizedDescription)")
                }
            }
        }
    }
    func navegarAHome() {
        print("Iniciando navegación a Home...")
        
        // Si usan el storyboard de FarmFlow dejen ese nombre si en caso esta en Main como el mio cambienlo
        // En el inicioVC Cambien por su controlador que quieran probar y ponganle su identificador
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let inicioVC = storyboard.instantiateViewController(

            withIdentifier: "OnboardingPaso1ViewController"
        ) as? OnboardingPaso1ViewController else {
            print("Error: No se pudo castear InicioViewController")
            mostrarAlerta(mensaje: "Error al cargar la pantalla principal")
            return
        }
        
        print("InicioViewController cargado correctamente desde FarmFlow")
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            print("Error: No se pudo obtener la ventana")
            return
        }
        
        print("Ventana obtenida")
        
        let navigationController = UINavigationController(rootViewController: inicioVC)
        navigationController.setNavigationBarHidden(true, animated: false)
        
        window.rootViewController = navigationController
        
        UIView.transition(with: window,
                         duration: 0.3,
                         options: .transitionCrossDissolve,
                         animations: nil,
                         completion: { _ in
            print("Navegación completada exitosamente")
        })
    }
}
