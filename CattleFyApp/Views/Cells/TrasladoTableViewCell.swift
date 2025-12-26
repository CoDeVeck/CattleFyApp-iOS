//
//  TrasladoTableViewCell.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/22/25.
//

import Foundation
import UIKit

class TrasladoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var fechaLabel: UILabel!
    @IBOutlet weak var origenLabel: UILabel!
    @IBOutlet weak var destinoLabel: UILabel!
    @IBOutlet weak var motivoLabel: UILabel!
    
    func configurar(con traslado: AnimalHistTraslado) {
        fechaLabel.text = traslado.especie
        origenLabel.text = "Origen: \(traslado.loteOrigen)"
        destinoLabel.text = "Destino: \(traslado.loteTraslado)"
        motivoLabel.text = traslado.motivo ?? "Sin motivo"
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
