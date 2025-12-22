import UIKit

class LoteCell: UITableViewCell {
    
    @IBOutlet weak var loteLabelç: UILabel!
    
    @IBOutlet weak var estadoLabel: UILabel!
    
    @IBOutlet weak var especieLabel: UILabel!
    
    @IBOutlet weak var engordeLabel: UILabel!
    
    @IBOutlet weak var cantidadLabel: UILabel!
    
    @IBOutlet weak var fechaLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - Configure
    func configure(with lote: LoteResponse) {
        loteLabelç.text = "Lote: \(lote.idLote != nil ? String(lote.idLote) : "N/A") \(lote.nombre != nil ? lote.nombre : "N/A")"
        estadoLabel?.text = lote.estado ?? "Sin estado"
        
        // Configurar color según estado
        switch lote.estado.lowercased(){
        case "activo":
            estadoLabel?.textColor = .systemGreen
        case "inactivo", "cerrado":
            estadoLabel?.textColor = .systemRed
        case "en proceso":
            estadoLabel?.textColor = .systemOrange
        default:
            estadoLabel?.textColor = .systemGray
        }
        
        let actual = lote.animalesVivos
        let maximo = lote.capacidadMax

        if actual > 0 && maximo > 0 {
            cantidadLabel?.text = "Cantidad: \(actual) / \(maximo) animales"
        } else if actual > 0 {
            cantidadLabel?.text = "Cantidad: \(actual) animales"
        } else {
            cantidadLabel?.text = "Cantidad: 0 animales"
        }
        
        fechaLabel?.text = "Inicio: \(lote.fechaCreacion)"
        
        engordeLabel?.text = lote.tipoLote ?? "Sin tipo"
    }
    
    // MARK: - Helper
    private func formatearFecha(_ fecha: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        if let date = formatter.date(from: fecha) {
            formatter.dateFormat = "dd/MM/yyyy"
            return formatter.string(from: date)
        }
        
        return fecha
    }
}
