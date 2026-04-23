//
//  MarketRegime.swift
//  Stocks+Physics
//
// 
//

import Foundation

enum MarketRegime: String, CaseIterable, Codable {
    case strongBullTrend = "Сильный бычий тренд"
    case weakBullTrend = "Слабый бычий тренд"
    case sideways = "Боковик"
    case weakBearTrend = "Слабый медвежий тренд"
    case strongBearTrend = "Сильный медвежий тренд"
    case panicSelloff = "Панические продажи"
    case speculativePump = "Спекулятивное продвижение"
    case stateControlledMode = "Продуманное управление"
}

struct MarketRegimeResult {
    let regime: MarketRegime
    let strength: Double          // 0...1
    let comment: String
    let debugScores: [MarketRegime: Double]
}
