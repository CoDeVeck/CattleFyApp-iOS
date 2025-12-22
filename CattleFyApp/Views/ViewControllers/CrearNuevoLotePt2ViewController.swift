//
//  CrearNuevoLotePt2ViewController.swift
//  
//
//  Created by Andy Yahir Valdivia Centeno on 11/12/25.
//

import UIKit

class CrearNuevoLotePt2ViewController: UIViewController {
    
    @IBOutlet weak var nombreLote: UILabel!
    
    @IBOutlet weak var especieNombre: UILabel!
    
    @IBOutlet weak var categoriaNombre: UILabel!
    
    @IBOutlet weak var capacidadMaxima: UILabel!
    
    @IBOutlet weak var crearButton: UIButton!
    
        var nombre: String = ""
        var especie: EspecieResponse!
        var categoria: CategoriaManejoResponse!
        var capacidadMax: Int = 0
        var idGranja: Int = 0
        
        override func viewDidLoad() {
            super.viewDidLoad()
            mostrarResumen()
        }
        
        func mostrarResumen() {
            nombreLote.text = nombre
            especieNombre.text = especie.nombre
            categoriaNombre.text = categoria.nombre
            capacidadMaxima.text = "\(capacidadMax) animales"
        }
    
    
    @IBAction func crearButtonTapped(_ sender: Any) {
        print("🔘 Creando lote...")
        
        let loteRequest = LoteRequest(
            idGranja: idGranja,
            nombre: nombre,
            idEspecie: especie.especieId!,
            idCategoria: categoria.id,
            diasDesdeCreacion: 0,
            capacidadMax: capacidadMax
        )
        
        // Mostrar loading
        crearButton.isEnabled = false
        crearButton.setTitle("Creando...", for: .normal)
        
        LoteService.shared.crearLote(request: loteRequest) { [weak self] result in
            DispatchQueue.main.async {
                self?.crearButton.isEnabled = true
                self?.crearButton.setTitle("Crear Lote", for: .normal)
                
                switch result {
                case .success(let lote):
                    print("Lote creado exitosamente")
                    print("   ID: \(lote.idLote)")
                    print("   Nombre: \(lote.nombre)")
                    print("   Código QR: \(lote.codigoQr)")
                    
                    self?.mostrarExito(lote: lote)
                    
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
    
    func mostrarExito(lote: LoteResponse) {
            let alert = UIAlertController(
                title: "Lote Creado",
                message: """
                \(lote.nombre)
                Código QR: \(lote.codigoQr)
                Capacidad: \(lote.capacidadMax)
                """,
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Ver Lotes", style: .default) { _ in
                // Volver a la lista de lotes
                self.volverAListaLotes()
            })
            
            alert.addAction(UIAlertAction(title: "Crear Otro", style: .default) { _ in
                // Volver al paso 1
                self.navigationController?.popToRootViewController(animated: true)
            })
            
            present(alert, animated: true)
        }
        
        func volverAListaLotes() {
            // Navegar o pop a donde corresponda
            navigationController?.popToRootViewController(animated: true)
        }
}
