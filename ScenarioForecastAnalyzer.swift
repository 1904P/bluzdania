//
//  ScenarioForecastAnalyzer.swift
//  Stocks+Physics
//
//  
//
import Foundation

final class ScenarioForecastAnalyzer {

    func analyze(
        input: AssetInputData,
        regime: MarketRegimeResult,
        impulse: ImpulseStrengthOutput,
        level: LevelAnalysisResult
    ) -> ScenarioForecastOutput {

        let trendUp = input.normalizedTrendBiasUp
        let crowdUp = input.normalizedCrowdForce

        let bullRaw =
            0.22 * trendUp +
            0.20 * crowdUp +
            0.22 * impulse.continuationProbabilityUp +
            0.16 * regime.strength +
            0.10 * (1.0 - level.breakoutRiskDown) +
            0.10 * input.strategicSupportScore

        let bearRaw =
            0.22 * (1.0 - trendUp) +
            0.20 * (1.0 - crowdUp) +
            0.22 * impulse.continuationProbabilityDown +
            0.16 * impulse.reversalProbability +
            0.10 * level.breakoutRiskDown +
            0.10 * max(0, -input.marketFearGreed)

        let baseRaw = max(0.10, 1.0 - abs(bullRaw - bearRaw))

        let total = bullRaw + bearRaw + baseRaw

        let bullProbability = bullRaw / total
        let bearProbability = bearRaw / total
        let baseProbability = baseRaw / total

        let dailyVol = max(0.003, min(0.06, input.volatility > 0 ? input.volatility : input.atr / max(input.currentPrice, 0.0001)))

        let bullishDrift = 0.004 + 0.015 * bullProbability
        let baseDrift = 0.001 + 0.006 * (bullProbability - bearProbability)
        let bearishDrift = -0.004 - 0.015 * bearProbability

        var points: [ForecastPoint] = []

        for day in 0...30 {
            let date = Calendar.current.date(byAdding: .day, value: day, to: input.currentDate) ?? input.currentDate

            let bullPrice = input.currentPrice * pow(1 + bullishDrift + dailyVol * 0.20, Double(day))
            let basePrice = input.currentPrice * pow(1 + baseDrift, Double(day))
            let bearPrice = input.currentPrice * pow(max(0.90, 1 + bearishDrift - dailyVol * 0.15), Double(day))

            points.append(
                ForecastPoint(
                    day: day,
                    date: date,
                    bullPrice: bullPrice,
                    basePrice: basePrice,
                    bearPrice: bearPrice
                )
            )
        }

        let last = points.last ?? ForecastPoint(
            day: 30,
            date: input.currentDate,
            bullPrice: input.currentPrice,
            basePrice: input.currentPrice,
            bearPrice: input.currentPrice
        )

        let expectedPrice30D =
            bullProbability * last.bullPrice +
            baseProbability * last.basePrice +
            bearProbability * last.bearPrice

        let expectedReturn30D =
            input.currentPrice > 0 ? (expectedPrice30D - input.currentPrice) / input.currentPrice : 0

        let confidence = AssetInputData.clamp(
            0.35 * regime.strength +
            0.25 * max(impulse.continuationProbabilityUp, impulse.continuationProbabilityDown) +
            0.20 * (1.0 - impulse.reversalProbability) +
            0.20 * (1.0 - max(level.breakoutRiskUp, level.breakoutRiskDown))
        )

        let summary = """
        Bull: \(String(format: "%.1f%%", bullProbability * 100))
        Base: \(String(format: "%.1f%%", baseProbability * 100))
        Bear: \(String(format: "%.1f%%", bearProbability * 100))
        Ожидаемая 30D цена: \(String(format: "%.2f", expectedPrice30D))
        """

        return ScenarioForecastOutput(
            bullProbability: bullProbability,
            baseProbability: baseProbability,
            bearProbability: bearProbability,
            expectedPrice30D: expectedPrice30D,
            expectedReturn30D: expectedReturn30D,
            confidence: confidence,
            points: points,
            summary: summary
        )
    }
}
