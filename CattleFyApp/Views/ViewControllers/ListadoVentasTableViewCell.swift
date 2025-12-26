//
//  ListadoVentasTableViewCell.swift
//  CattleFyApp
//
//  Created by Victor Manuel on 25/12/25.
//

import UIKit

class ListadoVentasTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelEspecieNombre: UILabel!
    
    @IBOutlet weak var labelLoteNombre: UILabel!
    
    @IBOutlet weak var labelFechaVenta: UILabel!
    
    @IBOutlet weak var labelCategoriaManejoNombre: UILabel!
    
    @IBOutlet weak var labelCantidadAnimalesVivos: UILabel!
    
    @IBOutlet weak var labelCostoTotalVenta: UILabel!
    
    @IBOutlet weak var btnDetalleVenta: UIButton!
    
    
    
    
    // MARK: - Properties
    var onDetallePressed: ((Int) -> Void)?
    private var ventaId: Int?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configurarEstilos()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Configuration
    private func configurarEstilos() {
        contentView.backgroundColor = .systemBackground
        

        labelEspecieNombre.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        labelEspecieNombre.textColor = .label
        

        labelLoteNombre.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        labelLoteNombre.textColor = .secondaryLabel
        

        labelCategoriaManejoNombre.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        labelCategoriaManejoNombre.textColor = .systemGray
        labelCategoriaManejoNombre.numberOfLines = 1
        

        labelFechaVenta.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        labelFechaVenta.textColor = .systemGray2
        

        labelCantidadAnimalesVivos.font = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .semibold)
        labelCantidadAnimalesVivos.textColor = .systemBlue
        

        labelCostoTotalVenta.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .bold)
        labelCostoTotalVenta.textColor = .systemGreen
        

        btnDetalleVenta.setTitle("Ver Detalle", for: .normal)
        btnDetalleVenta.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        btnDetalleVenta.setTitleColor(.systemBlue, for: .normal)
        btnDetalleVenta.layer.cornerRadius = 8
        btnDetalleVenta.layer.borderWidth = 1
        btnDetalleVenta.layer.borderColor = UIColor.systemBlue.cgColor
        btnDetalleVenta.backgroundColor = .clear
        

        separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func configurar(con venta: VentaListadoResponse) {
        // Guardar el ID de la venta
        self.ventaId = venta.ventaId
        
        // Especie
        labelEspecieNombre.text = venta.especieNombre
        
        // Lote
        labelLoteNombre.text = venta.loteNombre
        
        // Categoría con badge de tipo de venta
        let tipoVentaBadge = obtenerBadgeTipoVenta(venta.tipoVenta)
        labelCategoriaManejoNombre.text = "\(venta.categoriaManejoNombre) • \(tipoVentaBadge)"
        
        // Fecha formateada
        labelFechaVenta.text = formatearFecha(venta.fechaVenta)
        
        // Cantidad de animales con ícono
        labelCantidadAnimalesVivos.text = "\(venta.cantidadAnimalesVivos) animales"
        
        // Costo total formateado
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "PEN"
        formatter.maximumFractionDigits = 2
        
        if let precio = formatter.string(from: venta.costoTotalVenta as NSDecimalNumber) {
            labelCostoTotalVenta.text = precio
        } else {
            labelCostoTotalVenta.text = "S/ \(venta.costoTotalVenta)"
        }
        
        // Color del costo según cumplimiento de objetivo
        labelCostoTotalVenta.textColor = venta.cumplioObjetivo ? .systemGreen : .systemOrange
    }
    
    // MARK: - Helper Methods
    private func formatearFecha(_ fecha: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_PE")
        return formatter.string(from: fecha)
    }
    
    private func obtenerBadgeTipoVenta(_ tipo: String) -> String {
        switch tipo.lowercased() {
        case "engorde":
            return "Engorde"
        case "descarte":
            return "Descarte"
        case "reproduccion", "reproducción":
            return "Reproducción"
        default:
            return tipo
        }
    }
    
    
    @IBAction func btnMostrarDetalleVentaPressed(_ sender: UIButton) {
        guard let ventaId = ventaId else {
            print("No hay ventaId disponible")
            return
        }
        onDetallePressed?(ventaId)
    }
}
