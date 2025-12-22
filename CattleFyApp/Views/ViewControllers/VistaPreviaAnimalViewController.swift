//
//  VistaPreviaAnimalViewController.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/20/25.
//

import UIKit

class VistaPreviaAnimalViewController: UIViewController {

    
    @IBOutlet weak var animalCodigoLabel: UILabel!
    
    var codigoQR: String?
    private var animal: AnimalResponse?

        override func viewDidLoad() {
            super.viewDidLoad()
            cargarAnimal()
        }

        // MARK: - Data

        private func cargarAnimal() {
            guard let codigoQR = codigoQR else {
                mostrarAlerta(
                    titulo: "Error",
                    mensaje: "No se recibió el código del animal"
                )
                return
            }

            animalCodigoLabel.text = "Buscando..."

            AnimalesService.shared.obtenerAnimalPorQR(qrAnimal: codigoQR) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }

                    switch result {
                    case .success(let animal):
                        self.animal = animal
                        
                        let codigo = animal.codigoQr ?? codigoQR
                        self.animalCodigoLabel.text = "ANIMAL #\(codigo)"

                    case .failure(let error):
                        self.mostrarAlerta(
                            titulo: "Error",
                            mensaje: error.localizedDescription
                        )
                        self.animalCodigoLabel.text = "—"
                    }
                }
            }
        }
    
    @IBAction func verDetalleAnimalButton(_ sender: UIButton) {
        guard let vc = storyboard?.instantiateViewController(
            withIdentifier: "DetalleAnimalViewController"
        ) as? DetalleAnimalViewController else { return }
        
        vc.codigoQR = codigoQR
        navigationController?.pushViewController(vc, animated: true)
    }
    

    @IBAction func registrarPesajeAnimalButton(_ sender: UIButton) {
        
        guard let vc = storyboard?.instantiateViewController(
            withIdentifier: "RegistrarPesajeAnimalViewController"
        ) as? RegistrarPesajeAnimalViewController else { return }
        
        vc.codigoQR = codigoQR
        navigationController?.pushViewController(vc, animated: true)

    }
    
    @IBAction func registrarSanitarioAnimalButton(_ sender: UIButton) {
        let farmFlowStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let vc = farmFlowStoryboard.instantiateViewController(
            withIdentifier: "RegistroSanitarioAnimalViewController"
        ) as? RegistroSanitarioAnimalViewController else { return }
        
        vc.codigoQR = codigoQR
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func registrarTrasladoAnimalButton(_ sender: UIButton) {
        guard let vc = storyboard?.instantiateViewController(
            withIdentifier: "TrasladoAnimalViewController"
        ) as? TrasladoAnimalViewController else { return }
        
        vc.codigoQR = codigoQR
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func registrarMuerteAnimalButton(_ sender: UIButton) {
        guard let vc = storyboard?.instantiateViewController(
            withIdentifier: "RegistroMuerteViewController"
        ) as? RegistroMuerteViewController else { return }
        
        vc.codigoQR = codigoQR
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

extension UIViewController {

    func mostrarAlerta(titulo: String, mensaje: String) {
        let alert = UIAlertController(
            title: titulo,
            message: mensaje,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
