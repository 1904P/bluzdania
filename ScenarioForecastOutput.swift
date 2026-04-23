//
//  ScenarioForecastOutput.swift
//  Stocks+Physics
//
//  
//

import Foundation

struct ForecastPoint: Identifiable {
    let id = UUID()
    let day: Int
    let date: Date
    let bullPrice: Double
    let basePrice: Double
    let bearPrice: Double
}

struct ScenarioForecastOutput {
    let bullProbability: Double
    let baseProbability: Double
    let bearProbability: Double

    let expectedPrice30D: Double
    let expectedReturn30D: Double
    let confidence: Double

    let points: [ForecastPoint]
    let summary: String
}
