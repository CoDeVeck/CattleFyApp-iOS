//
//  AnimalesService.swift
//  CattleFyApp
//
//  Created by Rebeca on 12/20/25.
//

import Foundation
import UIKit

class AnimalService {

    static let shared = AnimalService()
    private init() {}

    // MARK: - Token

    private func getAuthToken() -> String? {
        UserDefaults.standard.string(forKey: "authToken")
    }

    private func crearRequest(
           url: URL,
           method: String,
           body: Data? = nil,
           isMultipart: Bool = false
       ) -> URLRequest {
           var request = URLRequest(url: url)
           request.httpMethod = method
           if let token = getAuthToken() {
               request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
           }
           if !isMultipart {
               request.setValue("application/json", forHTTPHeaderField: "Content-Type")
           }
           request.httpBody = body
           return request
       }

    // MARK: - GET total animales vivos

    func obtenerTotalAnimalesVivos(
        granjaId: Int,
        completion: @escaping (Result<Int, Error>) -> Void
    ) {
        guard let url = URL(
            string: "\(Constants.baseURL)animales/total-vivos/\(granjaId)"
        ) else {
            completion(.failure(ServiceError.urlInvalida))
            return
        }

        let request = crearRequest(url: url, method: "GET")

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data,
                  let total = Int(String(decoding: data, as: UTF8.self)) else {
                completion(.failure(ServiceError.respuestaInvalida))
                return
            }

            completion(.success(total))
        }.resume()
    }

    // MARK: - GET animal por QR

    func obtenerAnimalPorQR(
        qrAnimal: String,
        completion: @escaping (Result<AnimalResponse, Error>) -> Void
    ) {
        guard let url = URL(
            string: "\(Constants.baseURL)animales/animal/\(qrAnimal)"
        ) else {
            completion(.failure(ServiceError.urlInvalida))
            return
        }

        let request = crearRequest(url: url, method: "GET")

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(ServiceError.sinDatos))
                return
            }

            do {
                let animal = try JSONDecoder()
                    .decode(AnimalResponse.self, from: data)
                completion(.success(animal))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    

    // MARK: - GET animales por lote

    func listarAnimalesPorLote(
        idLote: Int,
        completion: @escaping (Result<[AnimalResponse], Error>) -> Void
    ) {
        guard let url = URL(
            string: "\(Constants.baseURL)animales/lote/\(idLote)"
        ) else {
            completion(.failure(ServiceError.urlInvalida))
            return
        }

        let request = crearRequest(url: url, method: "GET")

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(ServiceError.sinDatos))
                return
            }

            do {
                let animales = try JSONDecoder()
                    .decode([AnimalResponse].self, from: data)
                completion(.success(animales))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: - Registrar Animal con Imagen
       func registrarAnimal(
           animal: AnimalRequest,
           imagen: UIImage?,
           completion: @escaping (Result<AnimalResponse, Error>) -> Void
       ) {
           guard let url = URL(string: "\(Constants.baseURL)animales/registrar") else {
               completion(.failure(NSError(
                   domain: "", code: -1,
                   userInfo: [NSLocalizedDescriptionKey: "URL inválida"]
               )))
               return
           }
           
           guard let token = getAuthToken() else {
               completion(.failure(NSError(
                   domain: "", code: 401,
                   userInfo: [NSLocalizedDescriptionKey: "No hay sesión activa"]
               )))
               return
           }
           
           let boundary = "Boundary-\(UUID().uuidString)"
           
           var request = URLRequest(url: url)
           request.httpMethod = "POST"
           request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
           request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
           
           // AQUÍ está la llamada al método privado - debe estar dentro de la clase
           request.httpBody = crearMultipartBody(
               animal: animal,
               imagen: imagen,
               boundary: boundary
           )
           
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
               
               guard let data = data else {
                   completion(.failure(NSError(
                       domain: "", code: -1,
                       userInfo: [NSLocalizedDescriptionKey: "No hay datos en la respuesta"]
                   )))
                   return
               }
               
               if httpResponse.statusCode == 500 {
                   let errorMessage = String(data: data, encoding: .utf8) ?? "Error interno del servidor"
                   completion(.failure(NSError(
                       domain: "", code: 500,
                       userInfo: [NSLocalizedDescriptionKey: errorMessage]
                   )))
                   return
               }
               
               guard (200...299).contains(httpResponse.statusCode) else {
                   let errorMessage = String(data: data, encoding: .utf8) ?? "Error desconocido"
                   completion(.failure(NSError(
                       domain: "", code: httpResponse.statusCode,
                       userInfo: [NSLocalizedDescriptionKey: errorMessage]
                   )))
                   return
               }
               
               do {
                   let animalResponse = try JSONDecoder().decode(AnimalResponse.self, from: data)
                   completion(.success(animalResponse))
               } catch {
                   print("Error al decodificar: \(error)")
                   completion(.failure(NSError(
                       domain: "", code: -1,
                       userInfo: [NSLocalizedDescriptionKey: "Error al procesar la respuesta del servidor"]
                   )))
               }
           }.resume()
       }
       
       // MARK: - Crear Body Multipart (DEBE ESTAR DENTRO DE LA CLASE)
       private func crearMultipartBody(
           animal: AnimalRequest,
           imagen: UIImage?,
           boundary: String
       ) -> Data {
           var body = Data()
           
           body.appendFormField(name: "origen", value: animal.origen, boundary: boundary)
           body.appendFormField(name: "idLote", value: "\(animal.idLote)", boundary: boundary)
           
           if let codigoQrMadre = animal.codigoQrMadre, !codigoQrMadre.isEmpty {
               body.appendFormField(name: "codigoQrMadre", value: codigoQrMadre, boundary: boundary)
           }
           
           body.appendFormField(name: "idEspecie", value: "\(animal.idEspecie)", boundary: boundary)
           body.appendFormField(name: "fechaNacimiento", value: animal.fechaNacimiento, boundary: boundary)
           body.appendFormField(name: "sexo", value: animal.sexo, boundary: boundary)
           
           if let peso = animal.peso {
               body.appendFormField(name: "peso", value: "\(peso)", boundary: boundary)
           }
           
           if let precioCompra = animal.precioCompra {
               body.appendFormField(name: "precioCompra", value: "\(precioCompra)", boundary: boundary)
           }
           
           if let imagen = imagen,
              let imageData = imagen.jpegData(compressionQuality: 0.8) {
               body.appendFormFile(
                   name: "imagen",
                   filename: "animal_\(Date().timeIntervalSince1970).jpg",
                   mimeType: "image/jpeg",
                   fileData: imageData,
                   boundary: boundary
               )
           }
           
           body.append("--\(boundary)--\r\n")
           
           return body
       }
    
    // MARK: - POST registrar peso

    func registrarPeso(
        requestBody: AnimalPesoReq,
        completion: @escaping (Result<AnimalResponse, Error>) -> Void
    ) {
        guard let url = URL(
            string: "\(Constants.baseURL)animales/registrar-peso"
        ) else {
            completion(.failure(ServiceError.urlInvalida))
            return
        }

        do {
            let body = try JSONEncoder().encode(requestBody)
            let request = crearRequest(url: url, method: "POST", body: body)

            URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(ServiceError.sinDatos))
                    return
                }

                do {
                    let response = try JSONDecoder()
                        .decode(AnimalResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    completion(.failure(error))
                }

            }.resume()

        } catch {
            completion(.failure(error))
        }
    }

    // MARK: - POST registrar muerte

    func registrarMuerte(
        requestBody: AnimalMuerteReq,
        completion: @escaping (Result<AnimalResponse, Error>) -> Void
    ) {
        guard let url = URL(
            string: "\(Constants.baseURL)animales/registrar-muerte"
        ) else {
            completion(.failure(ServiceError.urlInvalida))
            return
        }

        do {
            let body = try JSONEncoder().encode(requestBody)
            let request = crearRequest(url: url, method: "POST", body: body)

            URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(ServiceError.sinDatos))
                    return
                }

                do {
                    let response = try JSONDecoder()
                        .decode(AnimalResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    completion(.failure(error))
                }

            }.resume()

        } catch {
            completion(.failure(error))
        }
    }

    // MARK: - POST registrar traslado

    func registrarTraslado(
        requestBody: AnimalTrasReq,
        completion: @escaping (Result<AnimalResponse, Error>) -> Void
    ) {
        guard let url = URL(
            string: "\(Constants.baseURL)animales/registrar-traslado"
        ) else {
            completion(.failure(ServiceError.urlInvalida))
            return
        }

        do {
            let body = try JSONEncoder().encode(requestBody)
            let request = crearRequest(url: url, method: "POST", body: body)

            URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(ServiceError.sinDatos))
                    return
                }

                do {
                    let response = try JSONDecoder()
                        .decode(AnimalResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    completion(.failure(error))
                }

            }.resume()

        } catch {
            completion(.failure(error))
        }
    }

    // MARK: - Historiales

    func obtenerHistorialPesaje(
        idAnimal: Int,
        completion: @escaping (Result<[AnimalHistPesaje], Error>) -> Void
    ) {
        historial(
            endpoint: "historial/pesaje",
            idAnimal: idAnimal,
            completion: completion
        )
    }

    func obtenerHistorialSanitario(
        idAnimal: Int,
        completion: @escaping (Result<[AnimalHistSanitario], Error>) -> Void
    ) {
        historial(
            endpoint: "historial/sanitario",
            idAnimal: idAnimal,
            completion: completion
        )
    }

    func obtenerHistorialTraslados(
        idAnimal: Int,
        completion: @escaping (Result<[AnimalHistTraslado], Error>) -> Void
    ) {
        historial(
            endpoint: "historial/traslados",
            idAnimal: idAnimal,
            completion: completion
        )
    }

    private func historial<T: Decodable>(
        endpoint: String,
        idAnimal: Int,
        completion: @escaping (Result<[T], Error>) -> Void
    ) {
        guard let url = URL(
            string: "\(Constants.baseURL)animales/\(idAnimal)/\(endpoint)"
        ) else {
            completion(.failure(ServiceError.urlInvalida))
            return
        }

        let request = crearRequest(url: url, method: "GET")

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(ServiceError.sinDatos))
                return
            }

            do {
                let historial = try JSONDecoder().decode([T].self, from: data)
                completion(.success(historial))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
    
    mutating func appendFormField(name: String, value: String, boundary: String) {
        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
        append("\(value)\r\n")
    }
    
    mutating func appendFormFile(
        name: String,
        filename: String,
        mimeType: String,
        fileData: Data,
        boundary: String
    ) {
        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n")
        append("Content-Type: \(mimeType)\r\n\r\n")
        append(fileData)
        append("\r\n")
    }
}
