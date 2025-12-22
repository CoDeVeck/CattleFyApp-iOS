//
//  DashboardProduccionViewController.swift
//  CattleFyApp
//
//  Created by Fernando on 17/12/25.
//

import UIKit

class DashboardProduccionViewController: UIViewController {
    
    
    @IBOutlet weak var buttonEngorde: UIButton!
    
    @IBOutlet weak var buttonDescarte: UIButton!
    
    @IBOutlet weak var buttonReproduccion: UIButton!
    
    @IBOutlet weak var tableViewLotesDisponibles: UITableView!
    
    
    private let viewModel = VentaViewModel()
    private var loteSeleccionado: LoteDisponibleVentaResponse?
    private var indexPathSeleccionado: IndexPath?
    private let granjaId: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewLotesDisponibles.delegate = self
        tableViewLotesDisponibles.dataSource = self
        
        tableViewLotesDisponibles.rowHeight = 350
        
        viewModel.onLotesActualizados = { [weak self] in
            self?.tableViewLotesDisponibles.reloadData()
        }
        
        viewModel.onError = { [weak self] mensaje in
            let alert = UIAlertController(title: "Error", message: mensaje, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
        
        viewModel.tipoFiltroActual = .reproduccion
        viewModel.cargarLotesDisponibles(granjaId: granjaId)
        actualizarBotonesFiltro(botonActivo: buttonReproduccion)
        
    }
    
    
    // MARK: - Acciones de Filtros
    
    @IBAction func btnEngordePressed(_ sender: UIButton) {
        viewModel.aplicarFiltro(.engorde)
        actualizarBotonesFiltro(botonActivo: sender)
    }
    
    @IBAction func btnDescartePressed(_ sender: UIButton) {
        viewModel.aplicarFiltro(.descarte)
        actualizarBotonesFiltro(botonActivo: sender)
    }
    
    @IBAction func btnReproduccionPressed(_ sender: UIButton) {
        viewModel.aplicarFiltro(.reproduccion)
        actualizarBotonesFiltro(botonActivo: sender)
    }
    
    private func actualizarBotonesFiltro(botonActivo: UIButton) {
        [buttonEngorde, buttonDescarte, buttonReproduccion].forEach { boton in
            if boton == botonActivo && viewModel.tipoFiltroActual != nil {
                
                boton?.backgroundColor = .systemBlue.withAlphaComponent(0.3)
            } else {
                boton?.backgroundColor = .clear
            }
        }
    }
    
    
    // MARK: - Preparar Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueVentaLotePrimerPaso",
           let destinoVC = segue.destination as? VentaLoteViewController,
           let lote = loteSeleccionado {
            
            let datos = viewModel.formatearDatosParaVenta(lote: lote)
            destinoVC.loteData = lote
            destinoVC.ventaLoteNombreLote = datos.nombreLote
            destinoVC.ventaLoteTotalAnimales = datos.totalAnimales
            destinoVC.ventaLotePesoTotal = datos.pesoTotal
            destinoVC.ventaLotePesoPromedio = datos.pesoPromedio
            destinoVC.ventaLoteCvtTotal = datos.costoTotal
            destinoVC.ventaLoteCostoDeCompra = datos.costoPromedioPorAnimal
        }
    }
    
    
}

// MARK: - TableView DataSource
extension DashboardProduccionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.lotesFiltrados.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LotesDisponiblesCell", for: indexPath) as? LotesDisponiblesTableViewCell,
              let lote = viewModel.obtenerLote(en: indexPath.row) else {
            return UITableViewCell()
        }
        
        cell.configurar(con: lote)
        cell.marcarComoSeleccionada(indexPath == indexPathSeleccionado)
        
        cell.delegate = self
        
        return cell
    }
}

// MARK: - TableView Delegate
extension DashboardProduccionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let oldPath = indexPathSeleccionado,
           let oldCell = tableView.cellForRow(at: oldPath) as? LotesDisponiblesTableViewCell {
            oldCell.marcarComoSeleccionada(false)
        }
        
        loteSeleccionado = viewModel.obtenerLote(en: indexPath.row)
        indexPathSeleccionado = indexPath
        
        if let cell = tableView.cellForRow(at: indexPath) as? LotesDisponiblesTableViewCell {
            cell.marcarComoSeleccionada(true)
        }
        
    }
}

extension DashboardProduccionViewController: LotesDisponiblesCellDelegate {
    func didTapIniciarVenta(en lote: LoteDisponibleVentaResponse) {
        
        loteSeleccionado = lote
        
        
        let validacion = viewModel.puedeIniciarVenta(conLote: lote)
        
        if !validacion.valido {
            let alert = UIAlertController(
                title: "No se puede iniciar venta",
                message: validacion.mensaje,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        
        print("Iniciando venta del lote: \(lote.loteNombre)")
        performSegue(withIdentifier: "segueVentaLotePrimerPaso", sender: self)
    }
}
