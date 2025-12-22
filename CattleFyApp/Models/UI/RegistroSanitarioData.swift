//
//  RegistroSanitarioData.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/22/25.
//
import Foundation
import UIKit

// Modelo para compartir datos entre los 3 pasos
class RegistroSanitarioData {
    
    // MARK: - Paso 1: Datos del Animal
    var codigoQR: String?
    var animalId: Int?
    var imagenURL: String?
    var especieNombre: String?
    var loteNombre: String?
    var edadDias: Int?
    
    // MARK: - Paso 2: Datos del Protocolo
    var tipoProtocolo: String? // "Vacuna" o "Tratamiento"
    var nombreProducto: String?
    var dosisAplicada: Decimal?
    var costoUnitario: Decimal?
    var fechaAplicacion: Date?
    
    // MARK: - Singleton para compartir entre vistas
    static let shared = RegistroSanitarioData()
    
    private init() {}
    
    // MARK: - Métodos de utilidad
    
    func reset() {
        codigoQR = nil
        animalId = nil
        imagenURL = nil
        especieNombre = nil
        loteNombre = nil
        edadDias = nil
        tipoProtocolo = nil
        nombreProducto = nil
        dosisAplicada = nil
        costoUnitario = nil
        fechaAplicacion = nil
    }
    
    func toRequest() -> RegistroSanitarioRequest {
        var request = RegistroSanitarioRequest()
        
        request.qrAnimal = codigoQR
        request.tipoAplicacion = "Individual"
        request.protocoloTipo = tipoProtocolo
        request.nombreProducto = nombreProducto
        
        request.costoPorDosis = costoUnitario.map { NSDecimalNumber(decimal: $0).doubleValue }
        request.cantidadDosis = dosisAplicada.map { NSDecimalNumber(decimal: $0).doubleValue }
        
        return request
    }
    
    func isValidoParaPaso2() -> Bool {
        return codigoQR != nil && animalId != nil
    }
    
    func isValidoParaPaso3() -> Bool {
        return isValidoParaPaso2() &&
               tipoProtocolo != nil &&
               nombreProducto != nil &&
               dosisAplicada != nil &&
               costoUnitario != nil &&
               fechaAplicacion != nil
    }
}
