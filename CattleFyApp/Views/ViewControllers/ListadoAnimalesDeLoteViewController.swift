//
//  ListadoAnimalesDeLoteViewController.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/7/25.
//

import UIKit

class ListadoAnimalesDeLoteViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        
    }

    @IBAction func agregarNuevoAnimalButton(_ sender: UIButton) {
            let storyboard = UIStoryboard(name: "RegistroAnimal", bundle: nil)
            let registroVC = storyboard.instantiateViewController(withIdentifier: "RegistroAnimalViewController")
            navigationController?.pushViewController(registroVC, animated: true)
        }
    
}
