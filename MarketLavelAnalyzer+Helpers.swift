//
//  MarketLavelAnalyzer+Helpers.swift
//  Stocks+Physics
//
// 
//

import Foundation

extension MarketLevelAnalyzer {

    static func clamp01(_ value: Double) -> Double {
        AssetInputData.clamp(value)
    }

    static func closenessToLevel(distance: Double, atr: Double, price: Double) -> Double {
        AssetInputData.closenessToLevel(distance: distance, atr: atr, price: price)
    }

    static func normalizedRelativeVolume(_ relativeVolume: Double) -> Double {
        AssetInputData.normalizedRelativeVolume(relativeVolume)
    }

    static func normalizedATR(_ atr: Double, price: Double) -> Double {
        AssetInputData.normalizedATR(atr, price: price)
    }

    static func trendBiasUp(_ normalizedTrendScore: Double) -> Double {
        clamp01((normalizedTrendScore + 1.0) / 2.0)
    }

    static func calculateSupportDefenseScore(
        supportCloseness: Double,
        bullsStrength: Double,
        bearsStrength: Double,
        volumePressure: Double,
        govSupport: Double,
        trendBias: Double,
        crowd: Double
    ) -> Double {
        let crowdSupport = clamp01((crowd + 1.0) / 2.0)

        return clamp01(
            0.24 * supportCloseness +
            0.18 * clamp01(bullsStrength) +
            0.12 * (1.0 - clamp01(bearsStrength)) +
            0.14 * volumePressure +
            0.16 * govSupport +
            0.10 * trendBias +
            0.06 * crowdSupport
        )
    }

    static func calculateResistanceDefenseScore(
        resistanceCloseness: Double,
        bullsStrength: Double,
        bearsStrength: Double,
        volumePressure: Double,
        govSupport: Double,
        trendBias: Double,
        crowd: Double
    ) -> Double {
        let crowdSupport = clamp01((crowd + 1.0) / 2.0)

        return clamp01(
            0.24 * resistanceCloseness +
            0.18 * clamp01(bearsStrength) +
            0.12 * (1.0 - clamp01(bullsStrength)) +
            0.14 * volumePressure +
            0.10 * (1.0 - trendBias) +
            0.10 * (1.0 - crowdSupport) +
            0.12 * (1.0 - govSupport)
        )
    }

    static func calculateBreakoutRiskDown(
        supportCloseness: Double,
        supportDefenseScore: Double,
        bearsStrength: Double,
        volumePressure: Double,
        volatilityPressure: Double,
        rawBreakoutDownProbability: Double,
        hasBreakoutDown: Bool,
        govSupport: Double
    ) -> Double {
        clamp01(
            0.18 * supportCloseness +
            0.20 * (1.0 - supportDefenseScore) +
            0.14 * clamp01(bearsStrength) +
            0.14 * volumePressure +
            0.12 * volatilityPressure +
            0.14 * clamp01(rawBreakoutDownProbability) +
            0.08 * (hasBreakoutDown ? 1.0 : 0.0) -
            0.10 * govSupport
        )
    }

    static func calculateBreakoutRiskUp(
        resistanceCloseness: Double,
        resistanceDefenseScore: Double,
        bullsStrength: Double,
        volumePressure: Double,
        volatilityPressure: Double,
        rawBreakoutUpProbability: Double,
        hasBreakoutUp: Bool,
        govSupport: Double,
        trendBias: Double
    ) -> Double {
        clamp01(
            0.18 * resistanceCloseness +
            0.18 * (1.0 - resistanceDefenseScore) +
            0.16 * clamp01(bullsStrength) +
            0.14 * volumePressure +
            0.10 * volatilityPressure +
            0.14 * clamp01(rawBreakoutUpProbability) +
            0.08 * (hasBreakoutUp ? 1.0 : 0.0) +
            0.08 * trendBias -
            0.06 * govSupport
        )
    }

    static func detectExpectedReaction(
        data: AssetInputData,
        supportCloseness: Double,
        resistanceCloseness: Double,
        supportDefenseScore: Double,
        resistanceDefenseScore: Double,
        breakoutRiskUp: Double,
        breakoutRiskDown: Double,
        volumePressure: Double,
        govSupport: Double
    ) -> ExpectedLevelReaction {

        if govSupport > 0.75 && supportCloseness > 0.75 && breakoutRiskDown < 0.45 {
            return .stateSupportedStabilization
        }

        if supportCloseness > 0.75 {
            if breakoutRiskDown > 0.80 && volumePressure > 0.60 {
                return .sharpBreakdownWithAcceleration
            }
            if breakoutRiskDown > 0.62 {
                return .supportBreakdown
            }
            if supportDefenseScore > 0.72 {
                return .strongBounceFromSupport
            }
            return .weakBounceFromSupport
        }

        if resistanceCloseness > 0.75 {
            if breakoutRiskUp > 0.82 && volumePressure > 0.60 {
                return .impulsiveBreakoutUp
            }
            if breakoutRiskUp > 0.64 {
                return .resistanceBreakout
            }
            if resistanceDefenseScore > 0.70 {
                return .rejectionFromResistance
            }
            return .weakRejectionFromResistance
        }

        return .neutralRangeBehavior
    }

    static func buildExplanation(
        data: AssetInputData,
        supportDefenseScore: Double,
        resistanceDefenseScore: Double,
        breakoutRiskUp: Double,
        breakoutRiskDown: Double,
        reaction: ExpectedLevelReaction
    ) -> String {
        """
        Support defense: \(String(format: "%.2f", supportDefenseScore)).
        Resistance defense: \(String(format: "%.2f", resistanceDefenseScore)).
        Breakout up risk: \(String(format: "%.2f", breakoutRiskUp)).
        Breakout down risk: \(String(format: "%.2f", breakoutRiskDown)).
        Expected reaction: \(reaction.rawValue).
        """
    }
}
