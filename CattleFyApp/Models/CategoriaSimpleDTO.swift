//
//  CategoriaSimpleDTO.swift
//  CattleFyApp
//
//  Created by Victor Narazas on 20/12/25.
//

import Foundation

struct CategoriaSimpleDTO: Codable {
  let categoriaId: Int
  let nombre: String
  
  enum CodingKeys: String, CodingKey {
    case categoriaId = "categoria_id"
    case nombre
  }
}
