//
//  ReporteEngordeViewController.swift
//  CattleFyApp
//
//  Created by Victor Narazas on 17/12/25.
//

import UIKit
import SwiftUI

class ReporteEngordeViewController: UIViewController {
    
    
    @IBOutlet weak var pickerViewEspecie: UIPickerView!
    
    @IBOutlet weak var graficoContainerOne: UIView!
    
    @IBOutlet weak var pickerViewLote: UIPickerView!
    
    @IBOutlet weak var pickerViewFechaInicio: UIDatePicker!
    
    @IBOutlet weak var pickerViewFechaFin: UIDatePicker!
    
    @IBOutlet weak var labelTotalKg: UILabel!
    
    @IBOutlet weak var labelPromedioAnimal: UILabel!
    

    // MARK: - Properties
    private var viewModel: ReporteEngordeViewModel!
    private var granjaId = 1 // Esto debe venir del login o vista anterior
    private var hostingController: UIHostingController<GraficoReporte1>?
    
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
      viewModel = ReporteEngordeViewModel(granjaId: granjaId)
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
      pickerViewFechaFin.date = Date()
      

      let calendar = Calendar.current
      if let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date()) {
        pickerViewFechaInicio.date = thirtyDaysAgo
      }
      
      pickerViewFechaInicio.addTarget(self, action: #selector(fechaChanged), for: .valueChanged)
      pickerViewFechaFin.addTarget(self, action: #selector(fechaChanged), for: .valueChanged)
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
    private func setupChart(with datos: [ReporteGrafico1]) {
      // Remover hosting controller anterior
      if let existingController = hostingController {
        existingController.willMove(toParent: nil)
        existingController.view.removeFromSuperview()
        existingController.removeFromParent()
      }
      
      // Crear nuevo gráfico
      let swiftUIView = GraficoReporte1(datos: datos)
      let newHostingController = UIHostingController(rootView: swiftUIView)
      
      addChild(newHostingController)
      
      let hostedView = newHostingController.view!
      hostedView.translatesAutoresizingMaskIntoConstraints = false
      graficoContainerOne.addSubview(hostedView)
      
      NSLayoutConstraint.activate([
        hostedView.topAnchor.constraint(equalTo: graficoContainerOne.topAnchor),
        hostedView.bottomAnchor.constraint(equalTo: graficoContainerOne.bottomAnchor),
        hostedView.leadingAnchor.constraint(equalTo: graficoContainerOne.leadingAnchor),
        hostedView.trailingAnchor.constraint(equalTo: graficoContainerOne.trailingAnchor)
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
        fechaInicio: pickerViewFechaInicio.date,
        fechaFin: pickerViewFechaFin.date
      )
    }
    
    // MARK: - Update UI
    private func actualizarEstadisticas(_ reporte: ReporteProduccionEngordeDTO) {
 
        labelTotalKg.text = String(format: "%.2f kg", reporte.gananciaKg)
      
      // Promedio por Animal
        labelPromedioAnimal.text = String(format: "%.2f kg/día", reporte.pesoPromedio)
    }
    
    private func limpiarEstadisticas() {
      labelTotalKg.text = "0.0 kg"
      labelPromedioAnimal.text = "0.0 kg/día"
    }
    
    private func showAlert(message: String) {
      let alert = UIAlertController(title: "Información", message: message, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Aceptar", style: .default))
      present(alert, animated: true)
    }
   
}

// MARK: - UIPickerView DataSource
extension ReporteEngordeViewController: UIPickerViewDataSource {
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
extension ReporteEngordeViewController: UIPickerViewDelegate {
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
