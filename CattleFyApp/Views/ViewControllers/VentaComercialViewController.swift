import UIKit

class VentaComercialViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func switchCambiarViewController(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            MostrarViewController(id:"WC_A")
        case 1:
            MostrarViewController(id:"WC_B")
        default :
            break
        }
        
    }
    
    func MostrarViewController(id: String) {
        let storyboard = UIStoryboard(name: "VentaComercial", bundle: nil)
        let nuevoVC = storyboard.instantiateViewController(withIdentifier: id)
        
        // Eliminar el anterior
        children.forEach { child in
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
        
        // Agregar el nuevo
        addChild(nuevoVC)
        containerView.addSubview(nuevoVC.view)
        
        nuevoVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nuevoVC.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            nuevoVC.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            nuevoVC.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            nuevoVC.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        nuevoVC.didMove(toParent: self)
    }
    
}

