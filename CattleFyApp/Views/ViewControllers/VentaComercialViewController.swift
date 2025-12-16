//
//  VentaComercialViewController.swift
//  CattleFyApp
//
//  Created by Victor  on 10/12/25.
//

import UIKit

class VentaComercialViewController: UIViewController {

<<<<<<< HEAD
    
    @IBOutlet weak var containerView: UIView!
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()

      
    }
    
    @IBAction func switchCambiarViewController(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            MostrarViewController(id:"WC_B")
        case 1:
            MostrarViewController(id:"WC_A")
        default :
            break
        }
        
    }

    func MostrarViewController(id:String){
        let storyboard = UIStoryboard(name: "VentaComercial", bundle: nil)
            let nuevoVC = storyboard.instantiateViewController(withIdentifier: id)

           
            children.forEach { child in
                child.willMove(toParent: nil)
                child.view.removeFromSuperview()
                child.removeFromParent()
            }

            
            addChild(nuevoVC)
        
        nuevoVC.view.translatesAutoresizingMaskIntoConstraints = false
        nuevoVC.view.frame = containerView.bounds
        
        containerView.addSubview(nuevoVC.view)
        
        NSLayoutConstraint.activate([
            nuevoVC.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            nuevoVC.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            nuevoVC.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            nuevoVC.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        nuevoVC.didMove(toParent: self)
    }

}

=======
    override func viewDidLoad() {
        super.viewDidLoad()

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

}
>>>>>>> c57ccc11a6c3df26f8186cdb314b7c120edd3a90
