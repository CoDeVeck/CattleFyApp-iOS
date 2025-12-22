//
//  LotesDisponiblesTableViewCell.swift
//  CattleFyApp
//
//  Created by Victor Narazas on 21/12/25.
//

import UIKit

protocol LotesDisponiblesCellDelegate: AnyObject {
    func didTapIniciarVenta(en lote: LoteDisponibleVentaResponse)
}

class LotesDisponiblesTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var labelNombreLote: UILabel!
    @IBOutlet weak var labelEstadoListo: UILabel!
    @IBOutlet weak var labelAnimalesVivos: UILabel!
    @IBOutlet weak var labelPesoPromedioKG: UILabel!
    @IBOutlet weak var labelPesoTotalKg: UILabel!
    @IBOutlet weak var labelCostoTotalAcumulado: UILabel!
    @IBOutlet weak var labelPrecioSugeridoPorKg: UILabel!
    @IBOutlet weak var labelEspecieNombre: UILabel!
    
    @IBOutlet weak var btnIniciarVenta: UIButton!
    
    weak var delegate: LotesDisponiblesCellDelegate?
    private var loteActual: LoteDisponibleVentaResponse?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configurarEstilo()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Estilo básico de la celda
    private func configurarEstilo() {
        selectionStyle = .none
        contentView.layer.cornerRadius = 12
        contentView.backgroundColor = .systemBackground
        
        labelNombreLote.font = UIFont.boldSystemFont(ofSize: 18)
        labelEstadoListo.layer.cornerRadius = 8
        labelEstadoListo.clipsToBounds = true
        labelEstadoListo.textAlignment = .center
        labelEstadoListo.font = UIFont.boldSystemFont(ofSize: 12)
    }
    
    @IBAction func btnIniciarVentaPressed(_ sender: UIButton) {
        guard let lote = loteActual else { return }
        delegate?.didTapIniciarVenta(en: lote)
    }
    
    func configurar(con lote: LoteDisponibleVentaResponse) {
        
        self.loteActual = lote
        labelNombreLote.text = lote.loteNombre
       
        
        labelEspecieNombre.text = "\(lote.especieNombre) - \(lote.categoriaManejoNombre)"
        
        labelEstadoListo.text = "  \(lote.tipoLote)  "
        switch lote.tipoLote {
        case "Engorde":
            labelEstadoListo.backgroundColor = .systemGreen
        case "Descarte":
            labelEstadoListo.backgroundColor = .systemRed
        case "Reproduccion":
            labelEstadoListo.backgroundColor = .systemBlue
        default:
            labelEstadoListo.backgroundColor = .systemGray
        }
        labelEstadoListo.textColor = .white
        
        
        labelAnimalesVivos.text = "\(lote.cantidadAnimalesVivos)"
        
        
        labelPesoPromedioKG.text = String(format: "%.2f kg", lote.pesoPromedioLote)
        
       
        labelPesoTotalKg.text = String(format: "%.2f kg", lote.sumaTotalPesos)
        
        
        let costoTotal = NSDecimalNumber(decimal: lote.costoTotalAcumulado).doubleValue
        labelCostoTotalAcumulado.text = String(format: "S/ %.2f", costoTotal)
        
        
        let precioSugerido = NSDecimalNumber(decimal: lote.precioSugeridoPorKgBase).doubleValue
        labelPrecioSugeridoPorKg.text = String(format: "S/ %.2f/kg", precioSugerido)
    }
    
    func marcarComoSeleccionada(_ seleccionada: Bool) {
        UIView.animate(withDuration: 0.3) {
            if seleccionada {
                self.contentView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
                self.contentView.layer.borderWidth = 2
                self.contentView.layer.borderColor = UIColor.systemBlue.cgColor
            } else {
                self.contentView.backgroundColor = .systemBackground
                self.contentView.layer.borderWidth = 0
            }
        }
    }
    
}
