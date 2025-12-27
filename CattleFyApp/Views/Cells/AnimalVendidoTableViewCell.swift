import UIKit

class AnimalVendidoTableViewCell: UITableViewCell {
    
    
    // MARK: - IBOutlets
        @IBOutlet weak var labelCodigoQR: UILabel!
        @IBOutlet weak var labelPeso: UILabel!
        @IBOutlet weak var labelCostoUnitario: UILabel!
        @IBOutlet weak var iconoAnimal: UIImageView!
        
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
            
            // Código QR - Principal
            labelCodigoQR.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            labelCodigoQR.textColor = .label
            
            // Peso
            labelPeso.font = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .medium)
            labelPeso.textColor = .systemBlue
            
            // Costo unitario
            labelCostoUnitario.font = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .medium)
            labelCostoUnitario.textColor = .systemGreen
            
            // Ícono
            iconoAnimal.tintColor = .systemGray
            iconoAnimal.contentMode = .scaleAspectFit
            
            // Separador
            separatorInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 16)
        }
        
        func configurar(con animal: DetalleAnimalVendido) {
            // Código QR
            labelCodigoQR.text = animal.codigoQr
            // Peso con formato
            let pesoFormatter = NumberFormatter()
            pesoFormatter.numberStyle = .decimal
            pesoFormatter.maximumFractionDigits = 2
            pesoFormatter.minimumFractionDigits = 2
            
           
            
            // Costo unitario con formato de moneda
            let costoFormatter = NumberFormatter()
            costoFormatter.numberStyle = .currency
            costoFormatter.currencyCode = "PEN"
            costoFormatter.maximumFractionDigits = 2
            
         
            // Ícono de animal
            iconoAnimal.image = UIImage(systemName: "circle.fill")
            iconoAnimal.tintColor = .systemGray3
        }
}
