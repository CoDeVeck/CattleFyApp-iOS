import Foundation

struct VentaListadoResponse : Codable {
    let ventaId: Int
    let loteId: Int
    let loteNombre: String
    let especieNombre: String
    let categoriaManejoNombre: String
    let roiReal: Double
    let roiObjetivo: Double
    let cumplioObjetivo: Bool
    let cantidadAnimalesVivos: Int
    let pesoPromedioLote: Decimal
    let sumaTotalPesos: Decimal
    let costoTotalVenta: Decimal
    let precioSugeridoPorKg: Decimal
    let fechaVenta: Date
    let tipoVenta: String
    let tipoAlcanceVenta: String
}
