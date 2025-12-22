//
//  DetalleAplicacionesTableViewCell.swift
//  CattleFyApp
//
//  Created by Victor Narazas on 20/12/25.
//

import UIKit

class DetalleAplicacionesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imagenSegunAplicacion: UIImageView!
    
    @IBOutlet weak var labelNombreProducto: UILabel!
    
    @IBOutlet weak var labelLoteAnimal: UILabel!
    
    @IBOutlet weak var labelCostoPorDosis: UILabel!
    
    @IBOutlet weak var labelFechaAplicacion: UILabel!
    
    @IBOutlet weak var contenedorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setupUI() {
        // Configurar celda
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // Configurar container con sombra
        contenedorView.backgroundColor = .systemBackground
        contenedorView.layer.cornerRadius = 12
        contenedorView.layer.shadowColor = UIColor.black.cgColor
        contenedorView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contenedorView.layer.shadowRadius = 4
        contenedorView.layer.shadowOpacity = 0.1
        contenedorView.layer.masksToBounds = false
        
        // Configurar icono con fondo circular
        imagenSegunAplicacion.layer.cornerRadius = 20 // Para 40x40
        imagenSegunAplicacion.contentMode = .center
        imagenSegunAplicacion.clipsToBounds = true
        imagenSegunAplicacion.tintColor = .white
        
        // Configurar labels
        labelNombreProducto.font = .systemFont(ofSize: 16, weight: .semibold)
        labelNombreProducto.textColor = .label
        labelNombreProducto.numberOfLines = 2
        
        labelLoteAnimal.font = .systemFont(ofSize: 13, weight: .regular)
        labelLoteAnimal.textColor = .secondaryLabel
        labelLoteAnimal.numberOfLines = 1
        
        labelCostoPorDosis.font = .systemFont(ofSize: 15, weight: .bold)
        labelCostoPorDosis.textColor = .systemGreen
        labelCostoPorDosis.textAlignment = .right
        
        labelFechaAplicacion.font = .systemFont(ofSize: 12, weight: .regular)
        labelFechaAplicacion.textColor = .tertiaryLabel
        labelFechaAplicacion.textAlignment = .right
    }
    
    func configure(nombreProducto: String, loteAnimal: String, costo: String, fecha: String, icono: String, colorIcono: UIColor) {
        labelNombreProducto.text = nombreProducto
        labelLoteAnimal.text = loteAnimal
        labelCostoPorDosis.text = costo
        labelFechaAplicacion.text = fecha
        
        
        let iconImage = UIImage(systemName: icono)?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        )
        imagenSegunAplicacion.image = iconImage
        imagenSegunAplicacion.backgroundColor = colorIcono
        imagenSegunAplicacion.tintColor = .white
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        labelNombreProducto.text = nil
        labelLoteAnimal.text = nil
        labelCostoPorDosis.text = nil
        labelFechaAplicacion.text = nil
        imagenSegunAplicacion.image = nil
        imagenSegunAplicacion.backgroundColor = .systemBlue
        imagenSegunAplicacion.tintColor = .white
    }
}
