//
//  RegistroSanitarioAnimalViewController.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/19/25.
//
<<<<<<< HEAD

import UIKit

class RegistroSanitarioAnimalViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

=======
import UIKit
import AVFoundation

class RegistroSanitarioAnimalViewController: UIViewController {
    
    @IBOutlet weak var buscadorCodigoQR: UITextField!
    @IBOutlet weak var imagenAnimal: UIImageView!
    @IBOutlet weak var codigoQRLabel: UILabel!
    @IBOutlet weak var especieLabel: UILabel!
    @IBOutlet weak var loteNombreLabel: UILabel!
    @IBOutlet weak var edadEnDias: UILabel!
    
    private let dataModel = RegistroSanitarioData.shared
    private let animalesService = AnimalesService()
    
    var codigoQR: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarVista()
        
        // Si viene con código QR previo, buscarlo
        if let qr = codigoQR {
            buscadorCodigoQR.text = qr
            buscarAnimalPorQR(qr)
        }
    }
    
    private func configurarVista() {
        imagenAnimal.layer.cornerRadius = 8
        imagenAnimal.clipsToBounds = true
        imagenAnimal.contentMode = .scaleAspectFill
        
        buscadorCodigoQR.delegate = self
        buscadorCodigoQR.placeholder = "Ingrese código QR"
        
        limpiarDatosAnimal()
    }
    
    private func limpiarDatosAnimal() {
        codigoQRLabel.text = "-"
        especieLabel.text = "-"
        loteNombreLabel.text = "-"
        edadEnDias.text = "-"
        imagenAnimal.image = UIImage(systemName: "photo")
    }
    
    @IBAction func escanearCodigoQR(_ sender: UIButton) {
        verificarPermisosCamara()
    }
    
    private func verificarPermisosCamara() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            abrirEscanerQR()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.abrirEscanerQR()
                    }
                }
            }
        case .denied, .restricted:
            mostrarAlertaPermisos()
        @unknown default:
            break
        }
    }
    
    private func abrirEscanerQR() {
        let scanner = QRScannerViewController()
        scanner.delegate = self
        scanner.modalPresentationStyle = .fullScreen
        present(scanner, animated: true)
    }
    
    private func mostrarAlertaPermisos() {
        let alert = UIAlertController(
            title: "Permiso de cámara",
            message: "Por favor habilita el acceso a la cámara en Configuración",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Configuración", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alert, animated: true)
    }
    
    private func buscarAnimalPorQR(_ qr: String) {
        mostrarLoading()
        
        animalesService.obtenerAnimalPorQR(qrAnimal: qr) { [weak self] result in
            DispatchQueue.main.async {
                self?.ocultarLoading()
                
                switch result {
                case .success(let animal):
                    self?.mostrarDatosAnimal(animal)
                    
                case .failure(let error):
                    self?.mostrarError("No se encontró el animal: \(error.localizedDescription)")
                    self?.limpiarDatosAnimal()
                }
            }
        }
    }
    
    private func mostrarDatosAnimal(_ animal: AnimalResponse) {
        // Guardar en el modelo compartido
        dataModel.codigoQR = animal.codigoQr
        dataModel.animalId = animal.idAnimal
        dataModel.imagenURL = animal.fotoUrl
        dataModel.especieNombre = animal.especie
        dataModel.loteNombre = animal.lote
        dataModel.edadDias = animal.edadEnDias
        
        // Mostrar en la UI
        codigoQRLabel.text = animal.codigoQr ?? "-"
        especieLabel.text = animal.especie ?? "N/A"
        loteNombreLabel.text = animal.lote ?? "Sin lote"
        edadEnDias.text = "\(animal.edadEnDias ?? 0) días"
        
        // Cargar imagen
        if let urlString = animal.fotoUrl, let url = URL(string: urlString) {
            cargarImagen(url: url)
        }
    }
    
    private func cargarImagen(url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.imagenAnimal.image = image
                }
            }
        }.resume()
    }
    
    @IBAction func siguienteButton(_ sender: UIButton) {
        guard let qr = buscadorCodigoQR.text, !qr.isEmpty else {
            mostrarError("Por favor ingrese o escanee un código QR")
            return
        }
        
        guard dataModel.isValidoParaPaso2() else {
            mostrarError("Primero debe buscar un animal válido")
            return
        }
        
        // Navegar al paso 2
        if let paso2 = storyboard?.instantiateViewController(
            withIdentifier: "RegistroSanitarioAnimal2ViewController"
        ) as? RegistroSanitarioAnimal2ViewController {
            navigationController?.pushViewController(paso2, animated: true)
        }
    }
    
    private func mostrarLoading() {
        view.isUserInteractionEnabled = false
        // Aquí puedes agregar un activity indicator si lo tienes
    }
    
    private func ocultarLoading() {
        view.isUserInteractionEnabled = true
    }
    
    private func mostrarError(_ mensaje: String) {
        let alert = UIAlertController(title: "Error", message: mensaje, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension RegistroSanitarioAnimalViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let qr = textField.text, !qr.isEmpty {
            buscarAnimalPorQR(qr)
        }
        return true
    }
}

// MARK: - QRScannerDelegate
extension RegistroSanitarioAnimalViewController: QRScannerDelegate {
    func didScanQRCode(_ code: String) {
        buscadorCodigoQR.text = code
        buscarAnimalPorQR(code)
    }
}

// MARK: - Protocolo para el scanner
protocol QRScannerDelegate: AnyObject {
    func didScanQRCode(_ code: String)
}

// MARK: - QR Scanner (simplificado)
class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    weak var delegate: QRScannerDelegate?
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCamera()
        setupCloseButton()
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    private func setupCloseButton() {
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Cerrar", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.backgroundColor = .systemRed
        closeButton.layer.cornerRadius = 8
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(cerrarScanner), for: .touchUpInside)
        
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 80),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc private func cerrarScanner() {
        dismiss(animated: true)
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first,
           let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
           let stringValue = readableObject.stringValue {
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            delegate?.didScanQRCode(stringValue)
            dismiss(animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }
>>>>>>> c5222b3 (Subindo ultimos cambios)
}
