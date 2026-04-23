//
//  MarketRegimeAnalyzer.swift
//  Stocks+Physics
//
// 
//


import Foundation

final class MarketRegimeAnalyzer {

    func detectRegime(from input: AssetInputData) -> MarketRegimeResult {
        let scores = calculateScores(input: input)

        guard let best = scores.max(by: { $0.value < $1.value }) else {
            return MarketRegimeResult(
                regime: .sideways,
                strength: 0,
                comment: "Невозможно определить рыночный режим",
                debugScores: scores
            )
        }

        let strength = normalizedStrength(bestScore: best.value, allScores: Array(scores.values))
        let comment = buildComment(for: best.key, strength: strength, input: input, scores: scores)

        return MarketRegimeResult(
            regime: best.key,
            strength: strength,
            comment: comment,
            debugScores: scores
        )
    }

    // MARK: - Scoring

    private func calculateScores(input: AssetInputData) -> [MarketRegime: Double] {
        var scores: [MarketRegime: Double] = [:]

        let rsiBull = clamp((input.rsi - 50) / 30, min: 0, max: 1)
        let rsiBear = clamp((50 - input.rsi) / 30, min: 0, max: 1)
        let overbought = clamp((input.rsi - 70) / 20, min: 0, max: 1)
        let oversold = clamp((30 - input.rsi) / 20, min: 0, max: 1)

        let macdBull = clamp(input.macd / 5, min: 0, max: 1)
        let macdBear = clamp(-input.macd / 5, min: 0, max: 1)
        let macdNeutral = clamp(1 - abs(input.macd) / 2, min: 0, max: 1)

        let momentumComposite = (
            input.momentum1D * 0.5 +
            input.momentum5D * 0.3 +
            input.momentum20D * 0.2
        )

        let momentumBull = clamp(momentumComposite / 10, min: 0, max: 1)
        let momentumBear = clamp(-momentumComposite / 10, min: 0, max: 1)
        let momentumNeutral = clamp(1 - abs(momentumComposite) / 4, min: 0, max: 1)

        let trendBull = clamp(input.normalizedTrendScore, min: 0, max: 1)
        let trendBear = clamp(-input.normalizedTrendScore, min: 0, max: 1)
        let trendFlat = input.normalizedTrendScore == 0 ? 1.0 : 0.0

        let relativeVolume = clamp(input.relativeVolume / 2.5, min: 0, max: 1)
        let abnormalVolume = clamp((input.relativeVolume - 1.2) / 1.5, min: 0, max: 1)
        let normalVolume = clamp(1 - abs(input.relativeVolume - 1.0) / 0.5, min: 0, max: 1)

        let highVolatility = clamp(input.volatility / 1.0, min: 0, max: 1)
        let lowVolatility = clamp(1 - input.volatility / 0.35, min: 0, max: 1)

        let bullStrength = clamp(
            input.retailInvestorInterest * 0.45 +
            input.institutionalSupport * 0.35 +
            max(0, input.newsPositivity) * 0.20,
            min: 0, max: 1
        )

        let bearStrength = clamp(
            max(0, -input.marketFearGreed) * 0.35 +
            max(0, -input.newsPositivity) * 0.35 +
            input.breakoutDownProbability * 0.30,
            min: 0, max: 1
        )

        let governmentIntervention = clamp(
            input.governmentImportance * 0.35 +
            input.strategicSectorImportance * 0.25 +
            (input.hasGovernmentSupport ? 0.20 : 0.0) +
            (input.isStrategicallyImportant ? 0.20 : 0.0),
            min: 0, max: 1
        )

        // СилБ
        scores[.strongBullTrend] =
            0.24 * trendBull +
            0.18 * rsiBull +
            0.16 * macdBull +
            0.16 * momentumBull +
            0.10 * bullStrength +
            0.08 * relativeVolume +
            0.08 * (input.hasBreakoutUp ? 1.0 : 0.0)

        // СлБ
        scores[.weakBullTrend] =
            0.24 * trendBull +
            0.15 * clamp((input.rsi - 52) / 15, min: 0, max: 1) +
            0.14 * clamp(input.macd / 2.5, min: 0, max: 1) +
            0.14 * clamp(momentumComposite / 5, min: 0, max: 1) +
            0.12 * bullStrength +
            0.10 * lowVolatility +
            0.11 * normalVolume

        // Б
        scores[.sideways] =
            0.22 * clamp(1 - abs(input.rsi - 50) / 15, min: 0, max: 1) +
            0.20 * macdNeutral +
            0.18 * momentumNeutral +
            0.18 * trendFlat +
            0.12 * lowVolatility +
            0.10 * normalVolume

        // СлМ
        scores[.weakBearTrend] =
            0.24 * trendBear +
            0.15 * clamp((48 - input.rsi) / 15, min: 0, max: 1) +
            0.14 * clamp(-input.macd / 2.5, min: 0, max: 1) +
            0.14 * clamp(-momentumComposite / 5, min: 0, max: 1) +
            0.12 * bearStrength +
            0.10 * lowVolatility +
            0.11 * normalVolume

        // СилМ
        scores[.strongBearTrend] =
            0.24 * trendBear +
            0.18 * rsiBear +
            0.16 * macdBear +
            0.16 * momentumBear +
            0.10 * bearStrength +
            0.08 * relativeVolume +
            0.08 * (input.hasBreakoutDown ? 1.0 : 0.0)

        // Паника
        scores[.panicSelloff] =
            0.18 * oversold +
            0.16 * macdBear +
            0.16 * momentumBear +
            0.16 * highVolatility +
            0.14 * abnormalVolume +
            0.12 * bearStrength +
            0.08 * input.breakoutDownProbability

        // Спек
        scores[.speculativePump] =
            0.18 * overbought +
            0.16 * momentumBull +
            0.16 * abnormalVolume +
            0.16 * highVolatility +
            0.12 * bullStrength +
            0.10 * macdBull +
            0.06 * input.breakoutUpProbability +
            0.06 * max(0, input.marketFearGreed)

        // Контр
        scores[.stateControlledMode] =
            0.32 * governmentIntervention +
            0.16 * input.strategicSupportScore +
            0.14 * clamp(1 - abs(input.relativeVolume - 1.0) / 0.4, min: 0, max: 1) +
            0.12 * clamp(1 - abs(input.rsi - 50) / 20, min: 0, max: 1) +
            0.10 * clamp(1 - abs(input.macd) / 2.5, min: 0, max: 1) +
            0.08 * (input.hasGovernmentSupport ? 1.0 : 0.0) +
            0.08 * (input.isStrategicallyImportant ? 1.0 : 0.0)

        return scores.mapValues { clamp($0, min: 0, max: 1) }
    }

    //Strength

    private func normalizedStrength(bestScore: Double, allScores: [Double]) -> Double {
        let sorted = allScores.sorted(by: >)
        guard sorted.count >= 2 else { return clamp(bestScore, min: 0, max: 1) }

        let second = sorted[1]
        let gap = max(0, bestScore - second)

        return clamp(0.70 * bestScore + 0.30 * min(gap * 2.0, 1.0), min: 0, max: 1)
    }

    // Комментарий

    private func buildComment(
        for regime: MarketRegime,
        strength: Double,
        input: AssetInputData,
        scores: [MarketRegime: Double]
    ) -> String {
        var reasons: [String] = []

        if input.rsi >= 70 {
            reasons.append("RSI в перепроданной зоне")
        } else if input.rsi <= 30 {
            reasons.append("RSI в перекупленной зоне")
        } else if abs(input.rsi - 50) <= 5 {
            reasons.append("RSI в нейтральной зоне")
        }

        if input.macd > 0 {
            reasons.append("MACD положительный")
        } else if input.macd < 0 {
            reasons.append("MACD отрицательный")
        }

        if input.ema50 > input.ema200 {
            reasons.append("EMA50 выше EMA200")
        } else if input.ema50 < input.ema200 {
            reasons.append("EMA50 ниже EMA200")
        }

        if input.relativeVolume > 1.3 {
            reasons.append("Объем выше среднего")
        } else if input.relativeVolume < 0.8 {
            reasons.append("Объем ниже среднего")
        }

        if input.hasBreakoutUp {
            reasons.append("Возможен пробой вверх")
        }

        if input.hasBreakoutDown {
            reasons.append("Возможен пробой вниз")
        }

        if input.hasGovernmentSupport || input.isStrategicallyImportant {
            reasons.append("Стратегическое или государственное управление")
        }

        let strengthText: String
        switch strength {
        case 0..<0.35:
            strengthText = "Слабый сигнал"
        case 0.35..<0.65:
            strengthText = "Средний сигнал"
        default:
            strengthText = "Сильный сигнал"
        }

        let top3 = scores
            .sorted { $0.value > $1.value }
            .prefix(3)
            .map { "\($0.key.rawValue): \(String(format: "%.2f", $0.value))" }
            .joined(separator: ", ")

        return """
        Selected regime: \(regime.rawValue).
        \(strengthText)
        Main reasons: \(reasons.joined(separator: ", ")).
        Top scores: \(top3).
        """
    }

    // MARK: - Helpers

    private func clamp(_ value: Double, min minValue: Double, max maxValue: Double) -> Double {
        Swift.max(minValue, Swift.min(value, maxValue))
    }
}
