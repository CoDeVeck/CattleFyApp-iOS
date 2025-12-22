//
//  RegistroSanitarioMasivoPt3ViewController.swift
//  CattleFyApp
//
//  Created by Andy Yahir Valdivia Centeno on 11/12/25.
//

import UIKit

class RegistroSanitarioMasivoPt3ViewController: UIViewController {
    
    
    @IBOutlet weak var loteNombreLabel: UILabel!
    
    @IBOutlet weak var protocoloLabel: UILabel!
    
    @IBOutlet weak var nombreProductoLabel: UILabel!
    
    @IBOutlet weak var dosisLabel: UILabel!
    
    @IBOutlet weak var animalesLabel: UILabel!
    
    @IBOutlet weak var costoLabel: UILabel!
    
    @IBOutlet weak var fechaLabel: UILabel!
    
    @IBOutlet weak var totalLabel: UILabel!
    
    @IBOutlet weak var registroButton: UIButton!
    
    var registroData: RegistroSanitarioUIData!
    
    private let apiService = RegistroSanitarioService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mostrarResumen()
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    private func mostrarResumen() {
        loteNombreLabel.text = "Lote ID: \(registroData.idLote ?? 0)"
        protocoloLabel.text = registroData.protocoloTipo
        nombreProductoLabel.text = registroData.nombreProducto
        dosisLabel.text = "\(registroData.cantidadDosis ?? 0) ml"
        animalesLabel.text = "\(registroData.animalesTratados ?? 0)"
        costoLabel.text = "S/ \(registroData.costoPorDosis ?? 0)"
        
        // Costo Total
        let costoTotalDecimal = registroData.costoTotal ?? 0
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        let totalNumber = NSDecimalNumber(decimal: costoTotalDecimal)
        
        if let formattedTotal = formatter.string(from: totalNumber) {
            totalLabel.text = "S/ \(formattedTotal)"
        }
        
        
        // Fecha
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.locale = Locale(identifier: "es_PE")
        if let fecha = registroData.fechaAplicacion {
            fechaLabel.text = dateFormatter.string(from: fecha)
        } else {
            fechaLabel.text = "Sin fecha"
        }

    }
    
    @IBAction func registroButtonTapped(_ sender: Any) {
        registrarVacunacionMasiva()
    }
    
    private func registrarVacunacionMasiva() {
        guard let idLote = registroData.idLote else {
            mostrarAlerta(titulo: "Error", mensaje: "No se pudo obtener el ID del lote")
            return
        }
        guard let cantidadAnimales = registroData.animalesTratados else{
            mostrarAlerta(titulo: "Error", mensaje:"No se pudo obtener los animales tratados")
            return
        }
        
        let request = RegistroSanitarioRequest(
            qrLote: nil,
            idLote: idLote,
            qrAnimal: nil,
            tipoAplicacion: registroData.tipoAplicacion,
            protocoloTipo: registroData.protocoloTipo,
            nombreProducto: registroData.nombreProducto,
            costoPorDosis: registroData.costoPorDosis,
            cantidadDosis: registroData.cantidadDosis,
            animalesTratados: cantidadAnimales
        )
        
        // Mostrar loading
        let loadingAlert = UIAlertController(
            title: nil,
            message: "Registrando...",
            preferredStyle: .alert
        )
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .medium
        loadingIndicator.startAnimating()
        
        loadingAlert.view.addSubview(loadingIndicator)
        present(loadingAlert, animated: true)
        
        // Llamar al servicio
        apiService.crearRegistroSanitario(request: request) { [weak self] result in
            DispatchQueue.main.async {
                loadingAlert.dismiss(animated: true) {
                    switch result {
                    case .success(let response):
                        self?.mostrarExito(response: response)
                    case .failure(let error):
                        self?.mostrarAlerta(
                            titulo: "Error",
                            mensaje: "No se pudo crear el registro: \(error.localizedDescription)"
                        )
                    }
                }
            }
        }
    }
    
    private func mostrarExito(response: RegistroSanitarioResponse) {
        let alert = UIAlertController(
            title: "¡Éxito!",
            message: "Registro sanitario masivo creado exitosamente.\nID: \(response.sanitarioId ?? 0)",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default) { [weak self] _ in
            // Volver al inicio o a la pantalla principal
            self?.navigationController?.popToRootViewController(animated: true)
        })
        
        present(alert, animated: true)
    }

}
