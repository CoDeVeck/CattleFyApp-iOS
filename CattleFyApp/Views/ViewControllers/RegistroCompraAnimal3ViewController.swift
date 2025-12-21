//
//  RegistroCompraAnimal3ViewController.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/19/25.
//

import UIKit

class RegistroCompraAnimal3ViewController: UIViewController {
    
    @IBOutlet weak var imageViewAnimal: UIImageView!
    @IBOutlet weak var especieLabel: UILabel!
    @IBOutlet weak var pesoKgLabel: UILabel!
    @IBOutlet weak var precioLabelCompra: UILabel!
    @IBOutlet weak var fechaLabel: UILabel!
    @IBOutlet weak var loteNombreLabel: UILabel!
    
    var animalData: RegistroAnimalData?
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configurar indicador de carga
        activityIndicator.center = view.center
        activityIndicator.color = .systemBlue
        view.addSubview(activityIndicator)
        
        // Mostrar los datos de confirmación
        mostrarDatosConfirmacion()
    }
    
    private func mostrarDatosConfirmacion() {
        guard let data = animalData else { return }
        
        especieLabel.text = data.nombreEspecie
        pesoKgLabel.text = "\(data.peso ?? 0) kg"
        precioLabelCompra.text = "S/ \(data.precioCompra ?? 0)"
        fechaLabel.text = data.fechaNacimiento
        loteNombreLabel.text = data.nombreLote
        
        if let imagen = data.imagen {
            imageViewAnimal.image = imagen
        }
    }
    
    @IBAction func registrarAnimalButton(_ sender: UIButton) {
        guard let data = animalData else {
            mostrarError(mensaje: "No hay datos del animal")
            return
        }
        
        // Validaciones básicas
        guard data.idLote > 0 else {
            mostrarError(mensaje: "Debe seleccionar un lote")
            return
        }
        
        // Convertir RegistroAnimalData a AnimalRequest
        let animalRequest = AnimalRequest(
            origen: data.origen,
            idLote: data.idLote,
            codigoQrMadre: data.codigoQrMadre,
            idEspecie: data.idEspecie,
            fechaNacimiento: data.fechaNacimiento,
            sexo: data.sexo,
            peso: data.peso,
            precioCompra: data.precioCompra
        )
        
        // Deshabilitar botón y mostrar loading
        sender.isEnabled = false
        activityIndicator.startAnimating()
        
        // Registrar el animal
        AnimalService.shared.registrarAnimal(
            animal: animalRequest,
            imagen: data.imagen
        ) { [weak self] result in
            DispatchQueue.main.async {
                sender.isEnabled = true
                self?.activityIndicator.stopAnimating()
                
                switch result {
                case .success(let response):
                    let mensaje = response.mensaje ?? "Animal registrado con código: \(response.codigoQr ?? "")"
                    self?.mostrarExito(mensaje: mensaje)
                    
                case .failure(let error):
                    self?.mostrarError(mensaje: error.localizedDescription)
                }
            }
        }
    }
    
    private func mostrarExito(mensaje: String) {
        let alert = UIAlertController(
            title: "Éxito",
            message: mensaje,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navegarAListadoAnimales()
        })
        present(alert, animated: true)
    }
    
    private func mostrarError(mensaje: String) {
        let alert = UIAlertController(
            title: "Error",
            message: mensaje,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func navegarAListadoAnimales() {
        // Navegar al listado de animales del lote
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let listadoVC = storyboard.instantiateViewController(
            withIdentifier: "ListadoAnimalesDeLoteViewController"
        ) as? ListadoAnimalesDeLoteViewController {
       
            // Navegar limpiando el stack hasta el listado
            if let navigationController = navigationController {
                var viewControllers = navigationController.viewControllers
                // Remover las vistas de registro anteriores
                viewControllers.removeAll { vc in
                    vc is RegistroCompraAnimalViewController ||
                    vc is RegistroCompraAnimal2ViewController ||
                    vc is RegistroCompraAnimal3ViewController
                }
                viewControllers.append(listadoVC)
                navigationController.setViewControllers(viewControllers, animated: true)
            }
        }
    }
}
