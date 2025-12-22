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
    
    
    private var viewModel: DetalleAplicacionesViewModel!
    
    //por el momento es simulado pero esto tiene q llegar de la vista principal hasta aca
    private var granjaId = 1
    private var tipoProtocoloSeleccionado: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewModel()
        setupUI()
        setupTableView()
        setupPickerView()
        setupDatePickers()
        setupBindings()
        loadData()
    }
    
    private func setupViewModel(){
        viewModel = DetalleAplicacionesViewModel(granjaId: granjaId)
    }
    
    private func setupUI(){
        configurarBotonFiltro(btnAplicacionTodos, seleccionado: true)
        configurarBotonFiltro(btnAplicacionVacuna, seleccionado: false)
        configurarBotonFiltro(btnAplicacionTratamiento, seleccionado: false)
        
        btnExportPdf.layer.cornerRadius = 20
        btnExportPdf.backgroundColor = .systemRed
        
        limpiarEstadisticas()
    }
    
    private func configurarBotonFiltro(_ button: UIButton, seleccionado: Bool){
        
        button.layer.borderWidth = 1
        
        if seleccionado {
            button.backgroundColor = .systemBlue
            button.setTitleColor(.white, for: .normal)
            button.layer.borderColor = UIColor.systemBlue.cgColor
        }else{
            button.backgroundColor = .clear
            button.setTitleColor(.black , for: .normal)
            button.layer.borderColor = UIColor.systemBlue.cgColor
        }
    }
    
    private func setupTableView(){
        tableViewAplicacionesRecientes.delegate = self
        tableViewAplicacionesRecientes.dataSource = self
        tableViewAplicacionesRecientes.rowHeight = UITableView.automaticDimension
        
    }
    
    private func setupPickerView(){
        pickerViewLotes.delegate = self
        pickerViewLotes.dataSource = self
    }
    
    private func setupDatePickers(){
        datePickerFechaFin.date = Date()
        datePickerFechaInicio.date = Date()
        
        
        datePickerFechaInicio.addTarget(self, action: #selector(fechaChanged), for: .valueChanged)
        datePickerFechaFin.addTarget(self, action: #selector(fechaChanged), for: .valueChanged)
    }
    
    @objc private func fechaChanged(){
        aplicarFiltros()
    }
    
    private func setupBindings(){
        viewModel.onLotesUpdated = { [weak self] in
            self?.pickerViewLotes.reloadAllComponents()
        }
        
        viewModel.onAplicacionesUpdated = { [weak self] in
            self?.tableViewAplicacionesRecientes.reloadData()
        }
        viewModel.onError = { [weak self] errorMessage in
            self?.showAlert(message: errorMessage)
        }
        
        viewModel.isLoading = { [weak self] isLoading in
            UIApplication.shared.isNetworkActivityIndicatorVisible = isLoading
        }
        
        viewModel.onEstadisticasActualizadas = { [weak self] estadisticas in
            self?.actualizarEstadisticas(estadisticas)
        }
    }
    
    private func loadData(){
        viewModel.fetchLotes()
        aplicarFiltros()
    }
    
    @IBAction func btnTodosPressend(_ sender: UIButton) {
        
        tipoProtocoloSeleccionado = nil
        actualizarBotonesFiltro(seleccionado: sender)
        aplicarFiltros()
    }
    
    @IBAction func btnVacunaPressed(_ sender: UIButton) {
        
        tipoProtocoloSeleccionado = "Vacunacion"
        actualizarBotonesFiltro(seleccionado: sender)
        aplicarFiltros()
    }
    
    @IBAction func btnTratamientoPressed(_ sender: UIButton) {
        
        tipoProtocoloSeleccionado = "Tratamiento"
        actualizarBotonesFiltro(seleccionado: sender)
        aplicarFiltros()
        
    }
    
    @IBAction func btnExportPdfPressend(_ sender: UIButton) {
        
    }
    
    private func actualizarBotonesFiltro(seleccionado: UIButton){
        configurarBotonFiltro(btnAplicacionTodos, seleccionado: seleccionado == btnAplicacionTodos)
        configurarBotonFiltro(btnAplicacionVacuna, seleccionado: seleccionado == btnAplicacionVacuna)
        configurarBotonFiltro(btnAplicacionTratamiento, seleccionado: seleccionado == btnAplicacionTratamiento)
    }
    
    private func aplicarFiltros(){
        let selectedRow = pickerViewLotes.selectedRow(inComponent: 0)
        let loteId = viewModel.getLoteId(at: selectedRow)
        
        viewModel.aplicarFiltros(
            loteId: loteId,
            protocoloTipo: tipoProtocoloSeleccionado,
            fechaInicio: datePickerFechaInicio.date,
            fechaFin: datePickerFechaFin.date
        )
    }
    
    private func actualizarEstadisticas(_ estadisticas: SanidadEstadisticasDTO){
        labelTotalDeAplicaciones.text = String(format: "%.0f", estadisticas.cantidadTotalDosis)
        labelCostoTotal.text = String(format: "S/ %.2f", estadisticas.costoTotal)
        labelAnimalesTratados.text = estadisticas.animalesTratados != nil
        ? "\(estadisticas.animalesTratados!)"
        : "No hay animales"
                                    
        
        labelProductosMasUsados.text = estadisticas.medicamentoMasUsado

    }
    
    private func limpiarEstadisticas(){
        labelTotalDeAplicaciones.text = "0"
        labelCostoTotal.text = "S/0.0"
        labelAnimalesTratados.text = "0"
        labelProductosMasUsados.text = "N/A"
    }
    
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Información", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default))
        present(alert, animated: true)
       }
}


extension ReporteSanitarioViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.numberOfLotes
    }
}

extension ReporteSanitarioViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.getLoteNombre(at: row)
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        aplicarFiltros()
    }
}

extension ReporteSanitarioViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfAplicaciones
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as? DetalleAplicacionesTableViewCell,
                      let aplicacion = viewModel.getAplicacion(at: indexPath.row) else {
                    return UITableViewCell()
                }
                
                cell.configure(
                    nombreProducto: aplicacion.nombreProducto,
                    loteAnimal: viewModel.getLoteAnimalText(at: indexPath.row),
                    costo: viewModel.getCostoText(at: indexPath.row),
                    fecha: viewModel.getFechaFormateada(at: indexPath.row),
                    icono: viewModel.getImagenProducto(at: indexPath.row)
                )
                
                return cell

    }
}

extension ReporteSanitarioViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
