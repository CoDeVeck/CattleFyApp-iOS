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
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        print("Fetching Lotes: \(url.absoluteString)")
        
        let request = crearRequestAutenticado(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
       
            if let httpResponse = response as? HTTPURLResponse {
                print("Status Code para lotes: \(httpResponse.statusCode)")
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
         
                completion(.failure(NSError(domain: "Invalid response", code: -1, userInfo: nil)))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                
                // ⭐ SI ES 403, IMPRIMIR MÁS INFO
                if httpResponse.statusCode == 403 {
                    if let data = data, let errorString = String(data: data, encoding: .utf8) {
                    }
                }
                
                completion(.failure(NSError(domain: "HTTP Error", code: httpResponse.statusCode, userInfo: nil)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let lotes = try JSONDecoder().decode([LoteSimpleDTO].self, from: data)
                print("Lotes decodificados exitosamente: \(lotes.count)")
                for lote in lotes {
                    print("  - ID: \(lote.loteId), Nombre: \(lote.nombre)")
                }
                completion(.success(lotes))
            } catch {
                print("ecoding error: \(error)")
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
       
      var urlComponents = URLComponents(string: "\(Constants.baseURL)registroProduccion/reporte/\(granjaId)/detalleAplicaciones")
       
      var queryItems: [URLQueryItem] = []

       
      if let loteId = filtros.loteId {

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
        completion(.failure(NSError(domain: "Invalid_URL", code: -1, userInfo: nil)))
        return
      }
        
      let request = crearRequestAutenticado(url: url)
       
      URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
          completion(.failure(error))
          return
        }
         
        
         
        guard let httpResponse = response as? HTTPURLResponse else {
          
          completion(.failure(NSError(domain: "Invalid Response", code: -1, userInfo: nil)))
          return
        }
         
        guard (200...299).contains(httpResponse.statusCode) else {
         
          completion(.failure(NSError(domain: "HttpError", code: httpResponse.statusCode, userInfo: nil)))
          return
        }
         
          guard let data = data else {
              
              completion(.failure(NSError(domain: "NO DATA", code: -1, userInfo: nil)))
              return
          }
         
        do {
          let aplicaciones = try JSONDecoder().decode([DetalleAplicacion].self, from: data)
       
          completion(.success(aplicaciones))
        } catch {
         
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

    //MARK: - FETCH REPORTE PRODUCCION ENGORDEEEEE
    func fetchReporteEngorde(
        granjaId: Int,
        filtros: ReporteProduccionFiltros = ReporteProduccionFiltros(),
        completion: @escaping (Result<[ReporteProduccionEngordeDTO], Error>) -> Void
      ) {
        var urlComponents = URLComponents(string: "\(Constants.baseURL)registroProduccion/reporte/\(granjaId)/produccion")
        
        var queryItems: [URLQueryItem] = []
        
        if let loteId = filtros.loteId {
          queryItems.append(URLQueryItem(name: "lote_id", value: "\(loteId)"))
        }
        
        if let categoriaId = filtros.categoriaId {
          queryItems.append(URLQueryItem(name: "categoria_id", value: "\(categoriaId)"))
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
          completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
          return
        }
        
        print(" Fetching Reporte Engorde: \(url.absoluteString)")
        
        let request = crearRequestAutenticado(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
          if let error = error {
            print(" Network error: \(error.localizedDescription)")
            completion(.failure(error))
            return
          }
          
          guard let httpResponse = response as? HTTPURLResponse else {
            completion(.failure(NSError(domain: "Invalid Response", code: -1, userInfo: nil)))
            return
          }
          
          print(" Status Code Reporte Engorde: \(httpResponse.statusCode)")
          
          guard (200...299).contains(httpResponse.statusCode) else {
            completion(.failure(NSError(domain: "HTTP Error", code: httpResponse.statusCode, userInfo: nil)))
            return
          }
          
          guard let data = data else {
            completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
            return
          }
          
          if let jsonString = String(data: data, encoding: .utf8) {
            print("JSON Reporte Engorde:")
            print(jsonString)
          }
          
          do {
            let reporte = try JSONDecoder().decode([ReporteProduccionEngordeDTO].self, from: data)
            print("Reporte Engorde decodificado: \(reporte.count) registros")
            completion(.success(reporte))
          } catch {
            print("Decoding error: \(error)")
            completion(.failure(error))
          }
        }.resume()
      }
    
    //MARK: Fetch gráfico de evolución de peso (para Engorde)
    func fetchGraficoEngorde(
      granjaId: Int,
      filtros: ReporteProduccionFiltros = ReporteProduccionFiltros(),
      completion: @escaping (Result<[ReporteGrafico1], Error>) -> Void
    ) {
      var urlComponents = URLComponents(string: "\(Constants.baseURL)registroProduccion/grafico1/\(granjaId)/produccion")
      
      var queryItems: [URLQueryItem] = []
      
      if let loteId = filtros.loteId {
        queryItems.append(URLQueryItem(name: "lote_id", value: "\(loteId)"))
      }
      
      if let categoriaId = filtros.categoriaId {
        queryItems.append(URLQueryItem(name: "categoria_id", value: "\(categoriaId)"))
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
        completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
        return
      }
      
      print("🌐 Fetching Gráfico Engorde (Peso): \(url.absoluteString)")
      
      let request = crearRequestAutenticado(url: url)
      
      URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
          print("❌ Network error: \(error.localizedDescription)")
          completion(.failure(error))
          return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
          completion(.failure(NSError(domain: "Invalid Response", code: -1, userInfo: nil)))
          return
        }
        
        print("📊 Status Code Gráfico Engorde: \(httpResponse.statusCode)")
        
        guard (200...299).contains(httpResponse.statusCode) else {
          completion(.failure(NSError(domain: "HTTP Error", code: httpResponse.statusCode, userInfo: nil)))
          return
        }
        
        guard let data = data else {
          completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
          return
        }
        
        if let jsonString = String(data: data, encoding: .utf8) {
          print("📦 JSON Gráfico Engorde:")
          print(jsonString)
        }
        
        do {
          let grafico = try JSONDecoder().decode([ReporteGrafico1].self, from: data)
          print("✅ Gráfico Engorde decodificado: \(grafico.count) puntos")
          completion(.success(grafico))
        } catch {
          print("❌ Decoding error: \(error)")
          completion(.failure(error))
        }
      }.resume()
    }
    
    //MARK: FETCH REPRODUCCION
    func fetchReporteProduccion(
       granjaId: Int,
       filtros: ReporteProduccionFiltros = ReporteProduccionFiltros(),
       completion: @escaping (Result<[ReporteProduccionReproduccion], Error>) -> Void
     ) {
       var urlComponents = URLComponents(string: "\(Constants.baseURL)registroProduccion/reporte/reproduccion/\(granjaId)")
       
       var queryItems: [URLQueryItem] = []
       
       if let loteId = filtros.loteId {
         queryItems.append(URLQueryItem(name: "lote_id", value: "\(loteId)"))
       }
       
       if let categoriaId = filtros.categoriaId {
         queryItems.append(URLQueryItem(name: "categoria_id", value: "\(categoriaId)"))
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
         completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
         return
       }
       
       print("🌐 Fetching Reporte Producción: \(url.absoluteString)")
       
       let request = crearRequestAutenticado(url: url)
       
       URLSession.shared.dataTask(with: request) { data, response, error in
         if let error = error {
           print("❌ Network error: \(error.localizedDescription)")
           completion(.failure(error))
           return
         }
         
         guard let httpResponse = response as? HTTPURLResponse else {
           completion(.failure(NSError(domain: "Invalid Response", code: -1, userInfo: nil)))
           return
         }
         
         print("📊 Status Code Reporte Producción: \(httpResponse.statusCode)")
         
         guard (200...299).contains(httpResponse.statusCode) else {
           completion(.failure(NSError(domain: "HTTP Error", code: httpResponse.statusCode, userInfo: nil)))
           return
         }
         
         guard let data = data else {
           completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
           return
         }
         
         if let jsonString = String(data: data, encoding: .utf8) {
           print("📦 JSON Reporte Producción:")
           print(jsonString)
         }
         
         do {
           let reporte = try JSONDecoder().decode([ReporteProduccionReproduccion].self, from: data)
           print("✅ Reporte Producción decodificado: \(reporte.count) registros")
           completion(.success(reporte))
         } catch {
           print("❌ Decoding error: \(error)")
           completion(.failure(error))
         }
       }.resume()
     }
    
    //MARK: - FETCH GRAFICO 2
 
    func fetchGraficoProduccion(
       granjaId: Int,
       filtros: ReporteProduccionFiltros = ReporteProduccionFiltros(),
       completion: @escaping (Result<[ReporteGrafico2], Error>) -> Void
     ) {
       var urlComponents = URLComponents(string: "\(Constants.baseURL)registroProduccion/grafico2/\(granjaId)/reproduccion")
       
       var queryItems: [URLQueryItem] = []
       
       if let loteId = filtros.loteId {
         queryItems.append(URLQueryItem(name: "lote_id", value: "\(loteId)"))
       }
       
       if let categoriaId = filtros.categoriaId {
         queryItems.append(URLQueryItem(name: "categoria_id", value: "\(categoriaId)"))
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
         completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
         return
       }
       
       print("🌐 Fetching Gráfico Producción: \(url.absoluteString)")
       
       let request = crearRequestAutenticado(url: url)
       
       URLSession.shared.dataTask(with: request) { data, response, error in
         if let error = error {
           print("❌ Network error: \(error.localizedDescription)")
           completion(.failure(error))
           return
         }
         
         guard let httpResponse = response as? HTTPURLResponse else {
           completion(.failure(NSError(domain: "Invalid Response", code: -1, userInfo: nil)))
           return
         }
         
         print("📊 Status Code Gráfico Producción: \(httpResponse.statusCode)")
         
         guard (200...299).contains(httpResponse.statusCode) else {
           completion(.failure(NSError(domain: "HTTP Error", code: httpResponse.statusCode, userInfo: nil)))
           return
         }
         
         guard let data = data else {
           completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
           return
         }
         
         if let jsonString = String(data: data, encoding: .utf8) {
           print("📦 JSON Gráfico Producción:")
           print(jsonString)
         }
         
         do {
           let grafico = try JSONDecoder().decode([ReporteGrafico2].self, from: data)
           print("✅ Gráfico Producción decodificado: \(grafico.count) puntos")
           completion(.success(grafico))
         } catch {
           print("❌ Decoding error: \(error)")
           completion(.failure(error))
         }
       }.resume()
     }
    
    //MARK: - FETCH REPORTE FINANCIERO
    
    //MARK: - FETCH GRAFICO 3
    
    
}
