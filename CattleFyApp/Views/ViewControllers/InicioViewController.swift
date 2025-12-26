//
//  InicioViewController.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/7/25.
//

import UIKit

class InicioViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

<<<<<<< HEAD
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
=======
     
    }
    
    @IBAction func btnNavegarAVentaLotePressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "VentaComercial", bundle: nil)
           
           if let vc = storyboard.instantiateViewController(withIdentifier: "VentaComercialViewController") as? VentaComercialViewController {
               self.navigationController?.pushViewController(vc, animated: true)
           }
    }
>>>>>>> c5222b3 (Subindo ultimos cambios)

}
