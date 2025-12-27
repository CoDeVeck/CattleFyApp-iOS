//
//  DetalleVentaViewController.swift
//  CattleFyApp
//
//  Created by Victor Manuel on 25/12/25.
//

import UIKit

class DetalleVentaViewController: UIViewController {
    
    @IBOutlet weak var labelLoteNombre: UILabel!
    @IBOutlet weak var labelEspecieCategoria: UILabel!
    @IBOutlet weak var labelCliente: UILabel!
    @IBOutlet weak var labelFechaVenta: UILabel!
    @IBOutlet weak var labelTipoVenta: UILabel!
    @IBOutlet weak var labelPrecioTotal: UILabel!
    @IBOutlet weak var labelCostoInvertido: UILabel!
    @IBOutlet weak var labelGananciaNeta: UILabel!
    @IBOutlet weak var labelROI: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    
    // MARK: - Properties
    var ventaId: Int? {
        didSet {
            if isViewLoaded{
                cargarDatos()
            }
        }
    }
    private var viewModel: DetalleVentaViewModel?
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = ventaId {
            cargarDatos()
        }
        
        configurarUI()
        configurarTableView()
        configurarViewModel()
        cargarDatos()
    }
    
    // MARK: - Setup
    private func configurarUI() {
        title = "Detalle de Venta"
        view.backgroundColor = .systemGroupedBackground
        
        
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    private func configurarTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = 80
        tableView.backgroundColor = .systemGroupedBackground
    }
    
    private func configurarViewModel() {
        guard ventaId != nil else {
            mostrarError("No se proporcionó ID de venta")
            return
        }
    
        viewModel = DetalleVentaViewModel(ventaId: ventaId ?? -1)
        
        viewModel?.onDetalleActualizado = { [weak self] in
            self?.actualizarUI()
        }
        
        viewModel?.onError = { [weak self] mensaje in
            self?.mostrarError(mensaje)
        }
        
        viewModel?.onLoading = { [weak self] isLoading in
            if isLoading {
                self?.activityIndicator.startAnimating()
            } else {
                self?.activityIndicator.stopAnimating()
            }
        }
    }
    
    private func cargarDatos() {
        viewModel?.cargarDetalle()
    }
    
    private func actualizarUI() {
        actualizarInfoBasica()
        actualizarEstadisticas()
        tableView.reloadData()
    }
    
    private func actualizarInfoBasica() {
        guard let info = viewModel?.informacionBasica else { return }
        
        labelLoteNombre.text = info.loteNombre
        labelEspecieCategoria.text = "\(info.especieNombre) • \(info.categoriaManejoNombre)"
        labelCliente.text = "Cliente: \(info.clienteNombre)"
        labelFechaVenta.text = formatearFecha(info.fechaVenta)
        
    }
    
    private func actualizarEstadisticas() {
        guard let stats = viewModel?.estadisticas else { return }
        
        labelPrecioTotal.text = formatearMoneda(stats.precioTotal)
        labelPrecioTotal.textColor = .systemGreen
        
        labelCostoInvertido.text = formatearMoneda(stats.costoTotalInvertido)
        labelCostoInvertido.textColor = .systemOrange
        
        labelGananciaNeta.text = formatearMoneda(stats.gananciaNeta)
        labelGananciaNeta.textColor = stats.gananciaNeta >= 0 ? .systemGreen : .systemRed
        
        let roiTexto = String(format: "%.2f%%", Double(truncating: stats.roiReal as NSNumber))
        let objetivoTexto = String(format: "%.2f%%", Double(truncating: stats.roiObjetivo as NSNumber))
        labelROI.text = "ROI: \(roiTexto) (Obj: \(objetivoTexto))"
    }
    
    private func formatearFecha(_ fechaString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let fecha = isoFormatter.date(from: fechaString) else {
            isoFormatter.formatOptions = [.withInternetDateTime]
            guard let fecha = isoFormatter.date(from: fechaString) else {
                return fechaString
            }
            return formatearDate(fecha)
        }
        
        return formatearDate(fecha)
    }
    
    private func formatearDate(_ fecha: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_PE")
        return formatter.string(from: fecha)
    }
    
    private func formatearMoneda(_ valor: Decimal, porKg: Bool = false) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "PEN"
        formatter.maximumFractionDigits = 2
        
        if let valorStr = formatter.string(from: valor as NSDecimalNumber) {
            return porKg ? "\(valorStr)/kg" : valorStr
        }
        return porKg ? "S/ \(valor)/kg" : "S/ \(valor)"
    }
    
    
    
    private func mostrarError(_ mensaje: String) {
        let alert = UIAlertController(title: "Error", message: mensaje, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension DetalleVentaViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numeroDeAnimales ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "AnimalVendidoTableViewCell",
            for: indexPath
        ) as? AnimalVendidoTableViewCell else {
            return UITableViewCell()
        }
        
        if let animal = viewModel?.animal(en: indexPath.row) {
            cell.configurar(con: animal)
        }
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension DetalleVentaViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
