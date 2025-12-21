//
//  GranjaService.swift
//  CattleFyApp
//
//  Created by Fernando on 21/12/25.
//
import Foundation

class GranjaService {
    static let shared = GranjaService()
    
    private init() {}
    
    // MARK: - Helper para obtener el token
    private func getAuthToken() -> String? {
        return UserDefaults.standard.string(forKey: "authToken")
    }
    
    // MARK: - Helper para obtener el usuario ID
    private func getUserId() -> Int? {
        return UserDefaults.standard.integer(forKey: "userId")
    }
    
    // MARK: - Registrar Granja (POST /granja/registrar)
    func registrarGranja(
        nombre: String,
        direccion: String,
        latitud: Double,
        longitud: Double,
        completion: @escaping (Result<GranjaResponse, Error>) -> Void
    ) {
        guard let token = getAuthToken() else {
            completion(.failure(NSError(
                domain: "", code: 401,
                userInfo: [NSLocalizedDescriptionKey: "No hay sesión activa"]
            )))
            return
        }
        
        guard let userId = getUserId(), userId > 0 else {
            completion(.failure(NSError(
                domain: "", code: 401,
                userInfo: [NSLocalizedDescriptionKey: "Usuario no identificado"]
            )))
            return
        }
        
        guard let url = URL(string: "\(Constants.baseURL)granja/registrar") else {
            completion(.failure(NSError(
                domain: "", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "URL inválida"]
            )))
            return
        }
        
        // Crear el request
        let granjaRequest = GranjaRequest(
            usuarioId: userId,
            nombre: nombre,
            direccion: direccion,
            latitud: latitud,
            longitud: longitud
        )
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let jsonData = try JSONEncoder().encode(granjaRequest)
            urlRequest.httpBody = jsonData
            
            print("Enviando petición a: \(url)")
            print( "Body: \(String(data: jsonData, encoding: .utf8) ?? "")")
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print("Error de red: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            // Verificar código de respuesta HTTP
            if let httpResponse = response as? HTTPURLResponse {
                print("Código de respuesta: \(httpResponse.statusCode)")
                
                switch httpResponse.statusCode {
                case 401:
                    completion(.failure(NSError(
                        domain: "", code: 401,
                        userInfo: [NSLocalizedDescriptionKey: "Sesión expirada"]
                    )))
                    return
                case 403:
                    completion(.failure(NSError(
                        domain: "", code: 403,
                        userInfo: [NSLocalizedDescriptionKey: "No tienes permisos"]
                    )))
                    return
                default:
                    break
                }
            }
            
            guard let data = data else {
                completion(.failure(NSError(
                    domain: "", code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "No hay datos"]
                )))
                return
            }
            
            // Debug: Imprimir respuesta
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Respuesta recibida: \(jsonString)")
            }
            
            do {
                let resultado = try JSONDecoder().decode(ResultadoResponse<GranjaResponse>.self, from: data)
                
                if resultado.valor, let granjaData = resultado.data {
                    print("Granja creada exitosamente: \(granjaData.nombre)")
                    completion(.success(granjaData))
                } else {
                    let errorMsg = resultado.mensaje
                    completion(.failure(NSError(
                        domain: "",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: errorMsg]
                    )))
                }
            } catch {
                print("Error al decodificar: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
}
