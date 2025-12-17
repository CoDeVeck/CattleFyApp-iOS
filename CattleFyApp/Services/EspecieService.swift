//
//  EspecieService.swift
//  CattleFyApp
//
//  Created by Andy Yahir Valdivia Centeno on 16/12/25.
//
import Foundation

class EspecieService {
    static let shared = EspecieService()
    private init() {}

    private func getAuthToken() -> String? {
        UserDefaults.standard.string(forKey: "authToken")
    }

    func obtenerEspecies(completion: @escaping (Result<[EspecieResponse], Error>) -> Void) {
        guard let token = getAuthToken() else {
            completion(.failure(NSError(
                domain: "", code: 401,
                userInfo: [NSLocalizedDescriptionKey: "No hay sesión activa"]
            )))
            return
        }

        guard let url = URL(string: "\(Constants.baseURL)especies/list") else {
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
                let especies = try JSONDecoder().decode([EspecieResponse].self, from: data)
                completion(.success(especies))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
