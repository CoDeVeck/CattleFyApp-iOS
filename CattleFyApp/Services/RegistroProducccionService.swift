//
//  RegistroProducccionService.swift
//  CattleFyApp
//
//  Created by Andy Yahir Valdivia Centeno on 21/12/25.
//

import Foundation

class RegistroProduccionService {
    
    static let shared = RegistroProduccionService()
    
    private init() {}
    
    // MARK: - Obtener token
    private func getAuthToken() -> String? {
        return UserDefaults.standard.string(forKey: "authToken")
    }
    func obtenerHistorialProduccion(loteId: Int, completion: @escaping (Result<[RegistroProduccionDTO], Error>) -> Void) {
        guard let token = getAuthToken() else {
            completion(.failure(NSError(
                domain: "", code: 401,
                userInfo: [NSLocalizedDescriptionKey: "No hay sesión activa"]
            )))
            return
        }
        
        guard let url = URL(string: "\(Constants.baseURL)registroProduccion/listHistorial/\(loteId)") else {
            completion(.failure(NSError(
                domain: "", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "URL inválida"]
            )))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(
                    domain: "", code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "No hay datos"]
                )))
                return
            }
            
            do {
                let registros = try JSONDecoder().decode([RegistroProduccionDTO].self, from: data)
                if registros.isEmpty {
                    completion(.failure(NSError(
                        domain: "", code: 404,
                        userInfo: [NSLocalizedDescriptionKey: "No se encontraron registros"]
                    )))
                } else {
                    completion(.success(registros))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
