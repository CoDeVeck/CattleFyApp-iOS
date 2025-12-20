import UIKit

class ReporteSanitarioViewController: UIViewController {


    @IBOutlet weak var pickerViewLotes: UIPickerView!
    
    @IBOutlet weak var datePickerFechaInicio: UIDatePicker!
    
    @IBOutlet weak var datePickerFechaFin: UIDatePicker!
    
    @IBOutlet weak var btnAplicacionTodos: UIButton!
    
    @IBOutlet weak var btnAplicacionVacuna: UIButton!
    
    @IBOutlet weak var btnAplicacionTratamiento: UIButton!
    
    @IBOutlet weak var labelTotalDeAplicaciones: UILabel!
    
    @IBOutlet weak var labelCostoTotal: UILabel!
    
    @IBOutlet weak var labelAnimalesTratados: UILabel!
    
    @IBOutlet weak var labelProductosMasUsados: UILabel!
    
    @IBOutlet weak var tableViewAplicacionesRecientes: UITableView!
    
    @IBOutlet weak var btnExportPdf: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    

    

}
