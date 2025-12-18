//
//  RegistroSanitarioService.swift
//  CattleFyApp
//
//  Created by Andy Yahir Valdivia Centeno on 17/12/25.
//

import Foundation

class RegistroSanitarioService {
    
    static let shared = RegistroSanitarioService()
    
    private init() {}
    
    // MARK: - Obtener token
    private func getAuthToken() -> String? {
        return UserDefaults.standard.string(forKey: "authToken")
    }
    func crearRegistroSanitario(
        request: RegistroSanitarioRequest,
        completion: @escaping (Result<RegistroSanitarioResponse, Error>) -> Void
    ) {
        
        guard let token = getAuthToken() else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [
                NSLocalizedDescriptionKey: "No hay sesión activa"
            ])))
            return
        }
        
        guard let url = URL(string: "\(Constants.baseURL)registroSanitario/crear-unificado") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "URL inválida"
            ])))
            return
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Crear body multipart
        var body = Data()
        
        func addField(name: String, value: String?) {
            guard let value = value else { return }
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        addField(name: "qrLote", value: request.qrLote)
        addField(name: "idLote", value: request.idLote != nil ? "\(request.idLote!)" : nil)
        addField(name: "qrAnimal", value: request.qrAnimal)
        addField(name: "tipoAplicacion", value: request.tipoAplicacion)
        addField(name: "protocoloTipo", value: request.protocoloTipo)
        addField(name: "nombreProducto", value: request.nombreProducto)
        addField(name: "costoPorDosis", value: request.costoPorDosis != nil ? "\(request.costoPorDosis!)" : nil)
        addField(name: "cantidadDosis", value: request.cantidadDosis != nil ? "\(request.cantidadDosis!)" : nil)
        addField(name: "animalesTratados", value: request.animalesTratados != nil ? "\(request.animalesTratados!)" : nil)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        urlRequest.httpBody = body
        
        print("Multipart body enviado:")
        print(String(data: body, encoding: .utf8) ?? "")
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "No hay datos"
                ])))
                return
            }
            
            do {
                let resultado = try JSONDecoder().decode(
                    ResultadoResponse<RegistroSanitarioResponse>.self,
                    from: data
                )
                
                if resultado.valor, let registro = resultado.data {
                    completion(.success(registro))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: resultado.mensaje
                    ])))
                }
                
            } catch {
                completion(.failure(error))
            }
            
        }.resume()
    }

}
