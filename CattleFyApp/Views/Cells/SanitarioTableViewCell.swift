//
//  SanitarioTableViewCell.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/22/25.
//

import Foundation
import UIKit

class SanitarioTableViewCell: UITableViewCell {
    
    @IBOutlet weak var fechaLabel: UILabel!
    @IBOutlet weak var nombreTratLabel: UILabel!
    @IBOutlet weak var tipoProtocoloLabel: UILabel!
    @IBOutlet weak var dosisLabel: UILabel!
    @IBOutlet weak var precioLabel: UILabel!
    
    func configurar(con sanitario: AnimalHistSanitario) {
        fechaLabel.text = formatearFecha(sanitario.fecha)
        nombreTratLabel.text = sanitario.nombreTrat
        tipoProtocoloLabel.text = sanitario.tipoProtocolo
        dosisLabel.text = String(format: "%.2f ml", sanitario.dosis)
        precioLabel.text = String(format: "S/ %.2f", sanitario.precio)
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
