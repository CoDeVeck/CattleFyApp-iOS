//
//  HistorialSanitarioViewController.swift
//  CattleFyApp
//
//  Created by Andy Yahir Valdivia Centeno on 21/12/25.
//

import UIKit

class HistorialSanitarioViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var loteId: Int!
        var registros: [RegistroSanitarioResponse] = []
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            title = "Historial Sanitario"
            setupTableView()
            cargarRegistros()
        }
        
        private func setupTableView() {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.rowHeight = 180
            tableView.estimatedRowHeight = 190
            
        
        }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    private func cargarRegistros() {
            RegistroSanitarioService.shared.obtenerRegistrosSanitarios(loteId: loteId) { [weak self] result in
                DispatchQueue.main.async {

                    switch result {
                    case .success(let registros):
                        self?.registros = registros
                        self?.tableView.reloadData()
                        
                    case .failure(let error):
                        self?.mostrarError(error.localizedDescription)
                    }
                }
            }
        }
        
        private func mostrarError(_ mensaje: String) {
            let alert = UIAlertController(title: "Error",
                                         message: mensaje,
                                         preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    // MARK: - UITableViewDataSource
    extension HistorialSanitarioViewController: UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return registros.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RegistroSanitarioCell", for: indexPath) as! RegistroSanitarioCell
            cell.configure(with: registros[indexPath.row])
            return cell
        }
    }

    // MARK: - UITableViewDelegate
    extension HistorialSanitarioViewController: UITableViewDelegate {
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            // Aquí puedes navegar a una vista de detalle
            let registro = registros[indexPath.row]
            mostrarDetalle(registro)
        }
        
        private func mostrarDetalle(_ registro: RegistroSanitarioResponse) {
            // Implementar navegación al detalle
        }
    }
