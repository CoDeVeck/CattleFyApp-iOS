//
//  ListadoVentasViewController.swift
//  CattleFyApp
//
//  Created by Victor Manuel on 25/12/25.
//

import UIKit

class ListadoVentasViewController: UIViewController {
    
    @IBOutlet weak var labelListadoVentas: UILabel!
    
    @IBOutlet weak var roiPromedioVentas: UILabel!
    
    @IBOutlet weak var animalesVendidosVentas: UILabel!
    
    @IBOutlet weak var btnEngordeFiltrar: UIButton!
    
    @IBOutlet weak var btnDescarteFiltrar: UIButton!
    
    @IBOutlet weak var btnReproduccionFiltrar: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    private var viewModel: ListadoVentasViewModel!
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarUI()
        configurarTableView()
        configurarViewModel()
        cargarDatos()
    }
    
    
    private func configurarUI() {
        title = "Ventas Realizadas"
        view.backgroundColor = .systemGroupedBackground
        
        // Configurar labels de estadísticas
        labelListadoVentas.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        labelListadoVentas.textColor = .label
        
        roiPromedioVentas.font = UIFont.monospacedDigitSystemFont(ofSize: 20, weight: .bold)
        roiPromedioVentas.textColor = .systemGreen
        
        animalesVendidosVentas.font = UIFont.monospacedDigitSystemFont(ofSize: 18, weight: .semibold)
        animalesVendidosVentas.textColor = .systemBlue
        
        
        configurarBotonesFiltro()
        
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    private func configurarBotonesFiltro() {
        let botones = [btnEngordeFiltrar, btnDescarteFiltrar, btnReproduccionFiltrar]
        
        botones.forEach { boton in
            guard let btn = boton else { return }
            btn.layer.cornerRadius = 8
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        }
        
        seleccionarBotonFiltro(btnEngordeFiltrar)
    }
    
    private func configurarTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = 200
        tableView.estimatedRowHeight = 160
        tableView.backgroundColor = .systemGroupedBackground
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refrescarDatos), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func obtenerGranjaId() -> Int {
        return 1
    }
    
    
    private func configurarViewModel() {
        let granjaId = obtenerGranjaId()
        viewModel = ListadoVentasViewModel(granjaId: granjaId)
        
        viewModel.onVentasActualizadas = { [weak self] in
            self?.actualizarUI()
        }
        
        viewModel.onError = { [weak self] mensaje in
            self?.mostrarError(mensaje)
        }
        
        viewModel.onLoading = { [weak self] isLoading in
            if isLoading {
                self?.activityIndicator.startAnimating()
            } else {
                self?.activityIndicator.stopAnimating()
                self?.tableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    // MARK: - Data Loading
    private func cargarDatos() {
        viewModel.cargarVentas()
    }
    
    @objc private func refrescarDatos() {
        viewModel.cargarVentas()
    }
    
    private func actualizarUI() {
        // Actualizar estadísticas
        labelListadoVentas.text = "Ventas: \(viewModel.numeroDeVentas)"
        roiPromedioVentas.text = String(format: "ROI: %.2f%%", viewModel.roiPromedio)
        animalesVendidosVentas.text = "\(viewModel.totalAnimalesVendidos) animales"
        
        // Recargar tabla
        tableView.reloadData()
        
        // Mostrar mensaje si no hay datos
        if viewModel.numeroDeVentas == 0 {
            mostrarMensajeVacio()
        } else {
            ocultarMensajeVacio()
        }
    }
    
    
    
    private func aplicarFiltro(_ filtro: TipoVentaFiltro, boton: UIButton) {
        viewModel.aplicarFiltro(filtro)
        seleccionarBotonFiltro(boton)
    }
    
    private func seleccionarBotonFiltro(_ botonSeleccionado: UIButton?) {
        let botones = [btnEngordeFiltrar, btnDescarteFiltrar, btnReproduccionFiltrar]
        
        botones.forEach { boton in
            guard let btn = boton else { return }
            
            if btn == botonSeleccionado {
                btn.backgroundColor = .systemBlue
                btn.setTitleColor(.white, for: .normal)
                btn.layer.borderWidth = 0
            } else {
                btn.backgroundColor = .systemBackground
                btn.setTitleColor(.systemBlue, for: .normal)
                btn.layer.borderWidth = 1
                btn.layer.borderColor = UIColor.systemBlue.cgColor
            }
        }
    }
    
    
    @IBAction func btnEngordePressed(_ sender: UIButton) {
        aplicarFiltro(.engorde, boton: sender)
    }
    @IBAction func btnDescartePressed(_ sender: UIButton) {
        aplicarFiltro(.descarte, boton: sender)
    }
    
    @IBAction func btnReproduccionPressed(_ sender: UIButton) {
        aplicarFiltro(.reproduccion, boton: sender)
    }
    
    
    
    private func ocultarMensajeVacio() {
        tableView.backgroundView = nil
    }
    
    private func mostrarError(_ mensaje: String) {
        let alert = UIAlertController(title: "Error", message: mensaje, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func mostrarMensajeVacio() {
        let mensajeLabel = UILabel()
        mensajeLabel.text = "No hay ventas registradas"
        mensajeLabel.textAlignment = .center
        mensajeLabel.textColor = .secondaryLabel
        mensajeLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        mensajeLabel.tag = 999
        
        tableView.backgroundView = mensajeLabel
    }
    
    
    
    
    
}


extension ListadoVentasViewController: UITableViewDataSource {
    
    
    func mostrarDetalleVenta(ventaId: Int) {
        
        
        let storyboard = UIStoryboard(name: "VentaComercial", bundle: nil)
        
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "DetalleVentaViewController"
        ) as? DetalleVentaViewController else {
            print("No se pudo instanciar DetalleVentaViewController")
            return
        }
        
        vc.ventaId = ventaId
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numeroDeVentas
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "celdaDetalleAnimales",
            for: indexPath
        ) as? ListadoVentasTableViewCell else {
            return UITableViewCell()
        }
        
        cell.onDetallePressed = { [weak self] ventaId in
            self?.mostrarDetalleVenta(ventaId: ventaId)
        }
        
        if let venta = viewModel.venta(en: indexPath.row) {
            cell.configurar(con: venta)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ListadoVentasViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
