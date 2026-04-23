//
//  StrategyDecisionEngine.swift
//  Stocks+Physics
//
// 
//

import Foundation

final class StrategyDecisionEngine {

    func analyze(
        input: AssetInputData,
        regime: MarketRegimeResult,
        impulse: ImpulseStrengthOutput,
        level: LevelAnalysisResult,
        forecast: ScenarioForecastOutput
    ) -> StrategyDecisionOutput {

        let buyScore =
            0.20 * forecast.bullProbability +
            0.20 * impulse.continuationProbabilityUp +
            0.15 * (1.0 - impulse.reversalProbability) +
            0.10 * level.supportDefenseScore +
            0.10 * (1.0 - level.breakoutRiskDown) +
            0.10 * input.normalizedTrendBiasUp +
            0.15 * regime.strength

        let sellScore =
            0.20 * forecast.bearProbability +
            0.20 * impulse.continuationProbabilityDown +
            0.15 * impulse.reversalProbability +
            0.10 * level.breakoutRiskDown +
            0.10 * level.resistanceDefenseScore +
            0.10 * (1.0 - input.normalizedTrendBiasUp) +
            0.15 * max(0, -input.marketFearGreed)

        let netScore = buyScore - sellScore

        let action: StrategyAction
        switch netScore {
        case 0.35...:
            action = .strongBuy
        case 0.18..<0.35:
            action = .buy
        case 0.05..<0.18:
            action = .hold
        case -0.05..<0.05:
            action = .watch
        case -0.18..<(-0.05):
            action = .reduce
        case -0.35..<(-0.18):
            action = .sell
        default:
            action = .avoid
        }

        let confidence = AssetInputData.clamp(
            0.30 * forecast.confidence +
            0.25 * regime.strength +
            0.25 * max(impulse.continuationProbabilityUp, impulse.continuationProbabilityDown) +
            0.20 * abs(netScore)
        )

        let atrBase = max(input.atr, input.currentPrice * 0.02)

        let stopLossPrice: Double
        let takeProfitPrice: Double

        switch action {
        case .strongBuy, .buy, .hold:
            stopLossPrice = max(0.01, input.currentPrice - 1.5 * atrBase)
            takeProfitPrice = max(input.currentPrice + 2.5 * atrBase, forecast.expectedPrice30D)
        case .watch:
            stopLossPrice = max(0.01, input.currentPrice - 1.0 * atrBase)
            takeProfitPrice = input.currentPrice + 1.5 * atrBase
        case .reduce, .sell, .avoid:
            stopLossPrice = max(0.01, input.currentPrice - 0.8 * atrBase)
            takeProfitPrice = input.currentPrice + 0.8 * atrBase
        }

        let risk = max(0.0001, input.currentPrice - stopLossPrice)
        let reward = max(0.0001, takeProfitPrice - input.currentPrice)
        let rr = reward / risk

        let positionSizeFraction: Double
        switch action {
        case .strongBuy:
            positionSizeFraction = AssetInputData.clamp(0.30 * confidence, max: 0.25)
        case .buy:
            positionSizeFraction = AssetInputData.clamp(0.22 * confidence, max: 0.18)
        case .hold:
            positionSizeFraction = AssetInputData.clamp(0.12 * confidence, max: 0.10)
        case .watch:
            positionSizeFraction = 0.03
        case .reduce:
            positionSizeFraction = 0.01
        case .sell, .avoid:
            positionSizeFraction = 0.0
        }

        let rationale = """
        Покупка: \(String(format: "%.2f", buyScore))
        Продажа: \(String(format: "%.2f", sellScore))
        Net score: \(String(format: "%.2f", netScore))
        Прогноз: \(String(format: "%.2f", forecast.confidence))
        """

        return StrategyDecisionOutput(
            action: action,
            confidence: confidence,
            positionSizeFraction: positionSizeFraction,
            stopLossPrice: stopLossPrice,
            takeProfitPrice: takeProfitPrice,
            riskRewardRatio: rr,
            rationale: rationale
        )
    }
}
