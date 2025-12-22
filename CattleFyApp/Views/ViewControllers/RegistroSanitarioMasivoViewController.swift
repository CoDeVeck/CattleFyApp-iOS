//
//  RegistroSanitarioMasivoViewController.swift
//  CattleFyApp
//
//  Created by Andy Yahir Valdivia Centeno on 11/12/25.
//

import UIKit

class RegistroSanitarioMasivoViewController: UIViewController {
    
    @IBOutlet weak var lotesPickerView: UIPickerView!
    
    @IBOutlet weak var siguienteButton: UIButton!
    
    private var lotes: [LoteSimpleDTO] = []
    private var loteSeleccionado: LoteSimpleDTO?
    private let apiService = LoteService.shared
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lotesPickerView.delegate = self
        lotesPickerView.dataSource = self
        
        cargarLotes()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func cargarLotes() {
        lotesPickerView.isHidden = true
        
        apiService.obtenerLotesSimples { [weak self] result in
            DispatchQueue.main.async {
                self?.lotesPickerView.isHidden = false
                
                switch result {
                case .success(let lotes):
                    self?.lotes = lotes
                    self?.lotesPickerView.reloadAllComponents()
                case .failure(let error):
                    self?.mostrarAlerta(mensaje:"Error al cargar lotes: \(error.localizedDescription)")
                }
            }
        }
    }
    @IBAction func siguenteButtonTapped(_ sender: UIButton) {
        guard let lote = loteSeleccionado else { return }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let datosVC = storyboard.instantiateViewController(
                withIdentifier: "RegistroSanitarioMasivoPt2ViewController"
            ) as! RegistroSanitarioMasivoPt2ViewController

            var data = RegistroSanitarioUIData()
            data.idLote = lote.loteId
            data.animalesTratados = lote.cantidadAnimales
            datosVC.registroData = data
            
            navigationController?.pushViewController(datosVC, animated: true)
    }
}

extension RegistroSanitarioMasivoViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return lotes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard row < lotes.count else { return nil}
        return lotes[row].nombre
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard row < lotes.count else { return }
        loteSeleccionado = lotes[row]
    }
}
