//
//  CategoriaManejoService.swift
//  CattleFyApp
//
//  Created by Andy Yahir Valdivia Centeno on 16/12/25.
//
import Foundation

class CategoriaManejoService {
    static let shared = CategoriaManejoService()
    private init() {}

    private func getAuthToken() -> String? {
        UserDefaults.standard.string(forKey: "authToken")
    }

    func obtenerCategorias(
        especieId: Int,
        completion: @escaping (Result<[CategoriaManejoResponse], Error>) -> Void
    ) {
        guard let token = getAuthToken() else {
            completion(.failure(NSError(
                domain: "", code: 401,
                userInfo: [NSLocalizedDescriptionKey: "No hay sesión activa"]
            )))
            return
        }

        guard let url = URL(string: "\(Constants.baseURL)categoriamanejo/por-especie/\(especieId)") else {
            completion(.failure(NSError(
                domain: "", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "URL inválida"]
            )))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, error in
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
                let resultado = try JSONDecoder()
                    .decode(ResultadoResponse<[CategoriaManejoResponse]>.self, from: data)

                if resultado.valor, let categorias = resultado.data {
                    completion(.success(categorias))
                } else {
                    completion(.failure(NSError(
                        domain: "", code: -1,
                        userInfo: [NSLocalizedDescriptionKey: resultado.mensaje]
                    )))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
