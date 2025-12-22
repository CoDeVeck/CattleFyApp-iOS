//
//  HistorialProduccionViewController.swift
//  CattleFyApp
//
//  Created by Andy Yahir Valdivia Centeno on 21/12/25.
//

import UIKit

class HistorialProduccionViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var loteId: Int!
    var registros: [RegistroProduccionDTO] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Historial de Producción"
        setupTableView()
        cargarRegistros()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 140
        tableView.estimatedRowHeight = 140
        
        // Pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refrescarDatos), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    @objc private func refrescarDatos() {
        cargarRegistros()
    }
    
    private func cargarRegistros() {
        
        tableView.isHidden = false
        
        RegistroProduccionService.shared.obtenerHistorialProduccion(loteId: loteId) { [weak self] result in
            DispatchQueue.main.async {
                
                self?.tableView.refreshControl?.endRefreshing()
                
                switch result {
                case .success(let registros):
                    self?.registros = registros.sorted { ($0.fechaRegistro ?? Date()) > ($1.fechaRegistro ?? Date()) }
                    self?.tableView.reloadData()
                    
                case .failure(let error):
                    if (error as NSError).code == 404 {
                        self?.mostrarEstadoVacio()
                    } else {
                        self?.mostrarError(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    private func mostrarEstadoVacio() {
        tableView.isHidden = true
    }
    

        
        private func mostrarError(_ mensaje: String) {
            let alert = UIAlertController(
                title: "Error",
                message: mensaje,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Reintentar", style: .default) { [weak self] _ in
                self?.cargarRegistros()
            })
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
            present(alert, animated: true)
        }
    }

    // MARK: - UITableViewDataSource
    extension HistorialProduccionViewController: UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return registros.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "RegistroProduccionCell",
                for: indexPath
            ) as! RegistroProduccionCell
            
            cell.configure(with: registros[indexPath.row])
            return cell
        }
    }

    // MARK: - UITableViewDelegate
extension HistorialProduccionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let registro = registros[indexPath.row]
    }
    
}
