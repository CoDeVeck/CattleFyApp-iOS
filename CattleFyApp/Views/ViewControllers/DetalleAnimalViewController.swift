//
//  DetalleAnimalViewController.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/7/25.
//

import UIKit

class DetalleAnimalViewController: UIViewController {
    
    @IBOutlet weak var animalImageView: UIImageView!
    @IBOutlet weak var codigoQRLabel: UILabel!
    @IBOutlet weak var especieLabel: UILabel!
    @IBOutlet weak var loteLabel: UILabel!
    @IBOutlet weak var origenLabel: UILabel!
    @IBOutlet weak var fechaIngresoLabel: UILabel!
    @IBOutlet weak var fechaNacimientoLabel: UILabel!
    @IBOutlet weak var codigoQRMadreLabel: UILabel!
    @IBOutlet weak var sexoLabel: UILabel!
    @IBOutlet weak var pesoKgLabel: UILabel!
    
    @IBOutlet weak var tablaSanitario: UITableView!
    @IBOutlet weak var tablaPeso: UITableView!
    @IBOutlet weak var tablaMovilidad: UITableView!
    
    var codigoQR: String?
    private let animalesService = AnimalesService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let qr = codigoQR {
            print("📍 Detalle del animal con QR: \(qr)")
            cargarDatosAnimal(qr: qr)
        }
    }
    
    // MARK: - Cargar datos del animal
    private func cargarDatosAnimal(qr: String) {
        animalesService.obtenerAnimalPorQR(qrAnimal: qr) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let animal):
                    self?.configurarVista(con: animal)
                case .failure(let error):
                    self?.mostrarError(error)
                }
            }
        }
    }
    
    // MARK: - Configurar vista con datos
    private func configurarVista(con animal: AnimalResponse) {
        // Setear labels con los datos del animal
        codigoQRLabel.text = animal.codigoQr ?? "N/A"
        especieLabel.text = animal.especie ?? "N/A"
        loteLabel.text = animal.lote ?? "N/A"
        origenLabel.text = animal.origen ?? "N/A"
        fechaIngresoLabel.text = formatearFecha(animal.fechaIngreso)
        fechaNacimientoLabel.text = formatearFecha(animal.fechaNacimiento)
        codigoQRMadreLabel.text = animal.codigoQrMadre ?? "Sin madre registrada"
        sexoLabel.text = animal.sexo ?? "N/A"
        
        // Formatear peso
        if let peso = animal.peso {
            pesoKgLabel.text = String(format: "%.2f kg", peso)
        } else {
            pesoKgLabel.text = "N/A"
        }
        
        // Cargar imagen si existe
        if let fotoUrl = animal.fotoUrl, !fotoUrl.isEmpty {
            cargarImagen(desde: fotoUrl)
        } else {
            animalImageView.image = UIImage(systemName: "photo")
        }
    }
    
    // MARK: - Helpers
    private func formatearFecha(_ fecha: String?) -> String {
        guard let fecha = fecha, !fecha.isEmpty else { return "N/A" }
        
        // Si la fecha viene en formato "yyyy-MM-dd", la formateamos
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: fecha) {
            dateFormatter.dateFormat = "dd/MM/yyyy"
            return dateFormatter.string(from: date)
        }
        
        return fecha // Retornar original si no se puede formatear
    }
    
    private func cargarImagen(desde url: String) {
        guard let imageURL = URL(string: url) else { return }
        
        URLSession.shared.dataTask(with: imageURL) { [weak self] data, response, error in
            guard let data = data, error == nil,
                  let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    self?.animalImageView.image = UIImage(systemName: "photo")
                }
                return
            }
            
            DispatchQueue.main.async {
                self?.animalImageView.image = image
            }
        }.resume()
    }
    
    private func mostrarError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: "No se pudieron cargar los datos del animal: \(error.localizedDescription)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    @IBAction func registrarPesoAnimalButton(_ sender: UIButton) {
        guard let vc = storyboard?.instantiateViewController(
            withIdentifier: "RegistrarPesajeAnimalViewController"
        ) as? RegistrarPesajeAnimalViewController else { return }
        
        vc.codigoQR = codigoQR
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func registrarTratamientoButton(_ sender: UIButton) {
        guard let vc = storyboard?.instantiateViewController(
            withIdentifier: "RegistroSanitarioAnimalViewController"
        ) as? RegistroSanitarioAnimalViewController else { return }
        
        vc.codigoQR = codigoQR
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func registrarTrasladoButton(_ sender: UIButton) {
        guard let vc = storyboard?.instantiateViewController(
            withIdentifier: "TrasladoAnimalViewController"
        ) as? TrasladoAnimalViewController else { return }
        
        vc.codigoQR = codigoQR
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func registrarMuerteButton(_ sender: UIButton) {
        guard let vc = storyboard?.instantiateViewController(
            withIdentifier: "RegistroMuerteViewController"
        ) as? RegistroMuerteViewController else { return }
        
        vc.codigoQR = codigoQR
        navigationController?.pushViewController(vc, animated: true)
    }
}
