//
//  RegistroAnimalData.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/20/25.
//

import Foundation
import UIKit

struct RegistroAnimalData {
    var origen: String = ""
    var idLote: Int = 0
    var nombreLote: String = ""
    var codigoQrMadre: String?
    var idEspecie: Int = 0
    var nombreEspecie: String = ""
    var fechaNacimiento: String = ""
    var sexo: String = ""
    var peso: Double?
    var precioCompra: Double?
    var imagen: UIImage?
    var proveedor: String?
}
