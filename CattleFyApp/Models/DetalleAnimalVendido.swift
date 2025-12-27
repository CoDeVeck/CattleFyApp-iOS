//
//  DetalleAnimalVendido.swift
//  CattleFyApp
//
//  Created by Victor Narazas on 21/12/25.
//


struct DetalleAnimalVendido: Codable {
    let animalId: Int
<<<<<<< HEAD
    let numeroIdentificacion: String
    let pesoActual: Double
=======
    let codigoQr: String
    let pesoActual: Double
    let costoUnitario: Double
>>>>>>> c5222b3 (Subindo ultimos cambios)
    let edad: Int?
    let sexo: String?

    enum CodingKeys: String, CodingKey {
           case animalId = "idAnimal"
<<<<<<< HEAD
            case numeroIdentificacion = "numeroIdentificacion"
            case pesoActual = "pesoActual"
            case edad = "edad"
            case sexo = "sexo"
=======
            case codigoQr = "codigoQr"
            case pesoActual = "peso"
            case edad = "edad"
            case sexo = "sexo"
            case costoUnitario = "costoUnitario"
>>>>>>> c5222b3 (Subindo ultimos cambios)
       }
}
