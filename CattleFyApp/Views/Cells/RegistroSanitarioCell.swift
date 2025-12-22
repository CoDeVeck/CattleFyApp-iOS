//
//  RegistroSanitarioCell.swift
//  CattleFyApp
//
//  Created by Andy Yahir Valdivia Centeno on 21/12/25.
//
import UIKit
class RegistroSanitarioCell : UITableViewCell{
    
    @IBOutlet weak var productoLabel: UILabel!
    
    @IBOutlet weak var tipoAplicacionLabel: UILabel!
    
    @IBOutlet weak var dosisLabel: UILabel!
    
    @IBOutlet weak var costoLabel: UILabel!
    
    @IBOutlet weak var animalesLabel: UILabel!
    
    func configure(with registro: RegistroSanitarioResponse) {
            productoLabel.text = registro.nombreProducto ?? "Sin producto"
            tipoAplicacionLabel.text = registro.tipoAplicacion ?? "N/A"
            
            if let animales = registro.animalesTratados {
                animalesLabel.text = "\(animales) animales"
            }
            
            if let costo = registro.costoTotal {
                costoLabel.text = formatearMoneda(costo)
            }
            
            if let dosis = registro.cantidadDosis {
                dosisLabel.text = "\(dosis) dosis"
            }
        }
        
        private func formatearMoneda(_ valor: Decimal) -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = "PEN"
            return formatter.string(from: valor as NSNumber) ?? "S/ 0.00"
        }
}
