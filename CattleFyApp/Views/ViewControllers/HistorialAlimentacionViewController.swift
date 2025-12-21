//
//  HistorialAlimentacionViewController.swift
//
//
//  Created by Andy Yahir Valdivia Centeno on 11/12/25.
//

import UIKit

class HistorialAlimentacionViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var registros: [RegistrarAlimentacionHistorialDTO] = []
    private let apiService = RegistroAlimentacionService.shared
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
                //cargarDatos()
            }
            
            // MARK: - Setup
            private func setupTableView() {
                tableView.delegate = self
                tableView.dataSource = self
                tableView.separatorStyle = .none
                tableView.backgroundColor = .clear
                tableView.estimatedRowHeight = 140
                tableView.rowHeight = 140
            }
            
            // MARK: - Data Loading
            /*private func cargarDatos() {
                apiService.obtenerHistorialAlimentacion { [weak self] result in
                    DispatchQueue.main.async {
                        
                        switch result {
                        case .success(let historial):
                            self?.registros = historial
                            self?.tableView.reloadData()
                            
                        case .failure(let error):
                            self?.mostrarError(error.localizedDescription)
                        }
                    }
                }
            }
            
            private func mostrarError(_ mensaje: String) {
                let alert = UIAlertController(
                    title: "Error",
                    message: mensaje,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Reintentar", style: .default) { [weak self] _ in
                    self?.cargarDatos()
                })
                alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
                present(alert, animated: true)
            }*/
            
    private func esReciente(_ registro: RegistrarAlimentacionHistorialDTO) -> Bool {
        guard let fechaString = registro.fecha else { return false }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        guard let fecha = formatter.date(from: fechaString) else { return false }
        
        let horasTranscurridas = Date().timeIntervalSince(fecha) / 3600
        return horasTranscurridas < 24
    }
}
extension HistorialAlimentacionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return registros.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "RegistroCell",
            for: indexPath
        ) as? RegistroAlimentacionCell else {
            return UITableViewCell()
        }
        
        let registro = registros[indexPath.row]
        cell.configurar(con: registro)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension HistorialAlimentacionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
