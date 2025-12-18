//
//  RegistroAlimentacionCell.swift
//  CattleFyApp
//
//  Created by Andy Yahir Valdivia Centeno on 17/12/25.
//
import UIKit

class RegistroAlimentacionCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var fechaLabel: UILabel!
    
    @IBOutlet weak var dietaLabel: UILabel!
    
    @IBOutlet weak var cantidadLabel: UILabel!
    
    @IBOutlet weak var costoLabel: UILabel!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        selectionStyle = .none
    }
    
    // MARK: - Configuration
    func configurar(con registro: RegistrarAlimentacionHistorialDTO) {
        // Fecha
        fechaLabel.text = formatearFecha(registro.fecha)
        
        // Dieta
        dietaLabel.text = registro.dieta ?? "Sin dieta"
        
        // Cantidad
        if let cantidad = registro.cantidadKg {
            cantidadLabel.text = "\(cantidad) kg"
        } else {
            cantidadLabel.text = "0 kg"
        }
        
        // Costo
        if let costo = registro.costoTotal {
            costoLabel.text = "S/ \(formatearPrecio(costo))"
        } else {
            costoLabel.text = "S/ 0.00"
        }
    }
    
    private func formatearFecha(_ fechaString: String?) -> String {
        guard let fechaString = fechaString else { return "" }
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd MMM yyyy, hh:mm a"
        outputFormatter.locale = Locale(identifier: "es_ES")
        
        if let date = inputFormatter.date(from: fechaString) {
            return outputFormatter.string(from: date)
        }
        return fechaString
    }
    
    private func formatearPrecio(_ precio: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: precio as NSDecimalNumber) ?? "0.00"
    }
}
