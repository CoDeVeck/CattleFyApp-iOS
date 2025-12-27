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
        print("✅ BuscadorQRViewController cargado")
    }
    
    // MARK: - Actions
    @IBAction func escanearQRButton(_ sender: UIButton) {
        print("🔍 Botón escanear presionado")
        abrirGaleria()
    }
    
    @IBAction func buscarButton(_ sender: UIButton) {
        print("🔍 Botón buscar presionado")
        guard let texto = buscadorTextField.text,
              !texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("⚠️ Campo de texto vacío")
            mostrarAlerta(
                titulo: "Campo vacío",
                mensaje: "Ingrese un código válido para buscar"
            )
            return
        }
        print("📝 Texto ingresado: '\(texto)'")
        procesarCodigo(texto)
    }
}

extension BuscadorQRViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func abrirGaleria() {
        print("📱 Abriendo galería...")
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        print("🖼️ Imagen seleccionada de la galería")
        picker.dismiss(animated: true)
        
        guard let imagen = info[.originalImage] as? UIImage else {
            print("❌ No se pudo obtener la imagen del info")
            mostrarAlerta(
                titulo: "Error",
                mensaje: "No se pudo obtener la imagen"
            )
            return
        }
        
        print("✅ Imagen obtenida correctamente")
        print("📐 Tamaño de imagen: \(imagen.size)")
        
        guard let codigoQR = decodificarQR(from: imagen) else {
            print("❌ No se pudo decodificar el QR de la imagen")
            mostrarAlerta(
                titulo: "QR no válido",
                mensaje: "La imagen no contiene un código QR válido"
            )
            return
        }
        
        print("✅ Código QR decodificado: '\(codigoQR)'")
        buscadorTextField.text = codigoQR
        procesarCodigo(codigoQR)
    }
}

extension BuscadorQRViewController {
    private func decodificarQR(from imagen: UIImage) -> String? {
        print("🔎 Iniciando decodificación de QR...")
        
        guard let ciImage = CIImage(image: imagen) else {
            print("❌ No se pudo crear CIImage desde UIImage")
            return nil
        }
        
        print("✅ CIImage creado correctamente")
        
        let detector = CIDetector(
            ofType: CIDetectorTypeQRCode,
            context: nil,
            options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        )
        
        guard let detector = detector else {
            print("❌ No se pudo crear el detector de QR")
            return nil
        }
        
        print("✅ Detector de QR creado")
        
        let features = detector.features(in: ciImage)
        print("📊 Número de features detectados: \(features.count)")
        
        for (index, feature) in features.enumerated() {
            print("🔍 Feature #\(index): \(type(of: feature))")
            
            if let qrFeature = feature as? CIQRCodeFeature {
                if let mensaje = qrFeature.messageString {
                    print("✅ QR decodificado exitosamente: '\(mensaje)'")
                    return mensaje
                } else {
                    print("⚠️ QR Feature sin mensaje")
                }
            }
        }
        
        print("❌ No se encontró ningún código QR válido en la imagen")
        return nil
    }
}

extension BuscadorQRViewController {
    private func procesarCodigo(_ codigo: String) {
        print("⚙️ Procesando código: '\(codigo)'")
        
        // Animales: QR_BOV_001, QR_OVI_001, QR_POR_001, etc.
        if codigo.hasPrefix("QR_") && !codigo.hasPrefix("QR_LOTE_") {
            print("🐄 Código identificado como ANIMAL")
            irAVistaAnimal(codigo)
        }
        // Lotes: QR_LOTE_001, QR_LOTE_002, etc.
        else if codigo.hasPrefix("QR_LOTE_") {
            print("📦 Código identificado como LOTE")
            irAVistaLote(codigo)
        }
        else {
            print("❌ Código no reconocido como animal ni lote")
            mostrarAlerta(
                titulo: "Código inválido",
                mensaje: "El código no corresponde a un animal ni a un lote"
            )
        }
    }
    
    private func irAVistaAnimal(_ codigo: String) {
        print("🐄 Navegando a vista de animal con código: '\(codigo)'")
        guard let vc = storyboard?.instantiateViewController(
            withIdentifier: "VistaPreviaAnimalViewController"
        ) as? VistaPreviaAnimalViewController else {
            print("❌ No se pudo instanciar VistaPreviaAnimalViewController")
            return
        }
        
        vc.codigoQR = codigo
        print("✅ Código QR asignado a VistaPreviaAnimalViewController")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func irAVistaLote(_ codigo: String) {
        print("📦 Navegando a vista de lote con código: '\(codigo)'")
        guard let vc = storyboard?.instantiateViewController(
            withIdentifier: "VistaPreviaLoteViewController"
        ) as? VistaPreviaLoteViewController else {
            print("❌ No se pudo instanciar VistaPreviaLoteViewController")
            return
        }
        
        vc.codigoQR = codigo
        print("✅ Código QR asignado a VistaPreviaLoteViewController: '\(codigo)'")
        navigationController?.pushViewController(vc, animated: true)
    }
}
