//
//  mpulseStrengthAnalyzer.swift
//  Stocks+Physics
//
//  
//
import Foundation

final class ImpulseStrengthAnalyzer {

    func analyze(input: AssetInputData) -> ImpulseStrengthOutput {
        let rsiZone = evaluateRSIZone(input.rsi)
        let momentum = evaluateMomentumComposite(
            m1: input.momentum1D,
            m5: input.momentum5D,
            m20: input.momentum20D
        )

        let macdScore = normalizeMACD(input.macd)
        let volumeScore = normalizeVolume(volume: input.volume, averageVolume: input.averageVolume)
        let atrScore = normalizeATR(input.atr, price: input.currentPrice)

        let supportProximity = proximityScore(
            distancePercent: max(0, input.distanceToSupportPct) * 100
        )
        let resistanceProximity = proximityScore(
            distancePercent: max(0, input.distanceToResistancePct) * 100
        )

        let crowdBullish = input.normalizedCrowdForce
        let crowdBearish = 1.0 - crowdBullish

        let bulls = clamp01(input.bullsStrength)
        let bears = clamp01(input.bearsStrength)

        let trendBias = calculateTrendBias(
            currentPrice: input.currentPrice,
            ema50: input.ema50,
            ema200: input.ema200,
            trendStrength: input.trendStrengthScore
        )

        let bullishImpulseScore =
            0.17 * rsiZone.bullish +
            0.18 * momentum.bullish +
            0.16 * macdScore +
            0.12 * volumeScore +
            0.09 * atrScore +
            0.10 * crowdBullish +
            0.10 * bulls +
            0.08 * trendBias

        let bearishImpulseScore =
            0.17 * rsiZone.bearish +
            0.18 * momentum.bearish +
            0.16 * (1.0 - macdScore) +
            0.12 * volumeScore +
            0.09 * atrScore +
            0.10 * crowdBearish +
            0.10 * bears +
            0.08 * (1.0 - trendBias)

        let falseBreakoutRiskUp = calculateFalseBreakoutRiskUp(
            breakoutUpProbability: input.breakoutUpProbability,
            volumeScore: volumeScore,
            bullsStrength: bulls,
            resistanceProximity: resistanceProximity,
            rsi: input.rsi,
            atrScore: atrScore
        )

        let falseBreakoutRiskDown = calculateFalseBreakoutRiskDown(
            breakoutDownProbability: input.breakoutDownProbability,
            volumeScore: volumeScore,
            bearsStrength: bears,
            supportProximity: supportProximity,
            rsi: input.rsi,
            atrScore: atrScore
        )

        let continuationProbabilityUp = clamp01(
            0.40 * bullishImpulseScore +
            0.18 * clamp01(input.breakoutUpProbability) +
            0.08 * (1.0 - resistanceProximity) +
            0.08 * supportProximity +
            0.08 * trendBias +
            0.18 * (1.0 - falseBreakoutRiskUp)
        )

        let continuationProbabilityDown = clamp01(
            0.40 * bearishImpulseScore +
            0.18 * clamp01(input.breakoutDownProbability) +
            0.08 * (1.0 - supportProximity) +
            0.08 * resistanceProximity +
            0.08 * (1.0 - trendBias) +
            0.18 * (1.0 - falseBreakoutRiskDown)
        )

        let exhaustionProbability = calculateExhaustionProbability(
            rsi: input.rsi,
            momentum1D: input.momentum1D,
            momentum5D: input.momentum5D,
            momentum20D: input.momentum20D,
            volumeScore: volumeScore,
            atrScore: atrScore,
            bullsStrength: bulls,
            bearsStrength: bears,
            resistanceProximity: resistanceProximity,
            supportProximity: supportProximity
        )

        let reversalProbability = calculateReversalProbability(
            bullishImpulseScore: bullishImpulseScore,
            bearishImpulseScore: bearishImpulseScore,
            exhaustionProbability: exhaustionProbability,
            resistanceProximity: resistanceProximity,
            supportProximity: supportProximity,
            falseBreakoutRiskUp: falseBreakoutRiskUp,
            falseBreakoutRiskDown: falseBreakoutRiskDown,
            rsi: input.rsi,
            crowdPressure: input.crowdForce
        )

        let trendAccelerationScore = calculateTrendAcceleration(
            momentum1D: input.momentum1D,
            momentum5D: input.momentum5D,
            momentum20D: input.momentum20D,
            macd: input.macd,
            volumeScore: volumeScore
        )

        var notes: [String] = []
        if input.rsi > 70 { notes.append("RSI в перекупленной зоне ") }
        if input.rsi < 30 { notes.append("RSI в перепроданной зоне") }
        if volumeScore > 0.75 { notes.append("Объем подтверждает движение") }
        if falseBreakoutRiskUp > 0.65 { notes.append("Высокий риск ложного пробоя вверх") }
        if falseBreakoutRiskDown > 0.65 { notes.append("Высокий риск ложного пробоя вниз") }
        if exhaustionProbability > 0.65 { notes.append("Импульс на исходе") }
        if abs(trendAccelerationScore) > 0.6 { notes.append("Тренд разгоняется") }

        return ImpulseStrengthOutput(
            continuationProbabilityUp: continuationProbabilityUp,
            continuationProbabilityDown: continuationProbabilityDown,
            reversalProbability: reversalProbability,
            exhaustionProbability: exhaustionProbability,
            bullishImpulseScore: clamp01(bullishImpulseScore),
            bearishImpulseScore: clamp01(bearishImpulseScore),
            falseBreakoutRiskUp: falseBreakoutRiskUp,
            falseBreakoutRiskDown: falseBreakoutRiskDown,
            trendAccelerationScore: trendAccelerationScore,
            debugNotes: notes
        )
    }
}
