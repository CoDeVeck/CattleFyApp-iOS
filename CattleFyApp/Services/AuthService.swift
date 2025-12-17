//
//  AuthService.swift
//  CattleFyApp
//
//  Created by Andy Yahir Valdivia Centeno on 16/12/25.
//

import Foundation

class AuthService {
    static let shared = AuthService()
    
    private init() {}
    
    // MARK: - Helper para obtener el token guardado
    private func getAuthToken() -> String? {
        return UserDefaults.standard.string(forKey: "authToken")
    }
    
    // MARK: - Registro (endpoint libre, no necesita token)
    func registrar(request: RegistroRequestDTO, completion: @escaping (Result<AuthResponseDTO, Error>) -> Void) {
        guard let url = URL(string: "\(Constants.baseURL)auth/registro") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL inválida"])))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(request)
            urlRequest.httpBody = jsonData
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
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No hay datos"])))
                return
            }
            
            do {
                let resultado = try JSONDecoder().decode(
                    ResultadoResponse<AuthResponseDTO>.self,
                    from: data
                )

                if resultado.valor, let authData = resultado.data {
                    completion(.success(authData))
                } else {
                    completion(.failure(
                        NSError(
                            domain: "",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: resultado.mensaje]
                        )
                    ))
                }

            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Login (endpoint libre, no necesita token)
    func login(request: LoginRequestDTO, completion: @escaping (Result<AuthResponseDTO, Error>) -> Void) {
        guard let url = URL(string: "\(Constants.baseURL)auth/login") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL inválida"])))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(request)
            urlRequest.httpBody = jsonData
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
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No hay datos"])))
                return
            }
            
            do {
                let resultado = try JSONDecoder().decode(
                    ResultadoResponse<AuthResponseDTO>.self,
                    from: data
                )

                if resultado.valor, let authData = resultado.data {
                    completion(.success(authData))
                } else {
                    completion(.failure(
                        NSError(
                            domain: "",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: resultado.mensaje]
                        )
                    ))
                }

            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Petición protegida ejemplo (NECESITA TOKEN)
    /*func obtenerPerfil(completion: @escaping (Result<PerfilUsuarioDTO, Error>) -> Void) {
        guard let token = getAuthToken() else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "No hay sesión activa"])))
            return
        }
        
        guard let url = URL(string: "\(Constants.baseURL)/perfil") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL inválida"])))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // ✅ AQUÍ SE AGREGA EL TOKEN
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Verificar si el token expiró (401 Unauthorized)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
                completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Sesión expirada"])))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No hay datos"])))
                return
            }
            
            do {
                let resultado = try JSONDecoder().decode(ResultadoResponse<PerfilUsuarioDTO>.self, from: data)
                
                if resultado.success, let perfil = resultado.data {
                    completion(.success(perfil))
                } else {
                    let errorMsg = resultado.error ?? "Error desconocido"
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMsg])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }*/
    
    // MARK: - Método genérico para peticiones protegidas
    func hacerPeticionProtegida<T: Codable>(
        url: String,
        method: String,
        body: Codable? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let token = getAuthToken() else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "No hay sesión activa"])))
            return
        }
        
        guard let requestURL = URL(string: url) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL inválida"])))
            return
        }
        
        var urlRequest = URLRequest(url: requestURL)
        urlRequest.httpMethod = method
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        if let body = body {
            do {
                let jsonData = try JSONEncoder().encode(body)
                urlRequest.httpBody = jsonData
            } catch {
                completion(.failure(error))
                return
            }
        }
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 401:
                    completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Sesión expirada"])))
                    return
                case 403:
                    completion(.failure(NSError(domain: "", code: 403, userInfo: [NSLocalizedDescriptionKey: "No tienes permisos"])))
                    return
                default:
                    break
                }
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No hay datos"])))
                return
            }
            
            do {
                let resultado = try JSONDecoder().decode(
                    ResultadoResponse<T>.self,
                    from: data
                )

                if resultado.valor, let responseData = resultado.data {
                    completion(.success(responseData))
                } else {
                    completion(.failure(
                        NSError(
                            domain: "",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: resultado.mensaje]
                        )
                    ))
                }

            } catch {
                completion(.failure(error))
            }

        }.resume()
    }
    
    // MARK: - Cerrar sesión
    func logout() {
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        print("✅ Sesión cerrada")
    }
}
