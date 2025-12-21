//
//  DetalleAnimalViewController.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/7/25.
//

import UIKit

class DetalleAnimalViewController: UIViewController {
    
    var qrAnimal: String?
    private let animalesService = AnimalesService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let qr = qrAnimal {
            print("QR Animal recibido: \(qr)")
            cargarDetalleAnimal(qr: qr)
        }
    }
    
    private func cargarDetalleAnimal(qr: String) {
        // Aquí puedes llamar al servicio para obtener los detalles del animal
        animalesService.obtenerAnimalPorQR(qrAnimal: qr) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let animal):
                    // Configurar la vista con los datos del animal
                    print("Animal cargado: \(animal)")
                case .failure(let error):
                    print("Error al cargar detalle: \(error)")
                }
            }
        }
    }
}
