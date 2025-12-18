//
//  ResultadoResponse.swift
//  CattleFyApp
//
//  Created by Andy Yahir Valdivia Centeno on 16/12/25.
//

struct ResultadoResponse<T: Codable>: Codable {
    let valor: Bool
    let mensaje: String
    let data: T?

    // Inicializador base
    init(valor: Bool, mensaje: String, data: T? = nil) {
        self.valor = valor
        self.mensaje = mensaje
        self.data = data
    }

    // MARK: - Success
    static func success(mensaje: String, data: T) -> ResultadoResponse<T> {
        return ResultadoResponse(valor: true, mensaje: mensaje, data: data)
    }

    static func success(mensaje: String) -> ResultadoResponse<T> {
        return ResultadoResponse(valor: true, mensaje: mensaje, data: nil)
    }

    // MARK: - Error
    static func error(mensaje: String) -> ResultadoResponse<T> {
        return ResultadoResponse(valor: false, mensaje: mensaje, data: nil)
    }

    static func error(mensaje: String, data: T) -> ResultadoResponse<T> {
        return ResultadoResponse(valor: false, mensaje: mensaje, data: data)
    }
}
