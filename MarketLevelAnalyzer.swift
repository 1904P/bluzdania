//
//  MarketLevelAnalyzer.swift
//  Stocks+Physics
//
//  
//
import Foundation

enum ExpectedLevelReaction: String {
    case strongBounceFromSupport
    case weakBounceFromSupport
    case supportBreakdown
    case sharpBreakdownWithAcceleration
    case rejectionFromResistance
    case weakRejectionFromResistance
    case resistanceBreakout
    case impulsiveBreakoutUp
    case neutralRangeBehavior
    case stateSupportedStabilization
}

struct LevelAnalysisResult {
    let supportDefenseScore: Double
    let resistanceDefenseScore: Double
    let breakoutRiskUp: Double
    let breakoutRiskDown: Double
    let expectedReactionNearLevel: ExpectedLevelReaction
    let explanation: String
}

enum MarketLevelAnalyzer {

    static func analyze(data: AssetInputData) -> LevelAnalysisResult {
        let supportCloseness = closenessToLevel(
            distance: max(0, data.distanceToSupport),
            atr: data.atr,
            price: data.currentPrice
        )

        let resistanceCloseness = closenessToLevel(
            distance: max(0, data.distanceToResistance),
            atr: data.atr,
            price: data.currentPrice
        )

        let volumePressure = normalizedRelativeVolume(data.relativeVolume)
        let volatilityPressure = normalizedATR(data.atr, price: data.currentPrice)
        let govSupport = data.strategicSupportScore
        let trendBias = trendBiasUp(data.normalizedTrendScore)
        let crowd = data.crowdForce

        let supportDefenseScore = calculateSupportDefenseScore(
            supportCloseness: supportCloseness,
            bullsStrength: data.bullsStrength,
            bearsStrength: data.bearsStrength,
            volumePressure: volumePressure,
            govSupport: govSupport,
            trendBias: trendBias,
            crowd: crowd
        )

        let resistanceDefenseScore = calculateResistanceDefenseScore(
            resistanceCloseness: resistanceCloseness,
            bullsStrength: data.bullsStrength,
            bearsStrength: data.bearsStrength,
            volumePressure: volumePressure,
            govSupport: govSupport,
            trendBias: trendBias,
            crowd: crowd
        )

        let breakoutRiskDown = calculateBreakoutRiskDown(
            supportCloseness: supportCloseness,
            supportDefenseScore: supportDefenseScore,
            bearsStrength: data.bearsStrength,
            volumePressure: volumePressure,
            volatilityPressure: volatilityPressure,
            rawBreakoutDownProbability: data.breakoutDownProbability,
            hasBreakoutDown: data.hasBreakoutDown,
            govSupport: govSupport
        )

        let breakoutRiskUp = calculateBreakoutRiskUp(
            resistanceCloseness: resistanceCloseness,
            resistanceDefenseScore: resistanceDefenseScore,
            bullsStrength: data.bullsStrength,
            volumePressure: volumePressure,
            volatilityPressure: volatilityPressure,
            rawBreakoutUpProbability: data.breakoutUpProbability,
            hasBreakoutUp: data.hasBreakoutUp,
            govSupport: govSupport,
            trendBias: trendBias
        )

        let reaction = detectExpectedReaction(
            data: data,
            supportCloseness: supportCloseness,
            resistanceCloseness: resistanceCloseness,
            supportDefenseScore: supportDefenseScore,
            resistanceDefenseScore: resistanceDefenseScore,
            breakoutRiskUp: breakoutRiskUp,
            breakoutRiskDown: breakoutRiskDown,
            volumePressure: volumePressure,
            govSupport: govSupport
        )

        let explanation = buildExplanation(
            data: data,
            supportDefenseScore: supportDefenseScore,
            resistanceDefenseScore: resistanceDefenseScore,
            breakoutRiskUp: breakoutRiskUp,
            breakoutRiskDown: breakoutRiskDown,
            reaction: reaction
        )

        return LevelAnalysisResult(
            supportDefenseScore: supportDefenseScore,
            resistanceDefenseScore: resistanceDefenseScore,
            breakoutRiskUp: breakoutRiskUp,
            breakoutRiskDown: breakoutRiskDown,
            expectedReactionNearLevel: reaction,
            explanation: explanation
        )
    }
}
