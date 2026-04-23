//
//  StrategyDecisionOutput.swift
//  Stocks+Physics
//
//  
//
import Foundation

enum StrategyAction: String {
    case strongBuy = "Strong Buy"
    case buy = "Buy"
    case hold = "Hold"
    case watch = "Watch"
    case reduce = "Reduce"
    case sell = "Sell"
    case avoid = "Avoid"
}

struct StrategyDecisionOutput {
    let action: StrategyAction
    let confidence: Double
    let positionSizeFraction: Double

    let stopLossPrice: Double
    let takeProfitPrice: Double
    let riskRewardRatio: Double

    let rationale: String
}
