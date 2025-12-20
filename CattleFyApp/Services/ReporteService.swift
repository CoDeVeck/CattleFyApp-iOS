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
    
    func fetchDetalleAplicaciones(granjaId: Int, filtros: AplicacionesFiltros = AplicacionesFiltros(), completion: @escaping (Result<[DetalleAplicacion], Error>) -> void){
        
        var urlComponents = URLComponents(string: "https://cattlefyapi.onrender.com/registroProduccion/reporte/\(granjaId)/detalleAplicaciones")
        
        var queryItems: [URLQueryItem] = []
        
        //Agregamos parametros si es q el usuario manda
        
        if let loteId = filtros.loteId{
            queryItems.append(URLQueryItem(name: "lote_id", value: loteId))
        }
        
        if let protocoloTipo = filtros.protocoloTipo {
            queryItems.append(URLQueryItem(name: "protocolo_tipo", value: protocoloTipo))
        }
        
        if let fechaInicio = filtros.fechaInicio{
            queryItems.append(URLQueryItem(name: "fecha_inicio", value: fechaInicio))
        }
        
        if let fechaFin = filtros.fechaFin{
            queryItems.append(URLQueryItem(name: "fecha_fin", value: fechaFin))
        }
        
        if !queryItems.isEmpty {
            urlComponents?.queryItems = queryItems
        }
        
        guard let url = urlComponents?.url else {
            completion(failure(NSError(domain: "Invalid_URL", code: -1, userInfo: nil)))
        }
        print("URL REQUEST : \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 30
        
        URLSession.shared.dataTask(with: request){
            data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Invalid Response", code: -1, userInfo: nil)))
                return
            }
            
            guard (200..299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "HttpError", code: -1, userInfo: nil)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "NO DATA", code: -1, userInfo: nil)))
                return
            }
            
            do{
                let aplicaciones = try JSONDecoder().decode([DetalleAplicacion].self, from: data)
                                completion(.success(aplicaciones))
            } catch {
                print("Decoding error: \(error)")
                                completion(.failure(error))
            }
        }.resume()
        
    }
    
}
