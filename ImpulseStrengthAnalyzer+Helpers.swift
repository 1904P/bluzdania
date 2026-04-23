//
//  ImpulseStrengthAnalyzer+Helpers.swift
//  Stocks+Physics
//
//
import Foundation

extension ImpulseStrengthAnalyzer {

    struct RSIZoneScore {
        let bullish: Double
        let bearish: Double
    }

    struct MomentumComposite {
        let bullish: Double
        let bearish: Double
    }

    func evaluateRSIZone(_ rsi: Double) -> RSIZoneScore {
        switch rsi {
        case ..<30:
            return RSIZoneScore(bullish: 0.85, bearish: 0.15)
        case 30..<45:
            return RSIZoneScore(bullish: 0.65, bearish: 0.35)
        case 45..<55:
            return RSIZoneScore(bullish: 0.50, bearish: 0.50)
        case 55..<70:
            return RSIZoneScore(bullish: 0.72, bearish: 0.28)
        default:
            return RSIZoneScore(bullish: 0.35, bearish: 0.70)
        }
    }

    func evaluateMomentumComposite(m1: Double, m5: Double, m20: Double) -> MomentumComposite {
        let n1 = normalizeMomentum(m1, scale: 3)
        let n5 = normalizeMomentum(m5, scale: 8)
        let n20 = normalizeMomentum(m20, scale: 15)

        let bullish = clamp01(
            0.45 * n1 +
            0.35 * n5 +
            0.20 * n20
        )

        let bearish = clamp01(
            0.45 * (1.0 - n1) +
            0.35 * (1.0 - n5) +
            0.20 * (1.0 - n20)
        )

        return MomentumComposite(bullish: bullish, bearish: bearish)
    }

    func normalizeMomentum(_ value: Double, scale: Double) -> Double {
        guard scale > 0 else { return 0.5 }
        let x = value / scale
        return sigmoid(x)
    }

    func normalizeMACD(_ macd: Double) -> Double {
        sigmoid(macd / 2.0)
    }

    func normalizeVolume(volume: Double, averageVolume: Double) -> Double {
        guard averageVolume > 0 else { return 0.5 }
        let ratio = volume / averageVolume

        switch ratio {
        case ..<0.7: return 0.20
        case 0.7..<0.95: return 0.40
        case 0.95..<1.15: return 0.55
        case 1.15..<1.5: return 0.72
        default: return 0.88
        }
    }

    func normalizeATR(_ atr: Double, price: Double) -> Double {
        guard price > 0 else { return 0.5 }
        let relativeATR = atr / price

        switch relativeATR {
        case ..<0.005: return 0.25
        case 0.005..<0.015: return 0.50
        case 0.015..<0.03: return 0.72
        default: return 0.90
        }
    }

    func proximityScore(distancePercent: Double) -> Double {
        let d = max(0, distancePercent)

        switch d {
        case ..<1: return 0.95
        case 1..<2: return 0.80
        case 2..<4: return 0.60
        case 4..<7: return 0.35
        default: return 0.15
        }
    }

    func calculateTrendBias(
        currentPrice: Double,
        ema50: Double,
        ema200: Double,
        trendStrength: Double
    ) -> Double {
        var score = 0.5

        if currentPrice > ema50 { score += 0.15 }
        if currentPrice > ema200 { score += 0.15 }
        if ema50 > ema200 { score += 0.15 }

        score += 0.15 * trendStrength
        return clamp01(score)
    }

    func calculateFalseBreakoutRiskUp(
        breakoutUpProbability: Double,
        volumeScore: Double,
        bullsStrength: Double,
        resistanceProximity: Double,
        rsi: Double,
        atrScore: Double
    ) -> Double {
        var risk = 0.0

        risk += 0.25 * (1.0 - clamp01(breakoutUpProbability))
        risk += 0.20 * (1.0 - volumeScore)
        risk += 0.15 * (1.0 - bullsStrength)
        risk += 0.15 * resistanceProximity
        risk += 0.15 * (rsi > 75 ? 1.0 : 0.3)
        risk += 0.10 * (atrScore > 0.85 ? 0.8 : 0.3)

        return clamp01(risk)
    }

    func calculateFalseBreakoutRiskDown(
        breakoutDownProbability: Double,
        volumeScore: Double,
        bearsStrength: Double,
        supportProximity: Double,
        rsi: Double,
        atrScore: Double
    ) -> Double {
        var risk = 0.0

        risk += 0.25 * (1.0 - clamp01(breakoutDownProbability))
        risk += 0.20 * (1.0 - volumeScore)
        risk += 0.15 * (1.0 - bearsStrength)
        risk += 0.15 * supportProximity
        risk += 0.15 * (rsi < 25 ? 1.0 : 0.3)
        risk += 0.10 * (atrScore > 0.85 ? 0.8 : 0.3)

        return clamp01(risk)
    }

    func calculateExhaustionProbability(
        rsi: Double,
        momentum1D: Double,
        momentum5D: Double,
        momentum20D: Double,
        volumeScore: Double,
        atrScore: Double,
        bullsStrength: Double,
        bearsStrength: Double,
        resistanceProximity: Double,
        supportProximity: Double
    ) -> Double {
        var exhaustion = 0.0

        let momentumDivergenceUp =
            (momentum20D > momentum5D && momentum5D > momentum1D && momentum20D > 0)

        let momentumDivergenceDown =
            (momentum20D < momentum5D && momentum5D < momentum1D && momentum20D < 0)

        if rsi > 75 || rsi < 25 { exhaustion += 0.22 }
        if momentumDivergenceUp || momentumDivergenceDown { exhaustion += 0.22 }
        if atrScore > 0.85 { exhaustion += 0.15 }
        if volumeScore < 0.45 { exhaustion += 0.14 }

        exhaustion += 0.12 * max(bullsStrength, bearsStrength)
        exhaustion += 0.15 * max(resistanceProximity, supportProximity)

        return clamp01(exhaustion)
    }

    func calculateReversalProbability(
        bullishImpulseScore: Double,
        bearishImpulseScore: Double,
        exhaustionProbability: Double,
        resistanceProximity: Double,
        supportProximity: Double,
        falseBreakoutRiskUp: Double,
        falseBreakoutRiskDown: Double,
        rsi: Double,
        crowdPressure: Double
    ) -> Double {
        var reversal = 0.0

        let directionConflict =
            abs(bullishImpulseScore - bearishImpulseScore) < 0.15 ? 0.8 : 0.25

        reversal += 0.22 * directionConflict
        reversal += 0.25 * exhaustionProbability
        reversal += 0.12 * max(resistanceProximity, supportProximity)
        reversal += 0.14 * max(falseBreakoutRiskUp, falseBreakoutRiskDown)

        if rsi > 78 || rsi < 22 {
            reversal += 0.15
        }

        if abs(crowdPressure) > 0.85 {
            reversal += 0.12
        }

        return clamp01(reversal)
    }

    func calculateTrendAcceleration(
        momentum1D: Double,
        momentum5D: Double,
        momentum20D: Double,
        macd: Double,
        volumeScore: Double
    ) -> Double {
        let short = tanh(momentum1D / 3)
        let mid = tanh(momentum5D / 8)
        let long = tanh(momentum20D / 15)
        let macdPart = tanh(macd / 2)

        let accel = (
            0.35 * short +
            0.25 * (short - mid) +
            0.20 * (mid - long) +
            0.20 * macdPart
        ) * (0.7 + 0.3 * volumeScore)

        return clampMinusOneToOne(accel)
    }

    func normalizeMinusOneToOneToZeroOne(_ value: Double) -> Double {
        clamp01((value + 1.0) / 2.0)
    }

    func sigmoid(_ x: Double) -> Double {
        1.0 / (1.0 + exp(-x))
    }

    func clamp01(_ value: Double) -> Double {
        min(max(value, 0.0), 1.0)
    }

    func clampMinusOneToOne(_ value: Double) -> Double {
        min(max(value, -1.0), 1.0)
    }
}
