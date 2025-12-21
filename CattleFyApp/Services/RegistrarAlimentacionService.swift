//
//  RegistrarAlimentacionService.swift
//  CattleFyApp
//
//  Created by Andy Yahir Valdivia Centeno on 16/12/25.
//
import Foundation

class RegistroAlimentacionService {
    static let shared = RegistroAlimentacionService()
    
    private init() {}
    
    private func getAuthToken() -> String? {
        return UserDefaults.standard.string(forKey: "authToken")
    }
    
    func obtenerHistorialAlimentacion(
        loteId: Int,
        completion: @escaping (Result<[RegistrarAlimentacionHistorialDTO], Error>) -> Void
    ) {
        
        guard let token = getAuthToken() else {
            completion(.failure(NSError(
                domain: "", code: 401,
                userInfo: [NSLocalizedDescriptionKey: "No hay sesión activa"]
            )))
            return
        }

        guard let url = URL(string: "\(Constants.baseURL)registrarAlimentacion/listHistorial/\(loteId)") else {
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
            // 1️⃣ Primero verificar si hay error de red
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // 2️⃣ Verificar que la respuesta sea HTTP válida
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(
                    domain: "", code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Respuesta inválida"]
                )))
                return
            }
            
            print("📊 Status Code: \(httpResponse.statusCode)")
            
            // 3️⃣ MANEJAR 404 - No hay registros (caso especial)
            if httpResponse.statusCode == 404 {
                completion(.success([])) // Devolver array vacío
                return
            }
            
            // 4️⃣ Verificar que sea un status code exitoso (200-299)
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(
                    domain: "", code: httpResponse.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "Error HTTP: \(httpResponse.statusCode)"]
                )))
                return
            }
            
            // 5️⃣ Verificar que haya datos
            guard let data = data else {
                completion(.failure(NSError(
                    domain: "", code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "No hay datos"]
                )))
                return
            }
            
            // 6️⃣ Decodificar el JSON
            do {
                let decoder = JSONDecoder()
                
                // Configurar formato de fecha si es necesario
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                decoder.dateDecodingStrategy = .formatted(formatter)
                
                let historial = try decoder.decode([RegistrarAlimentacionHistorialDTO].self, from: data)
                completion(.success(historial))
            } catch {
                print("❌ Error de decodificación: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }

    func registrarAlimentacion(
        request: RegistroAlimentacionRequestDTO,
        completion: @escaping (Result<RegistroAlimentacionResponse, Error>) -> Void
    ) {
        guard let token = getAuthToken() else {
            completion(.failure(NSError(
                domain: "",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "No hay sesión activa"]
            )))
            return
        }

        guard let url = URL(string: "\(Constants.baseURL)registrarAlimentacion/create") else {
            completion(.failure(NSError(
                domain: "",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "URL inválida"]
            )))
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(
                    domain: "",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "No hay datos"]
                )))
                return
            }

            do {
                let resultado = try JSONDecoder().decode(
                    ResultadoResponse<RegistroAlimentacionResponse>.self,
                    from: data
                )

                if resultado.valor, let alimentacion = resultado.data {
                    completion(.success(alimentacion))
                } else {
                    completion(.failure(NSError(
                        domain: "",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: resultado.mensaje]
                    )))
                }

            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

}

