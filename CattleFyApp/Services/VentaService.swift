//
//  VentaService.swift
//  CattleFyApp
//
//  Created by Victor Narazas on 21/12/25.
//

import Foundation

class VentaService {
    
    static let shared = VentaService()
    private init() {}
    
    private func getAuthToken() -> String? {
        return UserDefaults.standard.string(forKey: "authToken")
    }
    
    
    /* // MARK: - Helper para crear request autenticado
     private func crearRequestAutenticado(url: URL) -> URLRequest {
     var request = URLRequest(url: url)
     request.httpMethod = "GET"
     request.timeoutInterval = 30
     
     if let token = getAuthToken() {
     request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
     print("Token agregado: Bearer \(token.prefix(20))...")
     } else {
     print("No hay token disponible")
     }
     
     return request
     }*/
    
    
    // MARK: - Helper para crear request autenticado (ÚNICA VERSIÓN)
    private func crearRequestAutenticado(url: URL, metodo: String = "GET") -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = metodo
        request.timeoutInterval = 120  // 2 minutos para Render
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("✅ Token agregado: Bearer \(token.prefix(20))...")
        } else {
            print("⚠️ No hay token disponible")
        }
        
        return request
    }
    
    
    // MARK: - Obtener Lotes Disponibles para Venta
    func obtenerLotesDisponibles(granjaId: Int, tipoLote: String?, completion: @escaping (Result<[LoteDisponibleVentaResponse], Error>) -> Void) {
        
        var urlString = "\(Constants.baseURL)ventas/lotes-disponibles/\(granjaId)"
        
        
        if let tipo = tipoLote {
            
            if let encodedTipo = tipo.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                urlString += "?tipoLote=\(encodedTipo)"
            }
        }
        
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "VentaService", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL inválida: \(urlString)"])
            completion(.failure(error))
            return
        }
        
        let request = crearRequestAutenticado(url: url)
        
        print("Obteniendo lotes disponibles desde: \(urlString)")
        if let tipo = tipoLote {
            print("Filtro aplicado: \(tipo)")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print(" Error en la solicitud: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain: "VentaService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Respuesta inválida del servidor"])
                completion(.failure(error))
                return
            }
            
            print("Status Code: \(httpResponse.statusCode)")
            
            
            if let totalCount = httpResponse.value(forHTTPHeaderField: "X-Total-Count") {
                print("Total de lotes disponibles: \(totalCount)")
            }
            
            if let message = httpResponse.value(forHTTPHeaderField: "X-Message") {
                print("Mensaje del servidor: \(message)")
            }
            
            if let filterType = httpResponse.value(forHTTPHeaderField: "X-Filter-Type") {
                print("🔎 Filtro confirmado por servidor: \(filterType)")
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                var errorMessage = "Error del servidor (código \(httpResponse.statusCode))"
                
                if let data = data, let serverMessage = String(data: data, encoding: .utf8) {
                    errorMessage = serverMessage
                }
                
                let error = NSError(domain: "VentaService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "VentaService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No hay datos en la respuesta"])
                completion(.failure(error))
                return
            }
            
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("JSON recibido (\(data.count) bytes):")
                print(jsonString.prefix(500))
            }
            
            do {
                let decoder = JSONDecoder()
                
                
                decoder.dateDecodingStrategy = .custom { decoder in
                    let container = try decoder.singleValueContainer()
                    let dateString = try container.decode(String.self)
                    
                    
                    let formatter = ISO8601DateFormatter()
                    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    
                    if let date = formatter.date(from: dateString) {
                        return date
                    }
                    
                    formatter.formatOptions = [.withInternetDateTime]
                    if let date = formatter.date(from: dateString) {
                        return date
                    }
                    
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "No se pudo decodificar la fecha: \(dateString)")
                }
                
                let lotes = try decoder.decode([LoteDisponibleVentaResponse].self, from: data)
                
                print("Lotes decodificados exitosamente: \(lotes.count)")
                lotes.forEach { lote in
                    print("  - \(lote.loteNombre): \(lote.tipoLote) (\(lote.cantidadAnimalesVivos) animales)")
                }
                
                completion(.success(lotes))
                
            } catch let decodingError as DecodingError {
                print(" Error al decodificar JSON:")
                
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("  - Key no encontrado: \(key.stringValue)")
                    print("  - Contexto: \(context.debugDescription)")
                    
                case .typeMismatch(let type, let context):
                    print("  - Tipo no coincide: esperado \(type)")
                    print("  - Contexto: \(context.debugDescription)")
                    
                case .valueNotFound(let type, let context):
                    print("  - Valor no encontrado: tipo \(type)")
                    print("  - Contexto: \(context.debugDescription)")
                    
                case .dataCorrupted(let context):
                    print("  - Datos corruptos")
                    print("  - Contexto: \(context.debugDescription)")
                    
                @unknown default:
                    print("  - Error desconocido: \(decodingError)")
                }
                
                completion(.failure(decodingError))
                
            } catch {
                print(" Error general al decodificar: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    // MARK: - Registrar Venta
    func registrarVenta(request: RegistroVentaRequest, completion: @escaping (Result<VentaDetalleResponse, Error>) -> Void) {
        
        let urlString = "\(Constants.baseURL)ventas/venta"
        
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "VentaService", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL inválida"])
            completion(.failure(error))
            return
        }
        
        var urlRequest = crearRequestAutenticado(url: url, metodo: "POST")
        
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(request)
            urlRequest.httpBody = jsonData
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Request JSON:")
                print(jsonString)
            }
            
        } catch {
            print("Error al codificar request: \(error)")
            completion(.failure(error))
            return
        }
        
        print("Registrando venta en: \(urlString)")
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print(" Error en request: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain: "VentaService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Respuesta inválida"])
                completion(.failure(error))
                return
            }
            
            print("Status Code: \(httpResponse.statusCode)")
            
            // Logs de headers personalizados
            if let message = httpResponse.value(forHTTPHeaderField: "X-Message") {
                print("Mensaje: \(message)")
            }
            if let resourceId = httpResponse.value(forHTTPHeaderField: "X-Resource-Id") {
                print("Resource ID: \(resourceId)")
            }
            
            guard let data = data else {
                let error = NSError(domain: "VentaService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No hay datos"])
                completion(.failure(error))
                return
            }
            
            // Log del response
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Response JSON:")
                print(jsonString)
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                var errorMessage = "Error del servidor (\(httpResponse.statusCode))"
                if let serverMessage = String(data: data, encoding: .utf8) {
                    errorMessage = serverMessage
                }
                let error = NSError(domain: "VentaService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                completion(.failure(error))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let ventaResponse = try decoder.decode(VentaDetalleResponse.self, from: data)
                print("Venta registrada exitosamente - ID: \(ventaResponse.ventaId)")
                completion(.success(ventaResponse))
                
            } catch {
                print(" Error al decodificar response: \(error)")
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
}
