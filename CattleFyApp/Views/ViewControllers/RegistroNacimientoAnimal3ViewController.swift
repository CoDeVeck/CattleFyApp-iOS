//
//  RegistroNacimientoAnimal3ViewController.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/19/25.
//

import UIKit

class RegistroNacimientoAnimal3ViewController: UIViewController {
    
    @IBOutlet weak var imagenAnimal: UIImageView!
    @IBOutlet weak var fechaLabel: UILabel!
    @IBOutlet weak var sexoAnimalLabel: UILabel!
    @IBOutlet weak var pesoKgLabel: UILabel!
    @IBOutlet weak var loteNombreLabel: UILabel!
    @IBOutlet weak var especieLabel: UILabel!
    
    var registroAnimalData: RegistroAnimalData?
    private let animalesService = AnimalesService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarVista()
        mostrarResumenDatos()
    }
    
    private func configurarVista() {
        // Configurar imagen con bordes redondeados
        imagenAnimal.layer.cornerRadius = 10
        imagenAnimal.clipsToBounds = true
        imagenAnimal.contentMode = .scaleAspectFill
    }
    
    private func mostrarResumenDatos() {
        guard let data = registroAnimalData else { return }
        
        // Mostrar imagen
        if let imagen = data.imagen {
            imagenAnimal.image = imagen
        } else {
            imagenAnimal.image = UIImage(systemName: "photo")
        }
        
        // Mostrar datos
        fechaLabel.text = data.fechaNacimiento
        sexoAnimalLabel.text = data.sexo
        
        if let peso = data.peso {
            pesoKgLabel.text = String(format: "%.2f kg", peso)
        } else {
            pesoKgLabel.text = "No especificado"
        }
        
        loteNombreLabel.text = data.nombreLote
        especieLabel.text = data.nombreEspecie
    }
    
    @IBAction func registrarNacimientoAnimal(_ sender: UIButton) {
        guard let data = registroAnimalData else {
            mostrarAlerta(mensaje: "Error: No hay datos para registrar")
            return
        }
        
        // Deshabilitar botón para evitar múltiples envíos
        sender.isEnabled = false
        
        // Mostrar indicador de carga
        let loadingIndicator = mostrarIndicadorCarga()
        
        // Crear el request con origen "Nacimiento"
        let animalRequest = AnimalRequest.nacimiento(
            codigoQrMadre: data.codigoQrMadre,
            fechaNacimiento: data.fechaNacimiento,
            sexo: data.sexo,
            peso: data.peso
        )
        
        // Llamar al servicio
        animalesService.registrarAnimal(
            animal: animalRequest,
            imagen: data.imagen
        ) { [weak self] result in
            DispatchQueue.main.async {
                // Ocultar indicador y rehabilitar botón
                loadingIndicator.removeFromSuperview()
                sender.isEnabled = true
                
                switch result {
                case .success(let response):
                    self?.registroExitoso(response: response)
                    
                case .failure(let error):
                    self?.mostrarAlerta(mensaje: "Error al registrar: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func registroExitoso(response: AnimalResponse) {
        let alert = UIAlertController(
            title: "¡Registro Exitoso!",
            message: "El animal ha sido registrado correctamente con código QR: \(response.codigoQr ?? "N/A")",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Ver Animales del Lote", style: .default) { [weak self] _ in
            self?.navegarAListadoAnimales()
        })
        
        present(alert, animated: true)
    }
    
    private func navegarAListadoAnimales() {
        guard let idLote = registroAnimalData?.idLote else { return }
        
        // Navegar al listado de animales del lote
        let storyboard = UIStoryboard(name: "FarmFlow", bundle: nil)
        if let listadoVC = storyboard.instantiateViewController(
            withIdentifier: "ListadoAnimalesDeLoteViewController"
        ) as? ListadoAnimalesDeLoteViewController {
            
            // Navegar limpiando el stack hasta el listado
            if let navigationController = navigationController {
                var viewControllers = navigationController.viewControllers
                // Remover las vistas de registro anteriores
                viewControllers.removeAll { vc in
                    vc is RegistroNacimientoAnimalViewController ||
                    vc is RegistroNacimientoAnimal2ViewController ||
                    vc is RegistroNacimientoAnimal3ViewController
                }
                viewControllers.append(listadoVC)
                navigationController.setViewControllers(viewControllers, animated: true)
            }
        }
    }
    
    private func mostrarIndicadorCarga() -> UIView {
        let containerView = UIView(frame: view.bounds)
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.center = containerView.center
        activityIndicator.startAnimating()
        
        containerView.addSubview(activityIndicator)
        view.addSubview(containerView)
        
        return containerView
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
