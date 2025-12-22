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

    ]

    private var tiposProduccion: [String] {
        Array(Set(datos.map { $0.tipoProduccion })).sorted()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("Producción por Tipo")
                .font(.headline)
            
            // Leyenda
            HStack(spacing: 16) {
                ForEach(tiposProduccion, id: \.self) { tipo in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(colores[tipo] ?? .gray)
                            .frame(width: 8, height: 8)
                        Text(tipo)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

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

    private var chartProduccion: some View {
        Chart(datos) { item in
            let fecha = parseDate(item.fecha) ?? Date()
            let color = colores[item.tipoProduccion] ?? .gray

            LineMark(
                x: .value("Fecha", fecha),
                y: .value("Cantidad", item.cantidadTotal)
            )
            .foregroundStyle(by: .value("Tipo", item.tipoProduccion))
            .lineStyle(StrokeStyle(lineWidth: 2))
            .interpolationMethod(.catmullRom)

            PointMark(
                x: .value("Fecha", fecha),
                y: .value("Cantidad", item.cantidadTotal)
            )
            .foregroundStyle(by: .value("Tipo", item.tipoProduccion))
            .symbolSize(40)
        }
        .chartForegroundStyleScale([
            "Huevos": colores["Huevos"]!,
            "Leche": colores["Leche"]!
        ])
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 5)) {
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month().day())
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisValueLabel()
            }
        }
        .chartLegend(position: .top, alignment: .leading)
        .frame(height: 300)
        .padding(.horizontal, 4)
    }

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
