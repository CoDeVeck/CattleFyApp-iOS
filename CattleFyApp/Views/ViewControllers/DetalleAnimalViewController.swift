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
    
    // Arrays para los historiales
    private var historialPesaje: [AnimalHistPesaje] = []
    private var historialSanitario: [AnimalHistSanitario] = []
    private var historialTraslados: [AnimalHistTraslado] = []
    
    // ID del animal (lo obtendremos del response)
    private var idAnimal: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Tablas conectadas:")
        print("- tablaPeso: \(tablaPeso != nil)")
        print("- tablaSanitario: \(tablaSanitario != nil)")
        print("- tablaMovilidad: \(tablaMovilidad != nil)")
        
        configurarTablas()
        
        if let qr = codigoQR {
            print("📍 Detalle del animal con QR: \(qr)")
            cargarDatosAnimal(qr: qr)
        }
    }
    
    // MARK: - Configurar tablas
    private func configurarTablas() {
        // Configurar delegates y datasources
        tablaPeso.delegate = self
        tablaPeso.dataSource = self
        tablaPeso.tag = 1
        
        tablaSanitario.delegate = self
        tablaSanitario.dataSource = self
        tablaSanitario.tag = 2
        
        tablaMovilidad.delegate = self
        tablaMovilidad.dataSource = self
        tablaMovilidad.tag = 3

    }
    
    // MARK: - Cargar datos del animal
    private func cargarDatosAnimal(qr: String) {
        animalesService.obtenerAnimalPorQR(qrAnimal: qr) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let animal):
                    self?.idAnimal = animal.idAnimal
                    self?.configurarVista(con: animal)
                    
                    // Cargar historiales
                    if let id = animal.idAnimal {
                        self?.cargarHistoriales(idAnimal: id)
                    }
                    
                case .failure(let error):
                    self?.mostrarError(error)
                }
            }
        }
    }
    
    // MARK: - Cargar historiales
    private func cargarHistoriales(idAnimal: Int) {
        print("🔍 Cargando historiales para animal ID: \(idAnimal)")
        
        // Cargar historial de pesaje
        animalesService.obtenerHistorialPesaje(idAnimal: idAnimal) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let historial):
                    print("✅ Historial de pesaje cargado: \(historial.count) registros")
                    print("📊 Datos: \(historial)")
                    self?.historialPesaje = historial
                    self?.tablaPeso.reloadData()
                case .failure(let error):
                    print("❌ Error al cargar historial de pesaje: \(error)")
                }
            }
        }
        // Cargar historial sanitario
        animalesService.obtenerHistorialSanitario(idAnimal: idAnimal) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let historial):
                    self?.historialSanitario = historial
                    self?.tablaSanitario.reloadData()
                case .failure(let error):
                    print("❌ Error al cargar historial sanitario: \(error)")
                }
            }
        }
        
        // Cargar historial de traslados
        animalesService.obtenerHistorialTraslados(idAnimal: idAnimal) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let historial):
                    self?.historialTraslados = historial
                    self?.tablaMovilidad.reloadData()
                case .failure(let error):
                    print("❌ Error al cargar historial de traslados: \(error)")
                }
            }
        }
    }
    
    // MARK: - Configurar vista con datos
    private func configurarVista(con animal: AnimalResponse) {
        codigoQRLabel.text = animal.codigoQr ?? "N/A"
        especieLabel.text = animal.especie ?? "N/A"
        loteLabel.text = animal.lote ?? "N/A"
        origenLabel.text = animal.origen ?? "N/A"
        fechaIngresoLabel.text = formatearFecha(animal.fechaIngreso)
        fechaNacimientoLabel.text = formatearFecha(animal.fechaNacimiento)
        codigoQRMadreLabel.text = animal.codigoQrMadre ?? "Sin madre registrada"
        sexoLabel.text = animal.sexo ?? "N/A"
        
        if let peso = animal.peso {
            pesoKgLabel.text = String(format: "%.2f kg", peso)
        } else {
            pesoKgLabel.text = "N/A"
        }
        
        if let fotoUrl = animal.fotoUrl, !fotoUrl.isEmpty {
            cargarImagen(desde: fotoUrl)
        } else {
            animalImageView.image = UIImage(systemName: "photo")
        }
    }
    
    // MARK: - Helpers
    private func formatearFecha(_ fecha: String?) -> String {
        guard let fecha = fecha, !fecha.isEmpty else { return "N/A" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: fecha) {
            dateFormatter.dateFormat = "dd/MM/yyyy"
            return dateFormatter.string(from: date)
        }
        
        return fecha
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
        let farmFlowStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let vc = farmFlowStoryboard.instantiateViewController(
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

// MARK: - UITableViewDataSource
extension DetalleAnimalViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case 1: return historialPesaje.count
        case 2: return historialSanitario.count
        case 3: return historialTraslados.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView.tag {
        case 1: // Tabla de pesaje
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "PesajeCell",
                for: indexPath
            ) as? PesajeTableViewCell else {
                return UITableViewCell()
            }
            cell.configurar(con: historialPesaje[indexPath.row])
            return cell
            
        case 2: // Tabla sanitaria
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "SanitarioCell",
                for: indexPath
            ) as? SanitarioTableViewCell else {
                return UITableViewCell()
            }
            cell.configurar(con: historialSanitario[indexPath.row])
            return cell
            
        case 3: // Tabla de traslados
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "TrasladoCell",
                for: indexPath
            ) as? TrasladoTableViewCell else {
                return UITableViewCell()
            }
            cell.configurar(con: historialTraslados[indexPath.row])
            return cell
            
        default:
            return UITableViewCell()
        }
    }
}

// MARK: - UITableViewDelegate
extension DetalleAnimalViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
