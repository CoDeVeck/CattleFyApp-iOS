//
//  UIViewController+Alert.swift
//  CattleFyApp
//
//  Created by Andy Yahir Valdivia Centeno on 16/12/25.
//
import UIKit

extension UIViewController {

    func mostrarAlerta(
        titulo: String = "Aviso",
        mensaje: String,
        onAceptar: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(
            title: titulo,
            message: mensaje,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            onAceptar?()
        })

        present(alert, animated: true)
    }
}
