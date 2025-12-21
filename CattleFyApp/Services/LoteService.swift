//
//  LoteService.swift
//  CattleFyApp
//
//  Created by Andy Yahir Valdivia Centeno on 16/12/25.
//
import Foundation

class LoteService {
    static let shared = LoteService()
    
    private init() {}
    
    // MARK: - Helper para obtener el token
    private func getAuthToken() -> String? {
        return UserDefaults.standard.string(forKey: "authToken")
    }
    
    func obtenerLotesSimples(completion: @escaping (Result<[LoteSimpleDTO], Error>) -> Void) {
        guard let token = getAuthToken() else {
            completion(.failure(NSError(
                domain: "", code: 401,
                userInfo: [NSLocalizedDescriptionKey: "No hay sesión activa"]
            )))
            return
        }

        guard let url = URL(string: "\(Constants.baseURL)lotes/list-simple") else {
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
                let resultado = try JSONDecoder().decode(ResultadoResponse<[LoteSimpleDTO]>.self, from: data)
                if resultado.valor, let lotes = resultado.data{
                    completion(.success(lotes))
                } else {
                    completion(.failure(NSError(domain: "", code: -1)))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func listarLotes(
        granjaId: Int? = nil,
        especieId: Int? = nil,
        tipoLote: String? = nil,
        completion: @escaping (Result<ResultadoResponse<[LoteResponse]>, Error>) -> Void
    ) {
        
        guard let token = getAuthToken() else {
            completion(.failure(NSError(
                domain: "", code: 401,
                userInfo: [NSLocalizedDescriptionKey: "No hay sesión activa"]
            )))
            return
        }
        
        var components = URLComponents(string: "\(Constants.baseURL)lotes/listFiltro")
        
        var queryItems: [URLQueryItem] = []
        
        if let granjaId = granjaId {
            queryItems.append(URLQueryItem(name: "granjaId", value: "\(granjaId)"))
        }
        
        if let especieId = especieId {
            queryItems.append(URLQueryItem(name: "especieId", value: "\(especieId)"))
        }
        
        if let tipoLote = tipoLote {
            queryItems.append(URLQueryItem(name: "tipoLote", value: tipoLote))
        }
        
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
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
                let result = try JSONDecoder().decode(ResultadoResponse<[LoteResponse]>.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
            
        }.resume()
    }

    // MARK: - Crear Lote (POST /create)
    func crearLote(request: LoteRequest, completion: @escaping (Result<LoteResponse, Error>) -> Void) {
        guard let token = getAuthToken() else {
            completion(.failure(NSError(domain: "", code: 401,
                userInfo: [NSLocalizedDescriptionKey: "No hay sesión activa"])))
            return
        }
        
        guard let url = URL(string: "\(Constants.baseURL)lotes/create") else {
            completion(.failure(NSError(domain: "", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "URL inválida"])))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let jsonData = try JSONEncoder().encode(request)
            urlRequest.httpBody = jsonData
            
            print("Enviando petición a: \(url)")
            print("Body: \(String(data: jsonData, encoding: .utf8) ?? "")")
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
                    completion(.failure(NSError(domain: "", code: 401,
                        userInfo: [NSLocalizedDescriptionKey: "Sesión expirada"])))
                    return
                case 403:
                    completion(.failure(NSError(domain: "", code: 403,
                        userInfo: [NSLocalizedDescriptionKey: "No tienes permisos"])))
                    return
                default:
                    break
                }
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "No hay datos"])))
                return
            }
            
            // Debug: Imprimir respuesta
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Respuesta recibida: \(jsonString)")
            }
            
            do {
                let resultado = try JSONDecoder().decode(ResultadoResponse<LoteResponse>.self, from: data)
                
                if resultado.valor, let loteData = resultado.data {
                    print("Lote creado exitosamente: \(loteData.nombre)")
                    completion(.success(loteData))
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
