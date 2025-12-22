import SwiftUI
import Charts

struct GraficoReporte1: View {
  
  let datos: [ReporteGrafico1]
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      
      Text("Evolución de Peso")
        .font(.headline)
        .foregroundColor(.primary)
      
      if datos.isEmpty {
        // Estado vacío
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
      } else {
        Chart {
          ForEach(datos) { item in
            // Línea principal
            LineMark(
              x: .value("Fecha", parseDate(item.fecha) ?? Date()),
              y: .value("Peso (kg)", item.pesoKg)
            )
            .foregroundStyle(.blue)
            .lineStyle(StrokeStyle(lineWidth: 2))
            .interpolationMethod(.catmullRom)
            
            // Área bajo la línea
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
            
            // Puntos
            PointMark(
              x: .value("Fecha", parseDate(item.fecha) ?? Date()),
              y: .value("Peso (kg)", item.pesoKg)
            )
            .foregroundStyle(.blue)
            .symbolSize(50)
          }
        }
        .chartXAxis {
          AxisMarks(values: .stride(by: .day, count: obtenerStrideDias())) { value in
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
  
  private func parseDate(_ dateString: String) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.date(from: dateString)
  }
  
  private func obtenerStrideDias() -> Int {
    // Ajustar stride según cantidad de datos
    if datos.count > 20 {
      return 7 // Mostrar cada 7 días
    } else if datos.count > 10 {
      return 3 // Mostrar cada 3 días
    } else {
      return 1 // Mostrar todos
    }
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
