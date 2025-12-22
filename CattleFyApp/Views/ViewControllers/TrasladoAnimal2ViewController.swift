//
//  TrasladoAnimal2ViewController.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/19/25.
//

import UIKit

class TrasladoAnimal2ViewController: UIViewController {

    
    @IBOutlet weak var buscadorQRLoteTextField: UITextField!
    
    @IBOutlet weak var tablaLotesDestino: UITableView!
    // su celda tiene identifier llamado celdaLote
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // Funciona para el buscador de qr lote manualmente
    @IBAction func buscarButton(_ sender: UIButton) {
    }
    
    
    @IBAction func filtroTipoLoteTodos(_ sender: UIButton) {
    }
    
    
    @IBAction func filtroTipoLoteEngorde(_ sender: UIButton) {
    }
    
    
    @IBAction func filtroTipoLoteReproduccion(_ sender: UIButton) {
    }
    
    
    @IBAction func filtroTipoLoteEnfermeria(_ sender: UIButton) {
    }
    
    
    @IBAction func filtroTipoLoteDescarte(_ sender: UIButton) {
    }
}
