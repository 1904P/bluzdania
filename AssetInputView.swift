import SwiftUI

struct AssetInputView: View {
    @StateObject private var viewModel = AssetInputViewModel()

    var body: some View {
        NavigationStack {
            Form {
                basicSection
                marketSection
                momentumSection
                structuralSection
                qualitativeFactorsSection
                togglesSection
                computedMetricsSection
                validationSection
                actionSection

                marketRegimeSection
                impulseSection
                levelSection
                forecastSection
                strategySection
                chartsSection

                analysisResultSection
            }
            .navigationTitle("Анализ актива")
        }
    }
}

// MARK: - Sections
private extension AssetInputView {

    var basicSection: some View {
        Section("Основные данные") {
            TextField("Тикер", text: $viewModel.input.ticker)
                .textInputAutocapitalization(.characters)

            HStack {
                Text("Текущая цена")
                Spacer()
                TextField("0.00", value: $viewModel.input.currentPrice, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 140)
            }

            DatePicker(
                "Текущая дата",
                selection: $viewModel.input.currentDate,
                displayedComponents: [.date, .hourAndMinute]
            )
        }
    }

    var marketSection: some View {
        Section("Рыночные параметры") {
            numberRow(title: "RSI", value: $viewModel.input.rsi)
            numberRow(title: "Волатильность", value: $viewModel.input.volatility)
            numberRow(title: "Объём", value: $viewModel.input.volume)
            numberRow(title: "Средний объём", value: $viewModel.input.averageVolume)
            numberRow(title: "MACD", value: $viewModel.input.macd)
            numberRow(title: "ATR", value: $viewModel.input.atr)
            numberRow(title: "EMA 50", value: $viewModel.input.ema50)
            numberRow(title: "EMA 200", value: $viewModel.input.ema200)
        }
    }

    var momentumSection: some View {
        Section("Моментум") {
            numberRow(title: "Моментум 1D", value: $viewModel.input.momentum1D)
            numberRow(title: "Моментум 5D", value: $viewModel.input.momentum5D)
            numberRow(title: "Моментум 20D", value: $viewModel.input.momentum20D)
        }
    }

    var structuralSection: some View {
        Section("Структура и уровни") {
            numberRow(title: "Уровень поддержки", value: $viewModel.input.supportLevel)
            numberRow(title: "Уровень сопротивления", value: $viewModel.input.resistanceLevel)

            sliderRow(
                title: "Вероятность пробоя вверх",
                value: $viewModel.input.breakoutUpProbability,
                range: 0...1
            )

            sliderRow(
                title: "Вероятность пробоя вниз",
                value: $viewModel.input.breakoutDownProbability,
                range: 0...1
            )
        }
    }

    var qualitativeFactorsSection: some View {
        Section("Факторы, поддержка и сентимент") {
            sliderRow(
                title: "Государственная значимость",
                value: $viewModel.input.governmentImportance,
                range: 0...1
            )

            sliderRow(
                title: "Научная значимость",
                value: $viewModel.input.scienceImportance,
                range: 0...1
            )

            sliderRow(
                title: "Стратегическая значимость сектора",
                value: $viewModel.input.strategicSectorImportance,
                range: 0...1
            )

            sliderRow(
                title: "Поддержка акционеров",
                value: $viewModel.input.shareholderSupport,
                range: 0...1
            )

            sliderRow(
                title: "Интерес розничных инвесторов",
                value: $viewModel.input.retailInvestorInterest,
                range: 0...1
            )

            sliderRow(
                title: "Поддержка институционалов",
                value: $viewModel.input.institutionalSupport,
                range: 0...1
            )

            sliderRow(
                title: "Позитив новостного фона",
                value: $viewModel.input.newsPositivity,
                range: -1...1
            )

            sliderRow(
                title: "Индекс страха и жадности",
                value: $viewModel.input.marketFearGreed,
                range: -1...1
            )

            sliderRow(
                title: "Бычья сила",
                value: $viewModel.input.bullsStrength,
                range: 0...1
            )

            sliderRow(
                title: "Медвежья сила",
                value: $viewModel.input.bearsStrength,
                range: 0...1
            )
        }
    }

    var togglesSection: some View {
        Section("Сигналы и флаги") {
            Toggle("Есть пробой вверх", isOn: $viewModel.input.hasBreakoutUp)
            Toggle("Есть пробой вниз", isOn: $viewModel.input.hasBreakoutDown)
            Toggle("Стратегически важный актив", isOn: $viewModel.input.isStrategicallyImportant)
            Toggle("Есть государственная поддержка", isOn: $viewModel.input.hasGovernmentSupport)
        }
    }

    var computedMetricsSection: some View {
        Section("Автоматические метрики") {
            metricRow(title: "Относительный объём", value: viewModel.input.relativeVolume)
            metricRow(title: "Расстояние до поддержки", value: viewModel.input.distanceToSupport)
            metricRow(title: "Расстояние до сопротивления", value: viewModel.input.distanceToResistance)
            metricRow(title: "Расстояние до поддержки, %", value: viewModel.input.distanceToSupportPct, isPercent: true)
            metricRow(title: "Расстояние до сопротивления, %", value: viewModel.input.distanceToResistancePct, isPercent: true)
            metricRow(title: "Индекс перекупленности", value: viewModel.input.overboughtScore, isPercent: true)
            metricRow(title: "Индекс перепроданности", value: viewModel.input.oversoldScore, isPercent: true)
            metricRow(title: "Сила толпы", value: viewModel.input.crowdForce)
            metricRow(title: "Нормализованная сила толпы", value: viewModel.input.normalizedCrowdForce, isPercent: true)
            metricRow(title: "Индекс стратегической поддержки", value: viewModel.input.strategicSupportScore, isPercent: true)
            metricRow(title: "Индекс риска пробоя", value: viewModel.input.breakoutRiskScore, isPercent: true)
            metricRow(title: "Близость к поддержке", value: viewModel.input.supportClosenessScore, isPercent: true)
            metricRow(title: "Близость к сопротивлению", value: viewModel.input.resistanceClosenessScore, isPercent: true)
            metricRow(title: "Индекс силы тренда", value: viewModel.input.trendStrengthScore, isPercent: true)

            HStack {
                Text("Тренд")
                Spacer()
                Text(viewModel.input.trendDirection)
                    .foregroundColor(.secondary)
            }
        }
    }

    var validationSection: some View {
        Section("Проверка данных") {
            if viewModel.input.validationErrors.isEmpty {
                Text("Все поля заполнены корректно.")
                    .foregroundColor(.green)
            } else {
                ForEach(viewModel.input.validationErrors, id: \.self) { error in
                    Text("• \(error)")
                        .foregroundColor(.red)
                }
            }
        }
    }

    var actionSection: some View {
        Section {
            Button {
                viewModel.analyze()
            } label: {
                HStack {
                    Spacer()
                    Text("Провести анализ")
                        .fontWeight(.semibold)
                    Spacer()
                }
            }
        }
    }

    var marketRegimeSection: some View {
        Section("Рыночный режим") {
            if let result = viewModel.regimeResult {
                HStack {
                    Text("Режим")
                    Spacer()
                    Text(regimeTitle(result.regime.rawValue))
                        .foregroundColor(.secondary)
                }

                metricRow(title: "Сила режима", value: result.strength, isPercent: true)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Комментарий")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text(result.comment)
                        .foregroundColor(.secondary)
                        .textSelection(.enabled)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Отладочные оценки")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    ForEach(
                        result.debugScores.sorted(by: { $0.value > $1.value }),
                        id: \.key
                    ) { item in
                        HStack {
                            Text(regimeTitle(item.key.rawValue))
                            Spacer()
                            Text(String(format: "%.3f", item.value))
                                .foregroundColor(.secondary)
                                .monospacedDigit()
                        }
                    }
                }
            } else {
                Text("Нажмите «Провести анализ», чтобы определить рыночный режим.")
                    .foregroundColor(.secondary)
            }
        }
    }

    var impulseSection: some View {
        Section("Сила импульса") {
            if let result = viewModel.impulseResult {
                metricRow(title: "Вероятность продолжения роста", value: result.continuationProbabilityUp, isPercent: true)
                metricRow(title: "Вероятность продолжения снижения", value: result.continuationProbabilityDown, isPercent: true)
                metricRow(title: "Вероятность разворота", value: result.reversalProbability, isPercent: true)
                metricRow(title: "Вероятность истощения импульса", value: result.exhaustionProbability, isPercent: true)
                metricRow(title: "Индекс бычьего импульса", value: result.bullishImpulseScore, isPercent: true)
                metricRow(title: "Индекс медвежьего импульса", value: result.bearishImpulseScore, isPercent: true)
                metricRow(title: "Риск ложного пробоя вверх", value: result.falseBreakoutRiskUp, isPercent: true)
                metricRow(title: "Риск ложного пробоя вниз", value: result.falseBreakoutRiskDown, isPercent: true)

                HStack {
                    Text("Ускорение тренда")
                    Spacer()
                    Text(String(format: "%.3f", result.trendAccelerationScore))
                        .foregroundColor(.secondary)
                        .monospacedDigit()
                }

                if !result.debugNotes.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Отладочные заметки")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        ForEach(result.debugNotes, id: \.self) { note in
                            Text("• \(note)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            } else {
                Text("Нажмите «Провести анализ», чтобы рассчитать силу импульса.")
                    .foregroundColor(.secondary)
            }
        }
    }

    var levelSection: some View {
        Section("Отработка уровней") {
            if let result = viewModel.levelResult {
                metricRow(title: "Сила защиты поддержки", value: result.supportDefenseScore, isPercent: true)
                metricRow(title: "Сила защиты сопротивления", value: result.resistanceDefenseScore, isPercent: true)
                metricRow(title: "Риск пробоя вверх", value: result.breakoutRiskUp, isPercent: true)
                metricRow(title: "Риск пробоя вниз", value: result.breakoutRiskDown, isPercent: true)

                HStack {
                    Text("Ожидаемая реакция")
                    Spacer()
                    Text(levelReactionTitle(result.expectedReactionNearLevel.rawValue))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.trailing)
                }

                Text(result.explanation)
                    .foregroundColor(.secondary)
                    .textSelection(.enabled)
            } else {
                Text("Нажмите «Провести анализ», чтобы оценить отработку уровней.")
                    .foregroundColor(.secondary)
            }
        }
    }

    var forecastSection: some View {
        Section("Сценарный прогноз") {
            if let result = viewModel.forecastResult {
                metricRow(title: "Вероятность бычьего сценария", value: result.bullProbability, isPercent: true)
                metricRow(title: "Вероятность базового сценария", value: result.baseProbability, isPercent: true)
                metricRow(title: "Вероятность медвежьего сценария", value: result.bearProbability, isPercent: true)
                metricRow(title: "Ожидаемая цена через 30 дней", value: result.expectedPrice30D)
                metricRow(title: "Ожидаемая доходность за 30 дней", value: result.expectedReturn30D, isPercent: true)
                metricRow(title: "Уверенность прогноза", value: result.confidence, isPercent: true)

                Text(result.summary)
                    .foregroundColor(.secondary)
                    .textSelection(.enabled)
            } else {
                Text("Нажмите «Провести анализ», чтобы построить прогноз.")
                    .foregroundColor(.secondary)
            }
        }
    }

    var strategySection: some View {
        Section("Торговый план") {
            if let result = viewModel.strategyResult {
                HStack {
                    Text("Сигнал")
                    Spacer()
                    Text(actionTitle(result.action.rawValue))
                        .foregroundColor(.secondary)
                }

                metricRow(title: "Уверенность", value: result.confidence, isPercent: true)
                metricRow(title: "Размер позиции", value: result.positionSizeFraction, isPercent: true)
                metricRow(title: "Стоп-лосс", value: result.stopLossPrice)
                metricRow(title: "Тейк-профит", value: result.takeProfitPrice)
                metricRow(title: "Риск / прибыль", value: result.riskRewardRatio)

                Text(result.rationale)
                    .foregroundColor(.secondary)
                    .textSelection(.enabled)
            } else {
                Text("Нажмите «Провести анализ», чтобы собрать торговый план.")
                    .foregroundColor(.secondary)
            }
        }
    }

    var chartsSection: some View {
        Section("Графики") {
            if let forecast = viewModel.forecastResult {
                VStack(alignment: .leading, spacing: 20) {
                    ScenarioChartView(forecast: forecast)
                        .frame(minHeight: 340)

                    PriceTimeChartView(
                        points: makePriceTimelinePoints()
                    )
                    .frame(minHeight: 300)
                }
            } else {
                Text("Сначала проведите анализ, чтобы построить графики.")
                    .foregroundColor(.secondary)
            }
        }
    }

    var analysisResultSection: some View {
        Section("Итог анализа") {
            if viewModel.didAnalyze {
                Text(viewModel.analysisMessage)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
            } else {
                Text("Нажмите «Провести анализ», чтобы получить итоговую сводку.")
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Reusable UI
private extension AssetInputView {

    func numberRow(title: String, value: Binding<Double>) -> some View {
        HStack {
            Text(title)
            Spacer()
            TextField("0", value: value, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 140)
        }
    }

    func sliderRow(title: String, value: Binding<Double>, range: ClosedRange<Double>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                Spacer()
                Text(String(format: "%.2f", value.wrappedValue))
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }

            Slider(value: value, in: range)
        }
        .padding(.vertical, 4)
    }

    func metricRow(title: String, value: Double, isPercent: Bool = false) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(
                isPercent
                ? String(format: "%.2f%%", value * 100)
                : String(format: "%.4f", value)
            )
            .foregroundColor(.secondary)
            .monospacedDigit()
        }
    }
}

// MARK: - Chart helpers
private extension AssetInputView {

    func makePriceTimelinePoints() -> [PriceTimelinePoint] {
        guard let forecast = viewModel.forecastResult else { return [] }

        let calendar = Calendar.current
        let startDate = viewModel.input.currentDate
        let startPrice = max(viewModel.input.currentPrice, 0.0001)
        let endPrice = max(forecast.expectedPrice30D, 0.0001)

        let confidence = forecast.confidence

        let continuationUp = viewModel.impulseResult?.continuationProbabilityUp ?? 0.5
        let continuationDown = viewModel.impulseResult?.continuationProbabilityDown ?? 0.5
        let reversal = viewModel.impulseResult?.reversalProbability ?? 0.3

        let bullishImpulse = viewModel.impulseResult?.bullishImpulseScore ?? 0.5
        let bearishImpulse = viewModel.impulseResult?.bearishImpulseScore ?? 0.5

        let positionBias = viewModel.strategyResult?.positionSizeFraction ?? 0.0

        let days = 30

        let driftStrength =
            (continuationUp - continuationDown) * 0.45 +
            (bullishImpulse - bearishImpulse) * 0.35 +
            (positionBias - 0.5) * 0.20

        let volatilityStrength =
            max(0.02, viewModel.input.volatility) * 0.35 +
            reversal * 0.10 +
            (1 - confidence) * 0.12

        var points: [PriceTimelinePoint] = []

        for day in 0...days {
            let t = Double(day) / Double(days)
            let date = calendar.date(byAdding: .day, value: day, to: startDate) ?? startDate

            let baseTrend = startPrice + (endPrice - startPrice) * t

            let wave1 = sin(t * .pi * 3.2) * volatilityStrength * startPrice * (0.55 + t * 0.45)
            let wave2 = sin(t * .pi * 8.0) * volatilityStrength * startPrice * 0.18
            let directionalBend = driftStrength * startPrice * t * (1 - t) * 0.9

            let rawPrice = baseTrend + wave1 + wave2 + directionalBend
            let price = max(0.0001, rawPrice)

            points.append(
                PriceTimelinePoint(
                    date: date,
                    price: price
                )
            )
        }

        if !points.isEmpty {
            points[0] = PriceTimelinePoint(date: startDate, price: startPrice)
            let lastDate = calendar.date(byAdding: .day, value: days, to: startDate) ?? startDate
            points[days] = PriceTimelinePoint(date: lastDate, price: endPrice)
        }

        return points
    }
}

// MARK: - Russian titles for enums/raw values
private extension AssetInputView {

    func regimeTitle(_ value: String) -> String {
        switch value {
        case "strongBullTrend":
            return "Сильный бычий тренд"
        case "weakBullTrend":
            return "Слабый бычий тренд"
        case "sideways":
            return "Боковик"
        case "weakBearTrend":
            return "Слабый медвежий тренд"
        case "strongBearTrend":
            return "Сильный медвежий тренд"
        case "panicSelloff":
            return "Паническая распродажа"
        case "speculativePump":
            return "Спекулятивный памп"
        case "stateControlledMode":
            return "Режим внешней поддержки"
        default:
            return value
        }
    }

    func actionTitle(_ value: String) -> String {
        switch value {
        case "strongBuy":
            return "Агрессивная покупка"
        case "buy":
            return "Покупка"
        case "accumulate":
            return "Набор позиции"
        case "hold":
            return "Удержание"
        case "reduce":
            return "Сокращение позиции"
        case "sell":
            return "Продажа"
        case "strongSell":
            return "Агрессивная продажа"
        case "wait":
            return "Ожидание"
        default:
            return value
        }
    }

    func levelReactionTitle(_ value: String) -> String {
        switch value {
        case "bounceFromSupport":
            return "Отскок от поддержки"
        case "rejectionFromResistance":
            return "Отбой от сопротивления"
        case "breakoutUp":
            return "Пробой вверх"
        case "breakoutDown":
            return "Пробой вниз"
        case "compression":
            return "Сжатие у уровня"
        case "neutral":
            return "Нейтрально"
        default:
            return value
        }
    }
}

#Preview {
    AssetInputView()
}
