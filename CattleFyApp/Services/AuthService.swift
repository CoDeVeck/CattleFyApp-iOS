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
    
    // MARK: - Cerrar sesión
    func logout() {
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        print("✅ Sesión cerrada")
    }
}
