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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
