//
//  TrasladoAnimalViewController.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/19/25.
//

import UIKit

class TrasladoAnimalViewController: UIViewController {

    @IBOutlet weak var buscadorQRTextField: UITextField!
    @IBOutlet weak var especieLabel: UILabel!
    @IBOutlet weak var loteNombreLabel: UILabel!
    @IBOutlet weak var codigoQRLabel: UILabel!
    
    var codigoQR: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
    @IBAction func escanearQRButton(_ sender: UIButton) {
    }
    
    @IBAction func buscarQRManualButton(_ sender: UIButton) {
    }
}
