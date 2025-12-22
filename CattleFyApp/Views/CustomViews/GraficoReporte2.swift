//
//  GraficoReporte2.swift
//  CattleFyApp
//

import SwiftUI
import Charts

struct GraficoReporte2: View {

    let datos: [ReporteGrafico2]

    private let colores: [String: Color] = [
        "Huevos": .orange,
        "Leche": .blue,
        "Carne": .red,
        "Lana": .purple
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("Producción por Tipo")
                .font(.headline)

            if datos.isEmpty {
                vistaVacia
            } else {
                chartProduccion
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    // MARK: - Vista vacía
    private var vistaVacia: some View {
        VStack {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.3))

            Text("No hay datos disponibles")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(height: 300)
    }

    // MARK: - Chart
    private var chartProduccion: some View {
        Chart {

            ForEach(datos) { item in

                let fecha = parseDate(item.fecha) ?? Date()
                let color = colores[item.tipoProduccion] ?? .gray

                LineMark(
                    x: .value("Fecha", fecha),
                    y: .value("Cantidad", item.cantidadTotal)
                )
                .foregroundStyle(color)
                .lineStyle(StrokeStyle(lineWidth: 2))

                PointMark(
                    x: .value("Fecha", fecha),
                    y: .value("Cantidad", item.cantidadTotal)
                )
                .foregroundStyle(color)
                .symbolSize(40)
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 3)) {
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month().day())
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .frame(height: 300)
        .padding(.horizontal, 4)
    }

    // MARK: - Helpers
    private func parseDate(_ dateString: String) -> Date? {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.date(from: dateString)
    }
}

#Preview {
    GraficoReporte2(datos: [
        ReporteGrafico2(fecha: "2024-01-14", tipoProduccion: "Huevos", cantidadTotal: 222),
        ReporteGrafico2(fecha: "2024-01-14", tipoProduccion: "Leche", cantidadTotal: 44),
        ReporteGrafico2(fecha: "2024-01-17", tipoProduccion: "Huevos", cantidadTotal: 225),
        ReporteGrafico2(fecha: "2024-01-17", tipoProduccion: "Leche", cantidadTotal: 44.5),
        ReporteGrafico2(fecha: "2024-01-20", tipoProduccion: "Huevos", cantidadTotal: 228),
        ReporteGrafico2(fecha: "2024-01-20", tipoProduccion: "Leche", cantidadTotal: 45)
    ])
}
