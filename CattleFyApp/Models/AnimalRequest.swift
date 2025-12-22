//
//  AnimalRequest.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/20/25.
//

import Foundation

struct AnimalRequest: Codable {
    let origen: String
    let idLote: Int?              // (solo para Compra)
    let codigoQrMadre: String?
    let idEspecie: Int?            //  (solo para Compra)
    let fechaNacimiento: String
    let sexo: String
    let peso: Double?
    let precioCompra: Double?
    let proveedor: String?    // Opcional (solo para Compra)
}

// MARK: - Inicializadores de conveniencia

extension AnimalRequest {
    // Inicializador para registro por COMPRA
    static func compra(
        idLote: Int,
        idEspecie: Int,
        fechaNacimiento: String,
        sexo: String,
        peso: Double?,
        precioCompra: Double?,
        codigoQrMadre: String? = nil,
        proveedor: String
    ) -> AnimalRequest {
        return AnimalRequest(
            origen: "Compra",
            idLote: idLote,
            codigoQrMadre: codigoQrMadre,
            idEspecie: idEspecie,
            fechaNacimiento: fechaNacimiento,
            sexo: sexo,
            peso: peso,
            precioCompra: precioCompra,
            proveedor: proveedor
        )
    }
    
    // Inicializador para registro por NACIMIENTO
    static func nacimiento(
        codigoQrMadre: String?,
        fechaNacimiento: String,
        sexo: String,
        peso: Double?
    ) -> AnimalRequest {
        return AnimalRequest(
            origen: "Nacimiento",
            idLote: nil,
            codigoQrMadre: codigoQrMadre,
            idEspecie: nil,
            fechaNacimiento: fechaNacimiento,
            sexo: sexo,
            peso: peso,
            precioCompra: nil,
            proveedor: nil
        )
    }
}
