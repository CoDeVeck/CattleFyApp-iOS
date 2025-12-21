//
//  ListadoLotesViewController.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/7/25.
//

import UIKit

class ListadoLotesViewController: UIViewController {
    
    @IBOutlet weak var especieButton: UIButton!
        
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var loteNombreTextField: UITextField!
    
    private var especies: [EspecieResponse] = []
    private var lotes: [LoteResponse] = []
    private var especieSeleccionada: EspecieResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
                setupUI()
                cargarEspecies()
            }
            
    private func setupUI() {
            // Ocultar botón de tipo
            
            // Configurar TextField
            loteNombreTextField?.placeholder = "Buscar por nombre..."
            loteNombreTextField?.clearButtonMode = .whileEditing
            loteNombreTextField?.returnKeyType = .search
            loteNombreTextField?.delegate = self
            loteNombreTextField?.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
            
            // Configurar botón de especie
            especieButton?.setTitle("Seleccionar Especie", for: .normal)
            especieButton?.addTarget(self, action: #selector(especieButtonTapped), for: .touchUpInside)
            
            // Cargar todos los lotes inicialmente
            buscarLotes()
        }
        
        private func setupTableView() {
            tableView?.delegate = self
            tableView?.dataSource = self
            tableView?.separatorStyle = .none
            tableView?.backgroundColor = .systemGroupedBackground
        }
        
    private func cargarEspecies() {
        EspecieService.shared.obtenerEspecies { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let especies):
                    
                    // insertar opción TODOS
                    let opcionTodos = EspecieResponse(especieId: nil, nombre: "Todos")
                    self?.especies = [opcionTodos] + especies

                    print("✅ Especies cargadas: \(especies.count + 1)")

                case .failure(let error):
                    print("❌ Error: \(error.localizedDescription)")
                }
            }
        }
    }

        
        // MARK: - IBActions
        @IBAction func especieButtonTapped(_ sender: UIButton) {
            mostrarEspecies()
        }
        
        // MARK: - Actions
        @objc private func mostrarEspecies() {
            print("👆 Botón de especie presionado")
            
            guard !especies.isEmpty else {
                print("⚠️ No hay especies disponibles")
                mostrarAlerta(titulo: "Aviso", mensaje: "No hay especies disponibles")
                return
            }
            
            print("📋 Mostrando \(especies.count) especies")
            
            let alert = UIAlertController(title: "Seleccionar Especie", message: nil, preferredStyle: .actionSheet)
            
            for especie in especies {
                let action = UIAlertAction(title: especie.nombre, style: .default) { [weak self] _ in
                    print("✅ Especie seleccionada: \(especie.nombre)")
                    self?.especieSeleccionada = especie
                    self?.especieButton?.setTitle(especie.nombre, for: .normal)
                    self?.buscarLotes()
                }
                alert.addAction(action)
            }
            
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel) { _ in
                print("❌ Cancelado")
            })
            
            // Para iPad
            if let popover = alert.popoverPresentationController {
                popover.sourceView = especieButton
                popover.sourceRect = especieButton.bounds
            }
            
            present(alert, animated: true) {
                print("✅ Alert presentado")
            }
        }
        
        @objc private func textFieldDidChange() {
            buscarLotes()
        }
        
        private func buscarLotes() {
            // Obtener especie ID (puede ser nil si seleccionó "Todos")
            let especieId = especieSeleccionada?.especieId
            
            let nombreBusqueda = loteNombreTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            print("🔍 Buscando lotes...")
            if let id = especieId {
                print("   - Especie ID: \(id)")
            } else {
                print("   - Especie: TODOS (sin filtro)")
            }
            print("   - Nombre: \(nombreBusqueda ?? "todos")")
            
            LoteService.shared.listarLotes(
                granjaId: nil,
                especieId: especieId  // Ahora puede ser nil
            ) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        print("📦 Respuesta recibida:")
                        print("   - Valor: \(response.valor)")
                        print("   - Mensaje: \(response.mensaje)")
                        
                        if response.valor, let lotes = response.data {
                            // Filtrar por nombre si hay texto
                            if let nombre = nombreBusqueda, !nombre.isEmpty {
                                self?.lotes = lotes.filter { lote in
                                    let nombreLote = lote.nombre.lowercased()
                                    
                                    let busqueda = nombre.lowercased()
                                    return nombreLote.contains(busqueda) 
                                }
                                print("🔎 Filtrados: \(self?.lotes.count ?? 0) de \(lotes.count)")
                            } else {
                                self?.lotes = lotes
                            }
                            
                            self?.tableView?.reloadData()
                            print("✅ Mostrando \(self?.lotes.count ?? 0) lotes")
                            
                            if self?.lotes.isEmpty == true {
                                print("⚠️ Lista vacía después de filtrar")
                            }
                        } else {
                            self?.lotes = []
                            self?.tableView?.reloadData()
                            print("⚠️ Sin datos en la respuesta")
                        }
                        
                    case .failure(let error):
                        print("❌ Error al buscar lotes: \(error.localizedDescription)")
                        self?.lotes = []
                        self?.tableView?.reloadData()
                    }
                }
            }
        }
        
        private func mostrarAlerta(titulo: String, mensaje: String) {
            let alert = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
}
    // MARK: - UITableViewDataSource
    extension ListadoLotesViewController: UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return lotes.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LoteCell", for: indexPath) as? LoteCell else {
                return UITableViewCell()
            }
            
            let lote = lotes[indexPath.row]
            cell.configure(with: lote)
            cell.selectionStyle = .none
            cell.backgroundColor = .clear
            
            return cell
        }
    }
    
    // MARK: - UITableViewDelegate
    extension ListadoLotesViewController: UITableViewDelegate {
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let lote = lotes[indexPath.row]
            print("📌 Lote seleccionado: \(lote.nombre ?? "N/A")")
            
            // Aquí puedes navegar a los detalles del lote
            // performSegue(withIdentifier: "showLoteDetail", sender: lote)
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return UITableView.automaticDimension
        }
    
}
extension ListadoLotesViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        buscarLotes()
        return true
    }
}
