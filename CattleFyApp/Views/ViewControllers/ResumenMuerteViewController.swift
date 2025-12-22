//
//  ResumenMuerteViewController.swift
//  CattleFyApp
//
//  Created by Fernando on 17/12/25.
//

import UIKit

class ResumenMuerteViewController: UIViewController {

    
    @IBOutlet weak var codigoQR: UILabel!
    
    @IBOutlet weak var especieLabel: UILabel!
    
    @IBOutlet weak var nombreLote: UILabel!
    
    
    @IBOutlet weak var fechaHora: UILabel!
    
    
    @IBOutlet weak var causaMuerte: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    @IBAction func registrarMuerteButton(_ sender: UIButton) {
    }
}
