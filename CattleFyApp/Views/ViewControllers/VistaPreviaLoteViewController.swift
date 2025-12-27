//
//  VistaPreviaLoteViewController.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/20/25.
//

import UIKit

class VistaPreviaLoteViewController: UIViewController {
    
    @IBOutlet weak var loteCodigoLabel: UILabel!
    var codigoQR: String?
    private var lote: LoteResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if codigoQR == nil {
            codigoQR = "QR_LOTE_002" // 👈 Pon aquí un código QR real de tu base de datos
        }
        cargarLote()
    }
    
    // MARK: - Data
    
    private func cargarLote() {
        guard let codigoQR = codigoQR else {
            mostrarAlerta(
                titulo: "Error",
                mensaje: "No se recibió el código del lote"
            )
            return
        }
        
        loteCodigoLabel.text = "Buscando..."
        
        LoteService.shared.obtenerLotePorQR(qrLote: codigoQR) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let lote):
                    self.lote = lote
                    
                    let codigo = lote.codigoQr
                    self.loteCodigoLabel.text = "LOTE #\(codigo)"
                    
                case .failure(let error):
                    self.mostrarAlerta(
                        titulo: "Error",
                        mensaje: error.localizedDescription
                    )
                    self.loteCodigoLabel.text = "—"
                }
            }
        }
    }
    
    @IBAction func verDetalleLoteButton(_ sender: UIButton) {
        guard let lote = lote else {
            mostrarAlerta(titulo: "Error", mensaje: "No hay datos del lote")
            return
        }
        
        let storyboard = UIStoryboard(name: "FarmFlow", bundle: nil)
        
        if let detalleVC = storyboard.instantiateViewController(
            withIdentifier: "DetalleLoteViewController"
        ) as? DetalleLoteViewController {
            
            detalleVC.loteId = lote.idLote
            
            navigationController?.pushViewController(detalleVC, animated: true)
        }
    }
    
    @IBAction func registrarAlimentacionLoteButton(_ sender: UIButton) {
        guard let lote = lote else {
            mostrarAlerta(titulo: "Error", mensaje: "No hay datos del lote")
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let alimentacionVC = storyboard.instantiateViewController(
            withIdentifier: "RegistrarAlimentacionLoteViewController"
        ) as? RegistrarAlimentacionLoteViewController else {
            mostrarAlerta(titulo: "Error", mensaje: "No se pudo cargar la vista")
            return
        }
        alimentacionVC.lotePreseleccionado = LoteSimpleDTO(
            loteId: lote.idLote,
            nombre: lote.nombre,
            cantidadAnimales: lote.animalesVivos
        )
        
        navigationController?.pushViewController(alimentacionVC, animated: true)
    }
    
    @IBAction func registrarSanitarioLoteButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            guard let sanitarioVC = storyboard.instantiateViewController(
                withIdentifier: "RegistroSanitarioMasivoViewController"
            ) as? RegistroSanitarioMasivoViewController else {
                mostrarAlerta(titulo: "Error", mensaje: "No se pudo cargar la vista")
                return
            }
            
            navigationController?.pushViewController(sanitarioVC, animated: true)
    }
    
    
    @IBAction func verListadoAnimalesDeLoteButton(_ sender: UIButton) {
    }
    
}

