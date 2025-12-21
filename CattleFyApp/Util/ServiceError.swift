//
//  ServiceError.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/20/25.
//

import Foundation

enum ServiceError: LocalizedError {
    case urlInvalida
    case sinDatos
    case respuestaInvalida

    var errorDescription: String? {
        switch self {
        case .urlInvalida:
            return "La URL del servicio es inválida"
        case .sinDatos:
            return "No se recibieron datos del servidor"
        case .respuestaInvalida:
            return "Respuesta inválida del servidor"
        }
    }
}
