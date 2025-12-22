//
//  PesajeTableViewCell.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/22/25.
//

import Foundation
import UIKit

class PesajeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var fechaLabel: UILabel!
    @IBOutlet weak var pesoLabel: UILabel!
    @IBOutlet weak var dietaLabel: UILabel!
    @IBOutlet weak var gananciaLabel: UILabel!
    
    func configurar(con pesaje: AnimalHistPesaje) {
        fechaLabel.text = formatearFecha(pesaje.fecha)
        pesoLabel.text = String(format: "%.2f kg", pesaje.peso)
        dietaLabel.text = pesaje.dieta ?? "Sin dieta"
        
        if let ganancia = pesaje.gananciaPeso {
            gananciaLabel.text = String(format: "%+.2f kg", ganancia)
            gananciaLabel.textColor = ganancia >= 0 ? .systemGreen : .systemRed
        } else {
            gananciaLabel.text = "N/A"
            gananciaLabel.textColor = .label
        }
    }
    
    private func formatearFecha(_ fecha: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: fecha) {
            dateFormatter.dateFormat = "dd/MM/yyyy"
            return dateFormatter.string(from: date)
        }
        return fecha
    }
}
