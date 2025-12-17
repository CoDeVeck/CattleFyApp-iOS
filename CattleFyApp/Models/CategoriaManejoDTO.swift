//
//  CategoriaManejoDTO.swift
//  CattleFyApp
//
//  Created by Andy Yahir Valdivia Centeno on 16/12/25.
//

struct CategoriaManejoResponse: Codable, Identifiable {
    let categoriaId: Int
    let nombre: String
    let tipoLote: String

    var id: Int { categoriaId }
}

