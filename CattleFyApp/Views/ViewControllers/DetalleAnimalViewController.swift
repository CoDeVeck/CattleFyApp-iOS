//
//  DetalleAnimalViewController.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/7/25.
//

import UIKit

class DetalleAnimalViewController: UIViewController {
    
    var codigoQR: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let qr = codigoQR {
            print("📍 Detalle del animal con QR: \(qr)")
            // Aquí cargas los datos del animal
        }
    }

}
