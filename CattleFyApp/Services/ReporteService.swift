//
//  ReporteService.swift
//  CattleFyApp
//
//  Created by Victor Narazas on 20/12/25.
//

import Foundation

class ReporteService{
    
    static let shared = ReporteService()
    private init() {}
    
    private func getAuthToken() -> String? {
        return UserDefaults.standard.string(forKey: "authToken")
    }
    
    
    // MARK: - Helper para crear request autenticado
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
        }
    
    
    func fetchLotesPorGranja(
        granjaId: Int,
        completion: @escaping (Result<[LoteSimpleDTO], Error>) -> Void
    ) {
        let urlString = "\(Constants.baseURL)registroProduccion/loteGranja/1"
        
        guard let url = URL(string: urlString) else {
            print("❌ URL inválida: \(urlString)")
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        print("🌐 Fetching Lotes: \(url.absoluteString)")
        
        let request = crearRequestAutenticado(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            // ⭐ AGREGAR LOG DEL STATUS CODE
            if let httpResponse = response as? HTTPURLResponse {
                print("📊 Status Code para lotes: \(httpResponse.statusCode)")
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response")
                completion(.failure(NSError(domain: "Invalid response", code: -1, userInfo: nil)))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("❌ HTTP Error: \(httpResponse.statusCode)")
                
                // ⭐ SI ES 403, IMPRIMIR MÁS INFO
                if httpResponse.statusCode == 403 {
                    print("⚠️ Error 403 Forbidden - El token no tiene permisos para acceder a esta granja")
                    if let data = data, let errorString = String(data: data, encoding: .utf8) {
                        print("📦 Respuesta del servidor: \(errorString)")
                    }
                }
                
                completion(.failure(NSError(domain: "HTTP Error", code: httpResponse.statusCode, userInfo: nil)))
                return
            }
            
            guard let data = data else {
                print("❌ No data")
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }
            
            // ⭐ IMPRIMIR JSON CRUDO
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 JSON Lotes recibido:")
                print(jsonString)
            }
            
            do {
                let lotes = try JSONDecoder().decode([LoteSimpleDTO].self, from: data)
                print("✅ Lotes decodificados exitosamente: \(lotes.count)")
                for lote in lotes {
                    print("  - ID: \(lote.loteId), Nombre: \(lote.nombre)")
                }
                completion(.success(lotes))
            } catch {
                print("❌ Decoding error: \(error)")
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("  Key '\(key.stringValue)' no encontrada")
                        print("  Context: \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        print("  Type mismatch para '\(type)'")
                        print("  Context: \(context.debugDescription)")
                    case .valueNotFound(let type, let context):
                        print("  Value not found para '\(type)'")
                        print("  Context: \(context.debugDescription)")
                    default:
                        print("  Otro error de decodificación")
                    }
                }
                completion(.failure(error))
            }
        }.resume()
    }
    
    //MARK: - OBTENER ESTADISTICAS DE SANIDAD
    func fetchEstadisticasSanidad(
            granjaId: Int,
            loteId: Int? = nil,
            fechaInicio: String? = nil,
            fechaFin: String? = nil,
            completion: @escaping (Result<SanidadEstadisticasDTO, Error>) -> Void
        ) {
            var urlComponents = URLComponents(string: "\(Constants.baseURL)registroProduccion/reporte/1/sanidad")
            
            var queryItems: [URLQueryItem] = []
            
            if let loteId = loteId {
                queryItems.append(URLQueryItem(name: "lote_id", value: "\(loteId)"))
            }
            
            if let fechaInicio = fechaInicio {
                queryItems.append(URLQueryItem(name: "fecha_inicio", value: fechaInicio))
            }
            
            if let fechaFin = fechaFin {
                queryItems.append(URLQueryItem(name: "fecha_fin", value: fechaFin))
            }
            
            if !queryItems.isEmpty {
                urlComponents?.queryItems = queryItems
            }
            
            guard let url = urlComponents?.url else {
                completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
                return
            }
            
            print("Fetching Estadísticas: \(url.absoluteString)")
            
            var request = crearRequestAutenticado(url: url)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(NSError(domain: "Invalid response", code: -1, userInfo: nil)))
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(NSError(domain: "HTTP Error", code: httpResponse.statusCode, userInfo: nil)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                    return
                }
                
                do {
                    let estadisticas = try JSONDecoder().decode(SanidadEstadisticasDTO.self, from: data)
                    completion(.success(estadisticas))
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(error))
                }
            }.resume()
        }
    
    
    
    //MARK: - DETALLE DE APLICACIONES
    func fetchDetalleAplicaciones(
      granjaId: Int,
      filtros: AplicacionesFiltros = AplicacionesFiltros(),
      completion: @escaping (Result<[DetalleAplicacion], Error>) -> Void
    ) {
       
      // ⭐ USAR EL PARAMETRO granjaId, NO HARDCODEAR
      var urlComponents = URLComponents(string: "\(Constants.baseURL)registroProduccion/reporte/\(granjaId)/detalleAplicaciones")
       
      var queryItems: [URLQueryItem] = []
       
      //Agregamos parametros si es q el usuario manda
       
      if let loteId = filtros.loteId {
        // ⭐ CONVERTIR Int a String
        queryItems.append(URLQueryItem(name: "lote_id", value: "\(loteId)"))
      }
       
      if let protocoloTipo = filtros.protocoloTipo {
        queryItems.append(URLQueryItem(name: "protocolo_tipo", value: protocoloTipo))
      }
       
      if let fechaInicio = filtros.fechaInicio {
        queryItems.append(URLQueryItem(name: "fecha_inicio", value: fechaInicio))
      }
       
      if let fechaFin = filtros.fechaFin {
        queryItems.append(URLQueryItem(name: "fecha_fin", value: fechaFin))
      }
       
      if !queryItems.isEmpty {
        urlComponents?.queryItems = queryItems
      }
       
      guard let url = urlComponents?.url else {
        print("❌ Invalid URL")
        completion(.failure(NSError(domain: "Invalid_URL", code: -1, userInfo: nil)))
        return
      }
       
      print("🌐 URL REQUEST Aplicaciones: \(url.absoluteString)")
       
      let request = crearRequestAutenticado(url: url)
       
      URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
          print("❌ Network error: \(error.localizedDescription)")
          completion(.failure(error))
          return
        }
         
        // ⭐ AGREGAR LOG DEL STATUS CODE
        if let httpResponse = response as? HTTPURLResponse {
          print("📊 Status Code Aplicaciones: \(httpResponse.statusCode)")
        }
         
        guard let httpResponse = response as? HTTPURLResponse else {
          print("❌ Invalid Response")
          completion(.failure(NSError(domain: "Invalid Response", code: -1, userInfo: nil)))
          return
        }
         
        guard (200...299).contains(httpResponse.statusCode) else {
          print("❌ HTTP Error: \(httpResponse.statusCode)")
          completion(.failure(NSError(domain: "HttpError", code: httpResponse.statusCode, userInfo: nil)))
          return
        }
         
        guard let data = data else {
          print("❌ NO DATA")
          completion(.failure(NSError(domain: "NO DATA", code: -1, userInfo: nil)))
          return
        }
         
        // ⭐ IMPRIMIR JSON CRUDO
        if let jsonString = String(data: data, encoding: .utf8) {
          print("📦 JSON Aplicaciones recibido:")
          print(jsonString)
        }
         
        do {
          let aplicaciones = try JSONDecoder().decode([DetalleAplicacion].self, from: data)
          print("✅ Aplicaciones decodificadas: \(aplicaciones.count)")
          completion(.success(aplicaciones))
        } catch {
          print("❌ Decoding error: \(error)")
          if let decodingError = error as? DecodingError {
            switch decodingError {
            case .keyNotFound(let key, let context):
              print(" Key '\(key.stringValue)' no encontrada")
              print(" CodingPath: \(context.codingPath)")
            case .typeMismatch(let type, let context):
              print(" Type mismatch para '\(type)'")
              print(" CodingPath: \(context.codingPath)")
            case .valueNotFound(let type, let context):
              print(" Value not found para '\(type)'")
              print(" CodingPath: \(context.codingPath)")
            default:
              break
            }
          }
          completion(.failure(error))
        }
      }.resume()
    }

    
}
