import UIKit

class ReporteHomeViewController: UIViewController {

    
    
    @IBOutlet weak var containerView: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    
    @IBAction func cambiarVista(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            MostrarViewController(id:"VC_A")
        case 1:
            MostrarViewController(id:"VC_B")
        default :
            break
        }
    }
    
   
    func MostrarViewController(id:String){
        let storyboard = UIStoryboard(name: "FarmFlow", bundle: nil)
            let nuevoVC = storyboard.instantiateViewController(withIdentifier: id)

           
            children.forEach { child in
                child.willMove(toParent: nil)
                child.view.removeFromSuperview()
                child.removeFromParent()
            }

            
            addChild(nuevoVC)
        
        nuevoVC.view.translatesAutoresizingMaskIntoConstraints = false
        nuevoVC.view.frame = containerView.bounds
        
        containerView.addSubview(nuevoVC.view)
        
        NSLayoutConstraint.activate([
            nuevoVC.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            nuevoVC.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            nuevoVC.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            nuevoVC.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        nuevoVC.didMove(toParent: self)
    }
}
