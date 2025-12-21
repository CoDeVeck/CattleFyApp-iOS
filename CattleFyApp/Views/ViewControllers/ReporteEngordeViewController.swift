//
//  ReporteEngordeViewController.swift
//  CattleFyApp
//
//  Created by Victor Narazas on 17/12/25.
//

import UIKit
import SwiftUI

class ReporteEngordeViewController: UIViewController {
    
    
    
    @IBOutlet weak var graficoContainerOne: UIView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpChart()
    }
    

    private func setUpChart(){
        
        //Definimos o llamamos el grafico creado
        let swiftIU = GraficoReporte1()
        
        
        let hostingController = UIHostingController(rootView: swiftIU)
        
        
        addChild(hostingController)
        
        
        let hostedView = hostingController.view!
        hostedView.translatesAutoresizingMaskIntoConstraints = false
        graficoContainerOne.addSubview(hostedView)
        
        NSLayoutConstraint.activate([
            hostedView.topAnchor.constraint(equalTo: graficoContainerOne.topAnchor),
                        hostedView.bottomAnchor.constraint(equalTo: graficoContainerOne.bottomAnchor),
                        hostedView.leadingAnchor.constraint(equalTo: graficoContainerOne.leadingAnchor),
                        hostedView.trailingAnchor.constraint(equalTo: graficoContainerOne.trailingAnchor)
        ])
        
        hostingController.didMove(toParent: self)
    }
   
}
