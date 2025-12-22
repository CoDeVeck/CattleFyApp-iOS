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
    }
    
    @IBAction func registrarAlimentacionLoteButton(_ sender: UIButton) {
    }
    
    
    @IBAction func registrarSanitarioLoteButton(_ sender: UIButton) {
    }
    
    
    @IBAction func verListadoAnimalesDeLoteButton(_ sender: UIButton) {
    }
    
}


