//
//  ReporteProduccionViewController.swift
//  CattleFyApp
//
//  Created by Victor Narazas on 17/12/25.
//

import UIKit
import SwiftUI


class ReporteProduccionViewController: UIViewController {
    
    
    @IBOutlet weak var pickerViewEspecie: UIPickerView!
    
    @IBOutlet weak var pickerViewLote: UIPickerView!
    
    @IBOutlet weak var graficoContainerDos: UIView!
    
    @IBOutlet weak var DatePickerFechaInicio: UIDatePicker!
    
    @IBOutlet weak var datePickerFechaFin: UIDatePicker!
    
    @IBOutlet weak var labelLecheTotal: UILabel!
    
    @IBOutlet weak var labelHuevosTotal: UILabel!
    
    @IBOutlet weak var labelPromedioLecheHuevos: UILabel!
    
    // MARK: - Properties
    private var viewModel: ReporteProduccionViewModel!
    private var granjaId = 1
    private var hostingController: UIHostingController<GraficoReporte2>?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewModel()
        setupUI()
        setupPickers()
        setupDatePickers()
        setupBindings()
        loadData()
    }

    // MARK: - Setup
     private func setupViewModel() {
       viewModel = ReporteProduccionViewModel(granjaId: granjaId)
     }
     
     private func setupUI() {
       limpiarEstadisticas()
       setupChart(with: [])
     }
     
     private func setupPickers() {
       pickerViewLote.delegate = self
       pickerViewLote.dataSource = self
       
       pickerViewEspecie.delegate = self
       pickerViewEspecie.dataSource = self
     }
     
     private func setupDatePickers() {
       datePickerFechaFin.date = Date()
       
       // Fecha inicio: 30 días atrás
       let calendar = Calendar.current
       if let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date()) {
         DatePickerFechaInicio.date = thirtyDaysAgo
       }
       
       DatePickerFechaInicio.addTarget(self, action: #selector(fechaChanged), for: .valueChanged)
       datePickerFechaFin.addTarget(self, action: #selector(fechaChanged), for: .valueChanged)
     }
     
     private func setupBindings() {
       viewModel.onLotesUpdated = { [weak self] in
         self?.pickerViewLote.reloadAllComponents()
       }
       
       viewModel.onCategoriasUpdated = { [weak self] in
         self?.pickerViewEspecie.reloadAllComponents()
       }
       
       viewModel.onReporteUpdated = { [weak self] reporte in
         self?.actualizarEstadisticas(reporte)
       }
       
       viewModel.onGraficoUpdated = { [weak self] datos in
         self?.setupChart(with: datos)
       }
       
       viewModel.onError = { [weak self] mensaje in
         self?.showAlert(message: mensaje)
       }
       
       viewModel.isLoading = { isLoading in
         UIApplication.shared.isNetworkActivityIndicatorVisible = isLoading
       }
     }
     
     private func loadData() {
       viewModel.fetchLotes()
       aplicarFiltros()
     }
     
     // MARK: - Setup Chart
     private func setupChart(with datos: [ReporteGrafico2]) {
       if let existingController = hostingController {
         existingController.willMove(toParent: nil)
         existingController.view.removeFromSuperview()
         existingController.removeFromParent()
       }
       
       // Crear nuevo gráfico
       let swiftUIView = GraficoReporte2(datos: datos)
       let newHostingController = UIHostingController(rootView: swiftUIView)
       
       addChild(newHostingController)
       
       let hostedView = newHostingController.view!
       hostedView.translatesAutoresizingMaskIntoConstraints = false
         graficoContainerDos.addSubview(hostedView)
       
       NSLayoutConstraint.activate([
         hostedView.topAnchor.constraint(equalTo: graficoContainerDos.topAnchor),
         hostedView.bottomAnchor.constraint(equalTo: graficoContainerDos.bottomAnchor),
         hostedView.leadingAnchor.constraint(equalTo: graficoContainerDos.leadingAnchor),
         hostedView.trailingAnchor.constraint(equalTo: graficoContainerDos.trailingAnchor)
       ])
       
       newHostingController.didMove(toParent: self)
       hostingController = newHostingController
     }
     
     // MARK: - Actions
     @objc private func fechaChanged() {
       aplicarFiltros()
     }
     
     private func aplicarFiltros() {
       let loteRow = pickerViewLote.selectedRow(inComponent: 0)
       let loteId = viewModel.getLoteId(at: loteRow)
       
       let especieRow = pickerViewEspecie.selectedRow(inComponent: 0)
       let categoriaId = viewModel.getCategoriaId(at: especieRow)
       
       viewModel.aplicarFiltros(
         loteId: loteId,
         categoriaId: categoriaId,
         fechaInicio: DatePickerFechaInicio.date,
         fechaFin: datePickerFechaFin.date
       )
     }
     
     // MARK: - Update UI
     private func actualizarEstadisticas(_ reporte: ReporteProduccionReproduccion) {

       labelLecheTotal.text = String(format: "%.2f L", reporte.totalDeLecha)
       
    
       labelHuevosTotal.text = String(format: "%.0f unidades", reporte.totalDeHuevos)
       

       labelPromedioLecheHuevos.text = String(format: "Leche: %.2f L/día | Huevos: %.2f u/día",
                                              reporte.promedioLechesPorDia,
                                              reporte.promedioHuevosPorDia)
     }
     
     private func limpiarEstadisticas() {
       labelLecheTotal.text = "0.0 L"
       labelHuevosTotal.text = "0 unidades"
       labelPromedioLecheHuevos.text = "0.0 L/día | 0.0 u/día"
     }
     
     private func showAlert(message: String) {
       let alert = UIAlertController(title: "Información", message: message, preferredStyle: .alert)
       alert.addAction(UIAlertAction(title: "Aceptar", style: .default))
       present(alert, animated: true)
     }
   
}
// MARK: - UIPickerView DataSource
extension ReporteProduccionViewController: UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    if pickerView == pickerViewLote {
      return viewModel.numberOfLotes
    } else if pickerView == pickerViewEspecie {
      return viewModel.numberOfCategorias
    }
    return 0
  }
}

// MARK: - UIPickerView Delegate
extension ReporteProduccionViewController: UIPickerViewDelegate {
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    if pickerView == pickerViewLote {
      return viewModel.getLoteNombre(at: row)
    } else if pickerView == pickerViewEspecie {
      return viewModel.getCategoriaNombre(at: row)
    }
    return nil
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    aplicarFiltros()
  }
}


