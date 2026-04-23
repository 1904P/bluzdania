//
//  PriceTimeChartView.swift
//  Stocks+Physics
//
// 
//

import SwiftUI
import Charts

struct PriceTimelinePoint: Identifiable {
    let id = UUID()
    let date: Date
    let price: Double
}

struct PriceTimeChartView: View {
    let points: [PriceTimelinePoint]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("График цены")
                .font(.headline)

            Chart {
                ForEach(points) { point in
                    LineMark(
                        x: .value("Дата", point.date),
                        y: .value("Цена", point.price)
                    )
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("Дата", point.date),
                        y: .value("Цена", point.price)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(.blue.opacity(0.12))
                }

                if let last = points.last {
                    PointMark(
                        x: .value("Дата", last.date),
                        y: .value("Цена", last.price)
                    )
                    .annotation(position: .top, alignment: .trailing) {
                        Text(String(format: "%.2f", last.price))
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            .frame(height: 260)
            .chartYAxis {
                AxisMarks(position: .trailing)
            }
        }
        .padding(.vertical, 4)
    }
}
