//
//  ScenarioChartView.swift
//  Stocks+Physics
//
//  
//
import SwiftUI
import Charts

struct ScenarioChartView: View {
    let forecast: ScenarioForecastOutput

    @State private var selectedDay: Int?

    private var selectedPoint: ForecastPoint? {
        guard let selectedDay else { return nil }
        return forecast.points.first(where: { $0.day == selectedDay })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Chart {
                ForEach(forecast.points) { point in
                    LineMark(
                        x: .value("День", point.day),
                        y: .value("Bull", point.bullPrice)
                    )
                    .foregroundStyle(.green)

                    LineMark(
                        x: .value("День", point.day),
                        y: .value("Base", point.basePrice)
                    )
                    .foregroundStyle(.blue)

                    LineMark(
                        x: .value("День", point.day),
                        y: .value("Bear", point.bearPrice)
                    )
                    .foregroundStyle(.red)

                    if let selectedDay, selectedDay == point.day {
                        PointMark(
                            x: .value("Выбранный день", point.day),
                            y: .value("Выбранное Base", point.basePrice)
                        )
                        .symbolSize(60)
                    }
                }

                if let selectedPoint {
                    RuleMark(x: .value("Выбор", selectedPoint.day))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(height: 260)
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let plotFrame = geometry[proxy.plotAreaFrame]
                                    let x = value.location.x - plotFrame.origin.x

                                    guard x >= 0, x <= proxy.plotAreaSize.width else { return }

                                    if let day: Int = proxy.value(atX: x) {
                                        selectedDay = max(0, min(30, day))
                                    }
                                }
                        )
                }
            }

            if let point = selectedPoint {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Выбранная точка")
                        .font(.headline)

                    Text("Дата: \(point.date.formatted(date: .abbreviated, time: .omitted))")
                    Text("Bull: \(point.bullPrice, specifier: "%.2f")")
                    Text("Base: \(point.basePrice, specifier: "%.2f")")
                    Text("Bear: \(point.bearPrice, specifier: "%.2f")")
                }
                .font(.subheadline)
            } else {
                Text("Нажмите на график, чтобы просмотреть дату и цену")
                    .foregroundColor(.secondary)
            }
        }
    }
}
