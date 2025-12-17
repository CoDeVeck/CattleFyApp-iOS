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
    
    func obtenerHistorialAlimentacion(completion: @escaping (Result<[RegistrarAlimentacionHistorialDTO], Error>) -> Void) {
        guard let token = getAuthToken() else {
            completion(.failure(NSError(
                domain: "", code: 401,
                userInfo: [NSLocalizedDescriptionKey: "No hay sesión activa"]
            )))
            return
        }

        guard let url = URL(string: "\(Constants.baseURL)registrarAlimentacion/listHistorial") else {
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

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(
                    domain: "", code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Respuesta inválida"]
                )))
                return
            }

            guard httpResponse.statusCode == 200 else {
                completion(.failure(NSError(
                    domain: "", code: httpResponse.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "Error HTTP: \(httpResponse.statusCode)"]
                )))
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
                let historial = try JSONDecoder().decode([RegistrarAlimentacionHistorialDTO].self, from: data)
                completion(.success(historial))
            } catch {
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

