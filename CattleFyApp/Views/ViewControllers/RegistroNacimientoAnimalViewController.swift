//
//  RegistroNacimientoAnimalViewController.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/19/25.
//

import UIKit

class RegistroNacimientoAnimalViewController: UIViewController {
    @IBOutlet weak var imageViewAnimalMadre: UIImageView!
    @IBOutlet weak var codigoQRAnimalMadreLabel: UILabel!
    @IBOutlet weak var nombreLoteMadreLabel: UILabel!
    @IBOutlet weak var pesoKgMadre: UILabel!
    
    private let animalesService = AnimalesService()
    private var registroAnimalData = RegistroAnimalData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func escanearQRMadreAnimal(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true)
    }
    
    @IBAction func siguienteButton(_ sender: UIButton) {
        guard let codigoQrMadre = registroAnimalData.codigoQrMadre,
              !codigoQrMadre.isEmpty else {
            mostrarAlerta(mensaje: "Debe escanear el QR del animal madre primero")
            return
        }
        
        if let siguienteVC = storyboard?.instantiateViewController(
            withIdentifier: "RegistroNacimientoAnimal2ViewController"
        ) as? RegistroNacimientoAnimal2ViewController {
            siguienteVC.registroAnimalData = registroAnimalData
            navigationController?.pushViewController(siguienteVC, animated: true)
        }
    }
    
    private func procesarImagenQR(_ image: UIImage) {
        guard let ciImage = CIImage(image: image) else {
            mostrarAlerta(mensaje: "Error al procesar la imagen")
            return
        }
        
        let context = CIContext()
        let detector = CIDetector(
            ofType: CIDetectorTypeQRCode,
            context: context,
            options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        )
        
        guard let features = detector?.features(in: ciImage) as? [CIQRCodeFeature],
              let qrFeature = features.first,
              let qrString = qrFeature.messageString else {
            mostrarAlerta(mensaje: "No se detectó ningún código QR en la imagen")
            return
        }
        
        // Mostrar la imagen escaneada
        imageViewAnimalMadre.image = image
        
        // Buscar el animal por QR
        buscarAnimalPorQR(qrString)
    }
    
    private func buscarAnimalPorQR(_ codigoQr: String) {
        // Mostrar indicador de carga
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        animalesService.obtenerAnimalPorQR(qrAnimal: codigoQr) { [weak self] result in
            DispatchQueue.main.async {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                
                switch result {
                case .success(let animal):
                    self?.configurarDatosMadre(animal)
                case .failure(let error):
                    self?.mostrarAlerta(mensaje: "Error al buscar el animal: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func configurarDatosMadre(_ animal: AnimalResponse) {
        codigoQRAnimalMadreLabel.text = animal.codigoQr ?? "N/A"
        nombreLoteMadreLabel.text = animal.lote ?? "N/A"
        
        if let peso = animal.peso {
            pesoKgMadre.text = String(format: "%.2f kg", peso)
        } else {
            pesoKgMadre.text = "N/A"
        }
        
        if let fotoUrlString = animal.fotoUrl,
           let url = URL(string: fotoUrlString) {
            cargarImagenDesdeURL(url)
        } else {
            imageViewAnimalMadre.image = UIImage(systemName: "photo")
        }
        
        registroAnimalData.codigoQrMadre = animal.codigoQr
        registroAnimalData.idEspecie = animal.idEspecie ?? 0
        registroAnimalData.nombreEspecie = animal.especie ?? ""
        registroAnimalData.idLote = animal.idLote ?? 0
        registroAnimalData.nombreLote = animal.lote ?? ""
    }

    // Agrega esta propiedad a la clase
    private let imageCache = NSCache<NSString, UIImage>()

    private func cargarImagenDesdeURL(_ url: URL) {
        let urlString = url.absoluteString as NSString
        
        // Verificar si la imagen está en caché
        if let imagenCacheada = imageCache.object(forKey: urlString) {
            imageViewAnimalMadre.image = imagenCacheada
            return
        }
        
        // Mostrar placeholder mientras carga
        imageViewAnimalMadre.image = UIImage(systemName: "photo.circle")
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error al cargar imagen: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.imageViewAnimalMadre.image = UIImage(systemName: "exclamationmark.triangle")
                }
                return
            }
            
            guard let data = data,
                  let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    self.imageViewAnimalMadre.image = UIImage(systemName: "exclamationmark.triangle")
                }
                return
            }
            
            // Guardar en caché
            self.imageCache.setObject(image, forKey: urlString)
            
            // Actualizar la imagen en el hilo principal
            DispatchQueue.main.async {
                self.imageViewAnimalMadre.image = image
                self.imageViewAnimalMadre.contentMode = .scaleAspectFill
                self.imageViewAnimalMadre.clipsToBounds = true
            }
        }.resume()
    }
    
    private func mostrarAlerta(mensaje: String) {
        let alert = UIAlertController(
            title: "Atención",
            message: mensaje,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension RegistroNacimientoAnimalViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        picker.dismiss(animated: true)
        
        if let image = info[.originalImage] as? UIImage {
            procesarImagenQR(image)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
