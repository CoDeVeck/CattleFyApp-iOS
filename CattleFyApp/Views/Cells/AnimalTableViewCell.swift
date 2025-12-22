//
//  AnimalTableViewCell.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/21/25.
//
import UIKit

class AnimalTableViewCell: UITableViewCell {
    
    @IBOutlet weak var fotoImageView: UIImageView!
    @IBOutlet weak var codigoQRLabel: UILabel!
    @IBOutlet weak var pesoDiasLabel: UILabel!
    @IBOutlet weak var estadoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        // Configurar imagen redonda
        fotoImageView.contentMode = .scaleAspectFill
        fotoImageView.clipsToBounds = true
        fotoImageView.layer.cornerRadius = 8
        
        // Configurar labels
        codigoQRLabel.font = UIFont.boldSystemFont(ofSize: 16)
        codigoQRLabel.textColor = .label
        
        pesoDiasLabel.font = UIFont.systemFont(ofSize: 14)
        pesoDiasLabel.textColor = .secondaryLabel
        
        estadoLabel.font = UIFont.systemFont(ofSize: 14)
        estadoLabel.textAlignment = .right
    }
    
    // ← AQUÍ VA LA FUNCIÓN CONFIGURAR
    func configurar(con animal: AnimalResponse) {
        // Código QR como título
        codigoQRLabel.text = animal.codigoQr ?? "Sin código"
        
        // Peso y días
        var pesoDiasTexto = ""
        
        if let peso = animal.peso {
            pesoDiasTexto = String(format: "%.1f kg", peso)
        }
        
        if let dias = animal.edadEnDias {
            if !pesoDiasTexto.isEmpty {
                pesoDiasTexto += " - \(dias) días"
            } else {
                pesoDiasTexto = "\(dias) días"
            }
        }
        
        pesoDiasLabel.text = pesoDiasTexto.isEmpty ? "Sin datos" : pesoDiasTexto
        
        // Estado con color
        configurarEstado(animal.estado)
        
        // Cargar imagen
        cargarImagen(desde: animal.fotoUrl)
    }
    
    private func configurarEstado(_ estado: String?) {
        guard let estado = estado else {
            estadoLabel.text = "Desconocido"
            estadoLabel.textColor = .gray
            return
        }
        
        estadoLabel.text = estado
        
        // Asignar color según el estado
        switch estado.lowercased() {
        case "vivo", "activo":
            estadoLabel.textColor = .systemGreen
        case "muerto", "fallecido":
            estadoLabel.textColor = .systemRed
        case "vendido":
            estadoLabel.textColor = .systemBlue
        case "enfermo":
            estadoLabel.textColor = .systemOrange
        default:
            estadoLabel.textColor = .gray
        }
    }
    
    private func cargarImagen(desde urlString: String?) {
        // Imagen por defecto
        fotoImageView.image = UIImage(systemName: "photo")
        fotoImageView.tintColor = .systemGray3
        
        guard let urlString = urlString,
              !urlString.isEmpty,
              let url = URL(string: urlString) else {
            return
        }
        
        // Cargar imagen de forma asíncrona
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("❌ Error al cargar imagen: \(error.localizedDescription)")
                return
            }
            
            guard let data = data,
                  let image = UIImage(data: data) else {
                print("⚠️ No se pudo crear imagen desde los datos")
                return
            }
            
            DispatchQueue.main.async {
                self?.fotoImageView.image = image
                self?.fotoImageView.contentMode = .scaleAspectFill
            }
        }.resume()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Limpiar la celda antes de reutilizarla
        fotoImageView.image = UIImage(systemName: "photo")
        codigoQRLabel.text = nil
        pesoDiasLabel.text = nil
        estadoLabel.text = nil
    }
}
