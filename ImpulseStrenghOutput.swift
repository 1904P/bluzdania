//
//  ImpulseStrenghOutput.swift
//  Stocks+Physics
//
//
import Foundation

struct ImpulseStrengthOutput {
    let continuationProbabilityUp: Double      // 0...1
    let continuationProbabilityDown: Double    // 0...1
    let reversalProbability: Double            // 0...1
    let exhaustionProbability: Double          // 0...1

    let bullishImpulseScore: Double            // 0...1
    let bearishImpulseScore: Double            // 0...1

    let falseBreakoutRiskUp: Double            // 0...1
    let falseBreakoutRiskDown: Double          // 0...1

    let trendAccelerationScore: Double         // -1...1
    let debugNotes: [String]
}

