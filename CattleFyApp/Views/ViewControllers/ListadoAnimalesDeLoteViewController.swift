//
//  ListadoAnimalesDeLoteViewController.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/7/25.
//

import UIKit

class ListadoAnimalesDeLoteViewController: UIViewController {
    
    @IBOutlet weak var buscadorCodigoQRAnimal: UISearchBar!
    @IBOutlet weak var tablaAnimales: UITableView!
    
    // PROPIEDADES
    var idLote: Int?
    var nombreLote: String?
    
    private var animales: [AnimalResponse] = []
    private var animalesFiltrados: [AnimalResponse] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        setupSearchBar()
        
        // Cargar animales
        if let idLote = idLote {
            cargarAnimales(idLote: idLote)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Recargar datos cuando regrese de otra pantalla
        if let idLote = idLote {
            cargarAnimales(idLote: idLote)
        }
    }
    
    private func setupUI() {
        if let nombre = nombreLote {
            title = nombre
        }
    }
    
    private func setupTableView() {
        tablaAnimales.delegate = self
        tablaAnimales.dataSource = self
        tablaAnimales.separatorStyle = .singleLine
    }
    
    private func setupSearchBar() {
        buscadorCodigoQRAnimal.delegate = self
        buscadorCodigoQRAnimal.placeholder = "Buscar por código QR..."
    }
    
    private func cargarAnimales(idLote: Int) {
        print("🔄 Cargando animales del lote: \(idLote)")
        
        AnimalesService.shared.listarAnimalesPorLote(idLote: idLote) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let animales):
                    print("✅ Animales cargados: \(animales.count)")
                    self?.animales = animales
                    self?.animalesFiltrados = animales
                    self?.tablaAnimales.reloadData()
                    
                    if animales.isEmpty {
                        print("⚠️ No hay animales en este lote")
                    }
                    
                case .failure(let error):
                    print("❌ Error al cargar animales: \(error.localizedDescription)")
                    self?.mostrarAlerta(titulo: "Error", mensaje: "No se pudieron cargar los animales")
                }
            }
        }
    }
    
    private func filtrarAnimales(por codigoQR: String) {
        if codigoQR.isEmpty {
            animalesFiltrados = animales
        } else {
            animalesFiltrados = animales.filter { animal in
                guard let qr = animal.codigoQr else { return false }
                return qr.lowercased().contains(codigoQR.lowercased())
            }
        }
        tablaAnimales.reloadData()
    }
    
    private func navegarADetalleAnimal(codigoQR: String) {
        let storyboard = UIStoryboard(name: "FarmFlow", bundle: nil)
        
        if let detalleVC = storyboard.instantiateViewController(withIdentifier: "DetalleAnimalViewController") as? DetalleAnimalViewController {
            detalleVC.codigoQR = codigoQR
            navigationController?.pushViewController(detalleVC, animated: true)
        }
    }
    
    @IBAction func agregarNuevoAnimalButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "RegistroAnimal", bundle: nil)
        let registroVC = storyboard.instantiateViewController(withIdentifier: "RegistroAnimalViewController")
        navigationController?.pushViewController(registroVC, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ListadoAnimalesDeLoteViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return animalesFiltrados.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "celdaAnimal", for: indexPath) as? AnimalTableViewCell else {
            return UITableViewCell()
        }
        
        let animal = animalesFiltrados[indexPath.row]
        cell.configurar(con: animal)
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ListadoAnimalesDeLoteViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let animal = animalesFiltrados[indexPath.row]
        
        guard let codigoQR = animal.codigoQr else {
            print("⚠️ Animal sin código QR")
            mostrarAlerta(titulo: "Error", mensaje: "Este animal no tiene código QR")
            return
        }
        
        print("🐮 Navegando a detalle del animal: \(codigoQR)")
        navegarADetalleAnimal(codigoQR: codigoQR)
    }
}

// MARK: - UISearchBarDelegate
extension ListadoAnimalesDeLoteViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filtrarAnimales(por: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filtrarAnimales(por: "")
    }
}
