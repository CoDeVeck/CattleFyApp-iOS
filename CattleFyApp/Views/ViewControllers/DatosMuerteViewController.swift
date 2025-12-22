//
//  DatosMuerteViewController.swift
//  CattleFyApp
//
//  Created by Fernando on 16/12/25.
//

import UIKit

class DatosMuerteViewController: UIViewController {

    //Agregar este dato a al modelo DATA
    @IBOutlet weak var pickerDateTime: UIDatePicker!
    
    @IBOutlet weak var causaMuerteLabel: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    @IBAction func continuarButton(_ sender: Any) {
    }
    

}
