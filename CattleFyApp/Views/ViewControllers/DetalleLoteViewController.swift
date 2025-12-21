//
//  DetalleLoteViewController.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/7/25.
//

import UIKit

class DetalleLoteViewController: UIViewController {
    
    @IBOutlet weak var especieLabel: UILabel!
    
    @IBOutlet weak var categoriaLabel: UILabel!
    
    @IBOutlet weak var cicloLabel: UILabel!
    
    @IBOutlet weak var fechaLabel: UILabel!
    
    @IBOutlet weak var estadoLabel: UILabel!
    
    @IBOutlet weak var ubicacionLabel: UILabel!
    
    @IBOutlet weak var animalesVivosLabel: UILabel!
    
    @IBOutlet weak var ventasLabel: UILabel!
    
    @IBOutlet weak var pesoLabel: UILabel!
    
    @IBOutlet weak var costoLabel: UILabel!
    
    @IBOutlet weak var alimentacionButton: UIButton!
    
    @IBOutlet weak var ProduccionButton: UIButton!
    
    @IBOutlet weak var sanitarioButton: UIButton!
    
    var loteId: Int!
    private var loteDetalle: LoteDetalleResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alimentacionButton?.isEnabled = true
        alimentacionButton?.isUserInteractionEnabled = true
        self.title = "Detalle del lote"
        navigationItem.backButtonTitle = "Volver"
        ProduccionButton?.isEnabled = true
        ProduccionButton?.isUserInteractionEnabled = true
        
        sanitarioButton?.isEnabled = true
        sanitarioButton?.isUserInteractionEnabled = true
        cargarDetalleLote()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func cargarDetalleLote() {
        guard loteId != nil else {
            mostrarAlerta(titulo: "Error", mensaje: "ID de lote no válido")
            return
        }
        
        
        LoteService.shared.obtenerDetalleLote(loteId: loteId) { [weak self] result in
            DispatchQueue.main.async {
                
                
                switch result {
                case .success(let response):
                    if response.valor, let detalle = response.data {
                        self?.loteDetalle = detalle
                        self?.configurarVista(con: detalle)
                        print("✅ Detalle del lote cargado")
                    } else {
                        self?.mostrarAlerta(titulo: "Aviso", mensaje: response.mensaje)
                    }
                    
                case .failure(let error):
                    print("❌ Error: \(error.localizedDescription)")
                    self?.mostrarAlerta(titulo: "Error", mensaje: "No se pudo cargar el detalle del lote")
                }
            }
        }
    }
    
    private func configurarVista(con detalle: LoteDetalleResponse) {
        // Información básica
        especieLabel?.text = detalle.especieNombre ?? "N/A"
        cicloLabel?.text = detalle.tipoLote ?? "N/A"
        ubicacionLabel?.text = detalle.granjaNombre ?? "N/A"
        estadoLabel?.text = detalle.estado ?? "N/A"
        
        // Fecha
        if let fecha = detalle.fechaInicio {
            fechaLabel?.text = formatearFecha(fecha)
        } else {
            fechaLabel?.text = "N/A"
        }
        
        // Métricas clave
        if let peso = detalle.pesoPromedio {
            pesoLabel?.text = "\(Int(peso)) kg"
        } else {
            pesoLabel?.text = "N/A"
        }
        
        animalesVivosLabel?.text = "\(detalle.cantidadActual ?? 0)"
        
        
        if let precio = detalle.precioEstimado {
            costoLabel?.text = formatearPrecio(precio)
        } else {
            costoLabel?.text = "N/A"
        }
        func formatearFecha(_ fecha: String) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            
            if let date = formatter.date(from: fecha) {
                formatter.dateFormat = "dd/MM/yyyy"
                return formatter.string(from: date)
            }
            
            formatter.dateFormat = "yyyy-MM-dd"
            if let date = formatter.date(from: fecha) {
                formatter.dateFormat = "dd/MM/yyyy"
                return formatter.string(from: date)
            }
            
            return fecha
        }
        
        func formatearPrecio(_ precio: Double) -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = "USD"
            formatter.maximumFractionDigits = 0
            return formatter.string(from: NSNumber(value: precio)) ?? "$0"
        }
        
        func mostrarAlerta(titulo: String, mensaje: String) {
            let alert = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
        
    }
    @IBAction func alimentacion(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let historialVC = storyboard.instantiateViewController(
            withIdentifier: "HistorialAlimentacionViewController"
        ) as? HistorialAlimentacionViewController else {
            print("Error: No se pudo instanciar HistorialAlimentacionViewController")
            return
        }
        
        historialVC.loteId = loteId
        
        navigationController?.pushViewController(historialVC, animated: true)
        print("Lote recibido: \(loteId ?? -1)")

    }
    
    @IBAction func produccionButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let historialVC = storyboard.instantiateViewController(
            withIdentifier: "HistorialProduccionViewController"
        ) as? HistorialProduccionViewController else {
            print(" Error: No se pudo instanciar HistorialProduccionViewController")
            return
        }
        
        historialVC.loteId = loteId
        
        navigationController?.pushViewController(historialVC, animated: true)
        print("Lote recibido: \(loteId ?? -1)")
    }
    
    @IBAction func sanitarioButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let historialVC = storyboard.instantiateViewController(
            withIdentifier: "HistorialSanitarioViewController"
        ) as? HistorialSanitarioViewController else {
            print("Error: No se pudo instanciar HistorialSanitarioViewController")
            return
        }
        
        historialVC.loteId = loteId
        
        navigationController?.pushViewController(historialVC, animated: true)
        print("Lote recibido: \(loteId ?? -1)")
    }
    
    
}
