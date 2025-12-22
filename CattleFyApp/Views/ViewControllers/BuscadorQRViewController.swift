//
//  BuscadorQRViewController.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/19/25.
//

import UIKit
import CoreImage

class BuscadorQRViewController: UIViewController {
    @IBOutlet weak var buscadorTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Actions
    @IBAction func escanearQRButton(_ sender: UIButton) {
        abrirGaleria()
    }
    
    @IBAction func buscarButton(_ sender: UIButton) {
        guard let texto = buscadorTextField.text,
              !texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            mostrarAlerta(
                titulo: "Campo vacío",
                mensaje: "Ingrese un código válido para buscar"
            )
            return
        }
        procesarCodigo(texto)
    }
}

extension BuscadorQRViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func abrirGaleria() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        picker.dismiss(animated: true)
        
        guard let imagen = info[.originalImage] as? UIImage else {
            mostrarAlerta(
                titulo: "Error",
                mensaje: "No se pudo obtener la imagen"
            )
            return
        }
        
        guard let codigoQR = decodificarQR(from: imagen) else {
            mostrarAlerta(
                titulo: "QR no válido",
                mensaje: "La imagen no contiene un código QR válido"
            )
            return
        }
        
        buscadorTextField.text = codigoQR
        procesarCodigo(codigoQR)
    }
}

extension BuscadorQRViewController {
    private func decodificarQR(from imagen: UIImage) -> String? {
        guard let ciImage = CIImage(image: imagen) else { return nil }
        
        let detector = CIDetector(
            ofType: CIDetectorTypeQRCode,
            context: nil,
            options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        )
        
        let features = detector?.features(in: ciImage) ?? []
        
        for feature in features {
            if let qrFeature = feature as? CIQRCodeFeature {
                return qrFeature.messageString
            }
        }
        
        return nil
    }
}

extension BuscadorQRViewController {
    private func procesarCodigo(_ codigo: String) {
        // Animales: QR_BOV_001, QR_OVI_001, QR_POR_001, etc.
        if codigo.hasPrefix("QR_") && !codigo.hasPrefix("QR_LOTE_") {
            irAVistaAnimal(codigo)
        }
        // Lotes: QR_LOTE_001, QR_LOTE_002, etc.
        else if codigo.hasPrefix("QR_LOTE_") {
            irAVistaLote(codigo)
        }
        else {
            mostrarAlerta(
                titulo: "Código inválido",
                mensaje: "El código no corresponde a un animal ni a un lote"
            )
        }
    }

    
    private func irAVistaAnimal(_ codigo: String) {
        guard let vc = storyboard?.instantiateViewController(
            withIdentifier: "VistaPreviaAnimalViewController"
        ) as? VistaPreviaAnimalViewController else { return }
        
        vc.codigoQR = codigo
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func irAVistaLote(_ codigo: String) {
        guard let vc = storyboard?.instantiateViewController(
            withIdentifier: "VistaPreviaLoteViewController"
        ) as? VistaPreviaLoteViewController else { return }
        
        vc.codigoQR = codigo
        navigationController?.pushViewController(vc, animated: true)
    }
}
