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
    
    private func setupUI(){
        

        imagenSegunAplicacion.tintColor = .systemBlue
        imagenSegunAplicacion.contentMode = .scaleAspectFit
  
        labelNombreProducto.font = .systemFont(ofSize: 16, weight: .semibold)
        labelNombreProducto.textColor = .label
               
        labelLoteAnimal.font = .systemFont(ofSize: 14, weight: .regular)
        labelLoteAnimal.textColor = .secondaryLabel
               
        labelCostoPorDosis.font = .systemFont(ofSize: 15, weight: .medium)
        labelCostoPorDosis.textColor = .systemGreen
               
        labelFechaAplicacion.font = .systemFont(ofSize: 14, weight: .regular)
        labelFechaAplicacion.textColor = .secondaryLabel
    }
    
    func configure(nombreProducto: String, loteAnimal: String, costo: String, fecha: String, icono: String) {
        labelNombreProducto.text = nombreProducto
        labelLoteAnimal.text = loteAnimal
        labelCostoPorDosis.text = costo
        labelFechaAplicacion.text = fecha
        imagenSegunAplicacion.image = UIImage(systemName: icono)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
           
        labelNombreProducto.text = nil
        labelLoteAnimal.text = nil
        labelCostoPorDosis.text = nil
        labelFechaAplicacion.text = nil
        imagenSegunAplicacion.image = nil
        imagenSegunAplicacion.tintColor = .systemBlue
    }
}
