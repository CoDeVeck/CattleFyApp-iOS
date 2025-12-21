//
//  CreacionDeGranjaViewController.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/7/25.
//

import UIKit
import CoreLocation
import GoogleMaps

class CreacionDeGranjaViewController: UIViewController {
    
    
    
    @IBOutlet weak var nombreTextField: UITextField!
    
    
    @IBOutlet weak var distritoTextField: UITextField!
    
    
    @IBOutlet weak var direccionTextField: UITextField!
    
    
    
    @IBOutlet weak var mapsImageView: UIImageView!
    
    
    
    @IBOutlet weak var crearButton: UIButton!
    
    private var vistaDelMapa: GMSMapView!
        private var administradorDeUbicacion: CLLocationManager!
        private var marcadorActual: GMSMarker?
        
        // Variables para guardar la ubicación seleccionada
        private var latitudSeleccionada: Double?
        private var longitudSeleccionada: Double?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configurarAdministradorDeUbicacion()
        configurarGoogleMaps()
        configurarUI()
    }
    
    private func
    configurarAdministradorDeUbicacion() {
            administradorDeUbicacion = CLLocationManager()
            administradorDeUbicacion.delegate = self
            administradorDeUbicacion.desiredAccuracy = kCLLocationAccuracyBest
            
            // Solicitar permisos de ubicación
            administradorDeUbicacion.requestWhenInUseAuthorization()
        }
        
        // MARK: - Configurar Google Maps
        private func configurarGoogleMaps() {
            // Crear el mapa con una ubicación por defecto (Lima, Perú)
            let camara = GMSCameraPosition.camera(
                withLatitude: -12.0464,
                longitude: -77.0428,
                zoom: 12.0
            )
            
            vistaDelMapa = GMSMapView.map(withFrame: mapsImageView.bounds, camera: camara)
            vistaDelMapa.delegate = self
            vistaDelMapa.isMyLocationEnabled = true
            vistaDelMapa.settings.myLocationButton = true
            vistaDelMapa.settings.compassButton = true
            vistaDelMapa.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            // Reemplazar el ImageView con el mapa
            mapsImageView.addSubview(vistaDelMapa)
            
            // Configurar gesto de toque para seleccionar ubicación
            vistaDelMapa.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(mapaTocado(_:)))
            )
        }
        
        // MARK: - Configurar UI
        private func configurarUI() {
            // Configurar el botón
            crearButton.layer.cornerRadius = 8
            
            // Hacer que los TextFields no sean editables desde teclado
            direccionTextField.isUserInteractionEnabled = false
            
            // Ocultar el teclado al tocar fuera
            let gestoToque = UITapGestureRecognizer(target: self, action: #selector(ocultarTeclado))
            view.addGestureRecognizer(gestoToque)
        }
    
    @objc private func ocultarTeclado() {
           view.endEditing(true)
       }

    @objc private func mapaTocado(_ gesto: UITapGestureRecognizer) {
           let ubicacion = gesto.location(in: vistaDelMapa)
           let coordenada = vistaDelMapa.projection.coordinate(for: ubicacion)
           
           // Guardar coordenadas
           latitudSeleccionada = coordenada.latitude
           longitudSeleccionada = coordenada.longitude
           
           // Actualizar o crear marcador
           if marcadorActual == nil {
               marcadorActual = GMSMarker()
               marcadorActual?.map = vistaDelMapa
           }
           
           marcadorActual?.position = coordenada
           marcadorActual?.title = "Ubicación seleccionada"
           
           // Animar cámara hacia el marcador
           vistaDelMapa.animate(toLocation: coordenada)
           
           // Obtener la dirección desde las coordenadas
           obtenerDireccionDesdeCoordenadas(latitud: coordenada.latitude, longitud: coordenada.longitude)
       }
       
       // MARK: - Geocoding Inverso (Coordenadas → Dirección)
       private func obtenerDireccionDesdeCoordenadas(latitud: Double, longitud: Double) {
           let geocodificador = GMSGeocoder()
           let coordenada = CLLocationCoordinate2D(latitude: latitud, longitude: longitud)
           
           geocodificador.reverseGeocodeCoordinate(coordenada) { [weak self] respuesta, error in
               guard let self = self else { return }
               
               if let error = error {
                   print("Error en geocoding: \(error.localizedDescription)")
                   self.direccionTextField.text = "No se pudo obtener la dirección"
                   return
               }
               
               if let direccion = respuesta?.firstResult() {
                   // Construir dirección completa
                   var componentesDireccion: [String] = []
                   
                   if let calle = direccion.thoroughfare {
                       componentesDireccion.append(calle)
                   }
                   if let subLocalidad = direccion.subLocality {
                       componentesDireccion.append(subLocalidad)
                   }
                   if let localidad = direccion.locality {
                       componentesDireccion.append(localidad)
                   }
                   
                   let direccionCompleta = componentesDireccion.joined(separator: ", ")
                   
                   DispatchQueue.main.async {
                       self.direccionTextField.text = direccionCompleta.isEmpty ? "Dirección no disponible" : direccionCompleta
                       
                       // Actualizar distrito si está disponible
                       if let localidad = direccion.locality {
                           self.distritoTextField.text = localidad
                       }
                   }
                   
                   print("Dirección obtenida: \(direccionCompleta)")
               }
           }
       }
    
    
    @IBAction func crearButtonTapped(_ sender: UIButton) {
        
        guard let nombre = nombreTextField.text, !nombre.isEmpty else {
            mostrarAlerta(mensaje: "Por favor ingresa el nombre de la granja")
            return
        }
        
        guard let direccion = direccionTextField.text, !direccion.isEmpty else {
            mostrarAlerta(mensaje: "Por favor selecciona una ubicación en el mapa")
            return
        }
        
        guard let lat = latitudSeleccionada, let lng = longitudSeleccionada else {
            mostrarAlerta(mensaje: "Por favor selecciona una ubicación en el mapa")
            return
        }
        
        // Mostrar loading
        crearButton.isEnabled = false
        crearButton.setTitle("Creando...", for: .normal)
        
        // Llamar al servicio
        GranjaService.shared.registrarGranja(
            nombre: nombre,
            direccion: direccion,
            latitud: lat,
            longitud: lng
        ) { [weak self] resultado in
            DispatchQueue.main.async {
                self?.crearButton.isEnabled = true
                self?.crearButton.setTitle("Crear Granja", for: .normal)
                
                switch resultado {
                case .success(let granja):
                    print("Granja creada: \(granja.nombre)")
                    self?.mostrarExito(mensaje: "Granja creada exitosamente") {
                        // Volver a la pantalla anterior
                        self?.navigationController?.popViewController(animated: true)
                    }
                    
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                    self?.mostrarAlerta(mensaje: "Error al crear granja: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Helpers
       private func mostrarAlerta(mensaje: String) {
           let alerta = UIAlertController(title: "Atención", message: mensaje, preferredStyle: .alert)
           alerta.addAction(UIAlertAction(title: "OK", style: .default))
           present(alerta, animated: true)
       }
       
       private func mostrarExito(mensaje: String, completado: @escaping () -> Void) {
           let alerta = UIAlertController(title: "Éxito", message: mensaje, preferredStyle: .alert)
           alerta.addAction(UIAlertAction(title: "OK", style: .default) { _ in
               completado()
           })
           present(alerta, animated: true)
       }
}


// MARK: - CLLocationManagerDelegate
extension CreacionDeGranjaViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let ubicacion = locations.first else { return }
        
        // Centrar el mapa en la ubicación actual
        let camara = GMSCameraPosition.camera(
            withLatitude: ubicacion.coordinate.latitude,
            longitude: ubicacion.coordinate.longitude,
            zoom: 15.0
        )
        
        vistaDelMapa.animate(to: camara)
        
        // Detener actualizaciones
        administradorDeUbicacion.stopUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            administradorDeUbicacion.startUpdatingLocation()
            vistaDelMapa.isMyLocationEnabled = true
            
        case .denied, .restricted:
            print("Permisos de ubicación denegados")
            mostrarAlerta(mensaje: "Necesitamos acceso a tu ubicación para mostrar el mapa. Ve a Ajustes > Privacidad > Ubicación")
            
        default:
            break
        }
    }
}

// MARK: - GMSMapViewDelegate
extension CreacionDeGranjaViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        // Mostrar info del marcador
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        // Este método se ejecuta automáticamente, pero usamos el gesture recognizer
    }
}
