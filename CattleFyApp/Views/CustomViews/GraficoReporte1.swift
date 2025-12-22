import SwiftUI
import Charts

struct GraficoReporte1: View {
    
    let datos: [ReporteGrafico1]
    
    
    private var datosAgrupados: [ReporteGrafico1] {
        let grouped = Dictionary(grouping: datos) { $0.fecha }
        return grouped.map { fecha, items in
            let promedio = items.reduce(0.0) { $0 + $1.pesoKg } / Double(items.count)
            return ReporteGrafico1(fecha: fecha, pesoKg: promedio)
        }
        .sorted { parseDate($0.fecha) ?? Date() < parseDate($1.fecha) ?? Date() }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text("Evolución de Peso")
                .font(.headline)
                .foregroundColor(.primary)
            
            if datos.isEmpty {
                vistaVacia
            } else {
                Chart {
                    ForEach(datosAgrupados) { item in
                        LineMark(
                            x: .value("Fecha", parseDate(item.fecha) ?? Date()),
                            y: .value("Peso (kg)", item.pesoKg)
                        )
                        .foregroundStyle(.blue)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .interpolationMethod(.catmullRom)
                        
                        AreaMark(
                            x: .value("Fecha", parseDate(item.fecha) ?? Date()),
                            y: .value("Peso (kg)", item.pesoKg)
                        )
                        .foregroundStyle(
                            .linearGradient(
                                colors: [.blue.opacity(0.3), .blue.opacity(0.05)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        
                        PointMark(
                            x: .value("Fecha", parseDate(item.fecha) ?? Date()),
                            y: .value("Peso (kg)", item.pesoKg)
                        )
                        .foregroundStyle(.blue)
                        .symbolSize(50)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .month)) { value in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let peso = value.as(Double.self) {
                                Text("\(Int(peso)) kg")
                            }
                        }
                    }
                }
                .frame(height: 300)
                .padding(.horizontal, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private var vistaVacia: some View {
        VStack {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.3))
            
            Text("No hay datos disponibles")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(height: 300)
    }
    
    private func parseDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
}

#Preview("GraficoReporte1") {
    GraficoReporte1(datos: [
        ReporteGrafico1(fecha: "2024-01-15", pesoKg: 280.50),
        ReporteGrafico1(fecha: "2024-02-15", pesoKg: 315.00),
        ReporteGrafico1(fecha: "2024-03-15", pesoKg: 345.75),
        ReporteGrafico1(fecha: "2024-04-15", pesoKg: 378.20),
        ReporteGrafico1(fecha: "2024-05-15", pesoKg: 405.00)
    ])
}
