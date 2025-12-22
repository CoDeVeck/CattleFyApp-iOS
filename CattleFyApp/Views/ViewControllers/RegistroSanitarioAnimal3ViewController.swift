//
//  RegistroSanitarioAnimal3ViewController.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/19/25.
//

import UIKit

class RegistroSanitarioAnimal3ViewController: UIViewController {
    
    @IBOutlet weak var codigoQRLabel: UILabel!
    @IBOutlet weak var tipoProtocoloLabel: UILabel!
    @IBOutlet weak var nombreProductoLabel: UILabel!
    @IBOutlet weak var dosisLabel: UILabel!
    @IBOutlet weak var costoUnitarioLabel: UILabel!
    @IBOutlet weak var fechaAplicacionLabel: UILabel!
    
    private let dataModel = RegistroSanitarioData.shared
    private let registroService = RegistroSanitarioService()
    private var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarVista()
        mostrarResumen()
    }
    
    private func configurarVista() {
        title = "Resumen"
        
        // Configurar activity indicator
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    private func mostrarResumen() {
        // Mostrar datos del paso 1
        codigoQRLabel.text = dataModel.codigoQR ?? "-"
        
        // Mostrar datos del paso 2
        tipoProtocoloLabel.text = dataModel.tipoProtocolo ?? "-"
        nombreProductoLabel.text = dataModel.nombreProducto ?? "-"
        
        if let dosis = dataModel.dosisAplicada {
            dosisLabel.text = "\(dosis) ml"
        } else {
            dosisLabel.text = "-"
        }
        
        if let costo = dataModel.costoUnitario {
            costoUnitarioLabel.text = "S/ \(String(format: "%.2f", NSDecimalNumber(decimal: costo).doubleValue))"
        } else {
            costoUnitarioLabel.text = "-"
        }
        
        if let fecha = dataModel.fechaAplicacion {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy HH:mm"
            formatter.locale = Locale(identifier: "es_PE")
            fechaAplicacionLabel.text = formatter.string(from: fecha)
        } else {
            fechaAplicacionLabel.text = "-"
        }
    }
    
    @IBAction func registrarButton(_ sender: UIButton) {
        // Validar que todos los datos estén completos
        guard dataModel.isValidoParaPaso3() else {
            mostrarError("Faltan datos por completar")
            return
        }
        
        // Confirmar registro
        confirmarRegistro()
    }
    
    private func confirmarRegistro() {
        let alert = UIAlertController(
            title: "Confirmar Registro",
            message: "¿Está seguro que desea registrar esta aplicación sanitaria?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Confirmar", style: .default) { [weak self] _ in
            self?.enviarRegistro()
        })
        
        present(alert, animated: true)
    }
    
    private func enviarRegistro() {
        mostrarLoading(true)
        
        // Crear request desde el modelo
        let request = dataModel.toRequest()
        
        // Agregar fecha formateada
        if let fecha = dataModel.fechaAplicacion {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            // Nota: Asegúrate de que tu backend acepte este formato o ajusta según necesites
        }
        
        // Consumir servicio
        registroService.crearRegistroSanitario(request: request) { [weak self] result in
            DispatchQueue.main.async {
                self?.mostrarLoading(false)
                
                switch result {
                case .success(let response):
                    self?.mostrarExito(response)
                    
                case .failure(let error):
                    self?.mostrarError("Error al registrar: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func mostrarExito(_ response: RegistroSanitarioResponse) {
        let alert = UIAlertController(
            title: "✓ Registro Exitoso",
            message: "El registro sanitario ha sido creado correctamente",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Ver Detalle", style: .default) { [weak self] _ in
            self?.navegarADetalle()
        })
        
        present(alert, animated: true)
    }
    
    private func navegarADetalle() {
        // Buscar el storyboard FarmFlow
        let farmFlowStoryboard = UIStoryboard(name: "FarmFlow", bundle: nil)
        
        // Instanciar DetalleAnimalViewController
        if let detalleVC = farmFlowStoryboard.instantiateViewController(
            withIdentifier: "DetalleAnimalViewController"
        ) as? DetalleAnimalViewController {
            

            detalleVC.codigoQR = dataModel.codigoQR
            
            // Navegar
            if let navigationController = self.navigationController {
                navigationController.pushViewController(detalleVC, animated: true)

            } else {
                // Si no hay navigation controller, presentar modalmente
                detalleVC.modalPresentationStyle = .fullScreen
                present(detalleVC, animated: true)
            }
        } else {
            // Fallback: volver al inicio
            navigationController?.popToRootViewController(animated: true)
        }
        
        dataModel.reset()
    }
        
    private func mostrarLoading(_ mostrar: Bool) {
        if mostrar {
            view.isUserInteractionEnabled = false
            activityIndicator.startAnimating()
        } else {
            view.isUserInteractionEnabled = true
            activityIndicator.stopAnimating()
        }
    }
    
    private func mostrarError(_ mensaje: String) {
        let alert = UIAlertController(
            title: "Error",
            message: mensaje,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Extension para formatear decimales
extension Decimal {
    var doubleValue: Double {
        return NSDecimalNumber(decimal: self).doubleValue
    }
}
