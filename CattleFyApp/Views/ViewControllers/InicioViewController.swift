//
//  InicioViewController.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/7/25.
//

import UIKit

class InicioViewController: UIViewController {
    
    @IBOutlet weak var animalesLabel: UILabel!
    
    @IBOutlet weak var lotesLabel: UILabel!
    
    @IBOutlet weak var alertasLabel: UILabel!
    
    @IBOutlet weak var ventasLabel: UILabel!
    
    @IBOutlet weak var alimentacionView: UIView!
    
    @IBOutlet weak var sanidadView: UIView!
    
    @IBOutlet weak var pesoView: UIView!
    
    @IBOutlet weak var ventasView: UIView!
    
    @IBOutlet weak var reportesView: UIView!
    
    @IBOutlet weak var produccionView: UIButton!
    
    @IBOutlet weak var lotesListadoView: UIButton!
    
    private let dashboardService = AuthService.shared
    private var granjaId: Int = 1
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarUI()
        configurarGestosEnViews()
        alimentacionView.isUserInteractionEnabled = true
            sanidadView.isUserInteractionEnabled = true
            pesoView.isUserInteractionEnabled = true
            ventasView.isUserInteractionEnabled = true
            reportesView.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cargarContadores()
    }
    
    // MARK: - UI Setup
    private func configurarUI() {
        animalesLabel.text = "..."
        lotesLabel.text = "..."
        alertasLabel.text = "..."
        ventasLabel.text = "..."
        
    }
    private func configurarGestosEnViews() {
        // Crear tap gesture recognizers
        let tapAlimentacion = UITapGestureRecognizer(target: self, action: #selector(alimentacionTapped))
        alimentacionView.addGestureRecognizer(tapAlimentacion)
        
        let tapSanidad = UITapGestureRecognizer(target: self, action: #selector(sanidadTapped))
        sanidadView.addGestureRecognizer(tapSanidad)
        
        let tapPeso = UITapGestureRecognizer(target: self, action: #selector(pesoTapped))
        pesoView.addGestureRecognizer(tapPeso)
        
        let tapVentas = UITapGestureRecognizer(target: self, action: #selector(ventasTapped))
        ventasView.addGestureRecognizer(tapVentas)
        
        let tapReportes = UITapGestureRecognizer(target: self, action: #selector(reportesTapped))
        reportesView.addGestureRecognizer(tapReportes)
        
        let tapProduccion = UITapGestureRecognizer(target: self, action: #selector(produccionTapped))
        produccionView.addGestureRecognizer(tapProduccion)
        
        let tapLotes = UITapGestureRecognizer(target: self, action: #selector(lotesTapped))
        lotesListadoView.addGestureRecognizer(tapLotes)
    }
    // MARK: - Data Loading
    private func cargarContadores() {
        // Obtener granjaId del usuario logueado
        if let savedGranjaId = UserDefaults.standard.value(forKey: "granjaId") as? Int {
            granjaId = savedGranjaId
        }
        
        dashboardService.obtenerContadoresDashboard(granjaId: granjaId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let contadores):
                    self?.actualizarUI(con: contadores)
                case .failure(let error):
                    self?.mostrarError(error)
                }
            }
        }
    }
    
    // MARK: - UI Update
    private func actualizarUI(con contadores: DashboardContadores) {
        // Actualizar labels
        animalesLabel.text = "\(contadores.animalesActivos)"
        lotesLabel.text = "\(contadores.lotesActivos)"
        alertasLabel.text = "\(contadores.alertasCriticas)"
        
        // Formatear ventas con símbolo de moneda
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "S/ "
        formatter.maximumFractionDigits = 2
        
        if let ventasFormateadas = formatter.string(from: NSNumber(value: contadores.ventasDelMes)) {
            ventasLabel.text = ventasFormateadas
        } else {
            ventasLabel.text = "S/ \(String(format: "%.2f", contadores.ventasDelMes))"
        }
    }
    
    // MARK: - Error Handling
    private func mostrarError(_ error: Error) {
        print("  Error cargando contadores: \(error.localizedDescription)")
        
        animalesLabel.text = "0"
        lotesLabel.text = "0"
        alertasLabel.text = "0"
        ventasLabel.text = "S/ 0.00"
        
        let alert = UIAlertController(
            title: "Error",
            message: "No se pudieron cargar los datos del dashboard",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Reintentar", style: .default) { [weak self] _ in
            self?.cargarContadores()
        })
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    @objc private func refrescarDatos() {
        cargarContadores()
    }
    @objc private func alimentacionTapped() {
        animarView(alimentacionView)
        navegarA(storyboard: "Main", viewControllerID: "RegistrarAlimentacionLoteViewController")
    }
    @objc private func lotesTapped() {
        animarView(alimentacionView)
        navegarA(storyboard: "FarmFlow", viewControllerID: "ListadoLotesViewController")
    }
    @objc private func sanidadTapped() {
        animarView(sanidadView)
        navegarA(storyboard: "Main", viewControllerID: "RegistroSanitarioViewController")
    }
    
    @objc private func pesoTapped() {
        animarView(pesoView)
        navegarA(storyboard: "FarmFlow", viewControllerID: "BuscadorQRViewController")
    }
    
    @objc private func ventasTapped() {
        animarView(ventasView)
        navegarA(storyboard: "VentaComercial", viewControllerID: "VentaComercialViewController")
    }
    
    @objc private func reportesTapped() {
        animarView(reportesView)
        navegarA(storyboard: "FarmFlow", viewControllerID: "ReportesViewController")
    }
    
    @objc private func produccionTapped() {
        animarView(produccionView)
        navegarA(storyboard: "FarmFlow", viewControllerID: "RegistrarProduccionViewController")
    }
    
    private func navegarA(storyboard nombre: String, viewControllerID: String) {
        let storyboard = UIStoryboard(name: nombre, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: viewControllerID)
        navigationController?.pushViewController(vc, animated: true)
    }
    private func animarView(_ view: UIView) {
        UIView.animate(withDuration: 0.1, animations: {
            view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                view.transform = CGAffineTransform.identity
            }
        }
    }
}
