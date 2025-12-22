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
                // Ver el JSON
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📦 JSON recibido: \(jsonString.prefix(500))")
                }
                
                let decoder = JSONDecoder()
                
                // Estrategia personalizada para manejar múltiples formatos de fecha
                decoder.dateDecodingStrategy = .custom { decoder in
                    let container = try decoder.singleValueContainer()
                    let dateString = try container.decode(String.self)
                    
                    // Formatos posibles
                    let formatters = [
                        "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",  // Con microsegundos
                        "yyyy-MM-dd'T'HH:mm:ss",         // Sin microsegundos
                        "yyyy-MM-dd"                      // Solo fecha
                    ]
                    
                    for formatString in formatters {
                        let formatter = DateFormatter()
                        formatter.dateFormat = formatString
                        formatter.locale = Locale(identifier: "en_US_POSIX")
                        formatter.timeZone = TimeZone(secondsFromGMT: 0)
                        
                        if let date = formatter.date(from: dateString) {
                            return date
                        }
                    }
                    
                    throw DecodingError.dataCorruptedError(
                        in: container,
                        debugDescription: "No se pudo parsear la fecha: \(dateString)"
                    )
                }
                
                let registros = try decoder.decode([RegistroProduccionDTO].self, from: data)
                
                print("✅ Registros decodificados: \(registros.count)")
                
                if registros.isEmpty {
                    completion(.failure(NSError(
                        domain: "", code: 404,
                        userInfo: [NSLocalizedDescriptionKey: "No se encontraron registros"]
                    )))
                } else {
                    completion(.success(registros))
                }
            } catch let DecodingError.keyNotFound(key, context) {
                print("❌ Key '\(key.stringValue)' no encontrado: \(context.debugDescription)")
                print("   CodingPath: \(context.codingPath)")
            } catch let DecodingError.typeMismatch(type, context) {
                print("❌ Type mismatch '\(type)': \(context.debugDescription)")
                print("   CodingPath: \(context.codingPath)")
            } catch let DecodingError.valueNotFound(type, context) {
                print("❌ Value not found '\(type)': \(context.debugDescription)")
                print("   CodingPath: \(context.codingPath)")
            } catch let DecodingError.dataCorrupted(context) {
                print("❌ Data corrupted: \(context.debugDescription)")
                print("   CodingPath: \(context.codingPath)")
            } catch {
                print("❌ Error desconocido: \(error.localizedDescription)")
            }
        }.resume()
    }
}
