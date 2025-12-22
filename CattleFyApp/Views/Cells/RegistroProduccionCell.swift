//
//  RegistroProduccionCell.swift
//  CattleFyApp
//
//  Created by Andy Yahir Valdivia Centeno on 21/12/25.
//

import UIKit

class RegistroProduccionCell : UITableViewCell{
    
    @IBOutlet weak var tipoProduccionLabel: UILabel!
    
    @IBOutlet weak var fechaLabel: UILabel!
    
    @IBOutlet weak var loteLabel: UILabel!
    
    @IBOutlet weak var cantidadLabel: UILabel!
    
    override func awakeFromNib() {
            super.awakeFromNib()
        }
        
        func configure(with registro: RegistroProduccionDTO) {
            // Tipo de producción
            let tipo = registro.tipoProduccion ?? "Desconocido"
            tipoProduccionLabel.text = tipo.uppercased()
            tipoProduccionLabel.font = UIFont.boldSystemFont(ofSize: 18)
            
            // Fecha
            fechaLabel.text = formatearFecha(registro.fechaRegistro)
            fechaLabel.textColor = .secondaryLabel
            
            // Lote
            loteLabel.text = "Lote: \(registro.nombreLote ?? "N/A")"
            loteLabel.textColor = .secondaryLabel
            
            // Cantidad
            if let cantidad = registro.cantidad {
                cantidadLabel.text = formatearCantidad(cantidad)
                cantidadLabel.font = UIFont.boldSystemFont(ofSize: 24)
            }
                       
        }
        
        private func formatearFecha(_ fecha: Date?) -> String {
            guard let fecha = fecha else { return "Sin fecha" }
            
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            formatter.locale = Locale(identifier: "es_PE")
            
            let calendar = Calendar.current
            if calendar.isDateInToday(fecha) {
                return "Hoy"
            } else if calendar.isDateInYesterday(fecha) {
                return "Ayer"
            } else {
                return formatter.string(from: fecha)
            }
        }
        
        private func formatearCantidad(_ cantidad: Double) -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 2
            formatter.minimumFractionDigits = 0
            return formatter.string(from: cantidad as NSNumber) ?? "0"
        }
    
    
    
    
}
