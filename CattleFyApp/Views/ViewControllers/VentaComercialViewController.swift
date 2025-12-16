//
//  VentaComercialViewController.swift
//  CattleFyApp
//
//  Created by Victor  on 10/12/25.
//

import UIKit

class VentaComercialViewController: UIViewController {

    
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

