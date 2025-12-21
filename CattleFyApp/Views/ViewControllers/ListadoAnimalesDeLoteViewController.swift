//
//  ListadoAnimalesDeLoteViewController.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/7/25.
//

import UIKit

class ListadoAnimalesDeLoteViewController: UIViewController {

    
    @IBOutlet weak var buscadorCodigoQRAnimal: UISearchBar!
    
    @IBOutlet weak var tablaAnimales: UITableView!
    
    // Idnetifier de la celda: celdaAnimal
    // Al darle un tap gesture recognizer que rediriga a la vista DetalleAnimaViewController
    // Foto del animal, codigo QR, peso y estado (Vivo)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
    }

    @IBAction func agregarNuevoAnimalButton(_ sender: UIButton) {
            let storyboard = UIStoryboard(name: "RegistroAnimal", bundle: nil)
            let registroVC = storyboard.instantiateViewController(withIdentifier: "RegistroAnimalViewController")
            navigationController?.pushViewController(registroVC, animated: true)
        }
    
}
