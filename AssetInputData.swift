import Foundation

struct AssetInputData {
    var ticker: String = ""
    var currentPrice: Double = 0
    var currentDate: Date = Date()

    //  Рыночные параметры
    var rsi: Double = 50
    var volatility: Double = 0
    var volume: Double = 0
    var averageVolume: Double = 0
    var macd: Double = 0
    var atr: Double = 0

    var momentum1D: Double = 0
    var momentum5D: Double = 0
    var momentum20D: Double = 0

    var ema50: Double = 0
    var ema200: Double = 0

    //  Структурные параметры
    var supportLevel: Double = 0
    var resistanceLevel: Double = 0

    var breakoutUpProbability: Double = 0
    var breakoutDownProbability: Double = 0

    // Факторы значимости и  поддержки
    var governmentImportance: Double = 0
    var scienceImportance: Double = 0
    var strategicSectorImportance: Double = 0

    var shareholderSupport: Double = 0
    var retailInvestorInterest: Double = 0
    var institutionalSupport: Double = 0

    // Ожидаемый диапазон: -1...1
    var newsPositivity: Double = 0
    var marketFearGreed: Double = 0

    // Поля силы
    var bullsStrength: Double = 0.5
    var bearsStrength: Double = 0.5

    // Сигналы на основе флагов
    var hasGovernmentSupport: Bool = false
    var isStrategicallyImportant: Bool = false
    var hasBreakoutUp: Bool = false
    var hasBreakoutDown: Bool = false
}

//Вычисляемая аналитика
extension AssetInputData {

    var relativeVolume: Double {
        guard averageVolume > 0 else { return 0 }
        return volume / averageVolume
    }

    var distanceToSupport: Double {
        currentPrice - supportLevel
    }

    var distanceToResistance: Double {
        resistanceLevel - currentPrice
    }

    var distanceToSupportPct: Double {
        guard currentPrice > 0 else { return 0 }
        return (currentPrice - supportLevel) / currentPrice
    }

    var distanceToResistancePct: Double {
        guard currentPrice > 0 else { return 0 }
        return (resistanceLevel - currentPrice) / currentPrice
    }

    var safeDistanceToSupport: Double {
        max(0, distanceToSupport)
    }

    var safeDistanceToResistance: Double {
        max(0, distanceToResistance)
    }

    var overboughtScore: Double {
        max(0, (rsi - 70) / 30)
    }

    var oversoldScore: Double {
        max(0, (30 - rsi) / 30)
    }

    var trendDirection: String {
        if ema50 > ema200 { return "Бычий тренд" }
        if ema50 < ema200 { return "Медвежий тренд" }
        return "Нейтральный тренд"
    }

    var normalizedTrendScore: Double {
        if ema50 == 0 && ema200 == 0 { return 0 }
        if ema50 > ema200 { return 1 }
        if ema50 < ema200 { return -1 }
        return 0
    }

    var normalizedTrendBiasUp: Double {
        Self.clamp((normalizedTrendScore + 1) / 2)
    }

    var trendStrengthScore: Double {
        let baseline = max(abs(currentPrice), max(abs(ema50), abs(ema200)))
        guard baseline > 0 else { return abs(normalizedTrendScore) }

        let divergence = abs(ema50 - ema200) / baseline
        return Self.clamp(divergence / 0.08)
    }

    var crowdForce: Double {
        let bullishPart =
            retailInvestorInterest * 0.4 +
            institutionalSupport * 0.4 +
            shareholderSupport * 0.2

        let sentimentBoost =
            newsPositivity * 0.5 +
            marketFearGreed * 0.5

        return bullishPart + sentimentBoost
    }

    var normalizedCrowdForce: Double {
        Self.clamp((crowdForce + 1) / 2)
    }

    var strategicSupportScore: Double {
        let importanceCore =
            governmentImportance * 0.35 +
            scienceImportance * 0.20 +
            strategicSectorImportance * 0.45

        let supportBoost = hasGovernmentSupport ? 0.15 : 0.0
        let strategicBoost = isStrategicallyImportant ? 0.15 : 0.0

        return Self.clamp(importanceCore + supportBoost + strategicBoost)
    }

    var breakoutRiskScore: Double {
        min(1.0, max(breakoutUpProbability, breakoutDownProbability))
    }

    // Вспомогательные значения для блока уровней

    var supportClosenessScore: Double {
        Self.closenessToLevel(
            distance: safeDistanceToSupport,
            atr: atr,
            price: currentPrice
        )
    }

    var resistanceClosenessScore: Double {
        Self.closenessToLevel(
            distance: safeDistanceToResistance,
            atr: atr,
            price: currentPrice
        )
    }

    var normalizedVolumePressure: Double {
        Self.normalizedRelativeVolume(relativeVolume)
    }

    var normalizedVolatilityPressure: Double {
        Self.normalizedATR(atr, price: currentPrice)
    }

    // Проверка данных

    var validationErrors: [String] {
        var errors: [String] = []

        if ticker.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Тикер не заполнен.")
        }

        if currentPrice <= 0 {
            errors.append("Текущая цена должна быть больше 0.")
        }

        if rsi < 0 || rsi > 100 {
            errors.append("RSI должен быть в диапазоне от 0 до 100.")
        }

        if volume < 0 {
            errors.append("Объём не может быть отрицательным.")
        }

        if averageVolume <= 0 {
            errors.append("Средний объём должен быть больше 0.")
        }

        if volatility < 0 {
            errors.append("Волатильность не может быть отрицательной.")
        }

        if atr < 0 {
            errors.append("ATR не может быть отрицательным.")
        }

        if supportLevel < 0 || resistanceLevel < 0 {
            errors.append("Уровни поддержки и сопротивления не могут быть отрицательными.")
        }

        if supportLevel > 0, resistanceLevel > 0, supportLevel >= resistanceLevel {
            errors.append("Уровень поддержки должен быть ниже уровня сопротивления.")
        }

        if !(0...1).contains(breakoutUpProbability) {
            errors.append("Вероятность пробоя вверх должна быть в диапазоне от 0 до 1.")
        }

        if !(0...1).contains(breakoutDownProbability) {
            errors.append("Вероятность пробоя вниз должна быть в диапазоне от 0 до 1.")
        }

        if !(0...1).contains(governmentImportance) {
            errors.append("Государственная значимость должна быть в диапазоне от 0 до 1.")
        }

        if !(0...1).contains(scienceImportance) {
            errors.append("Научная значимость должна быть в диапазоне от 0 до 1.")
        }

        if !(0...1).contains(strategicSectorImportance) {
            errors.append("Стратегическая значимость сектора должна быть в диапазоне от 0 до 1.")
        }

        if !(0...1).contains(shareholderSupport) {
            errors.append("Поддержка акционеров должна быть в диапазоне от 0 до 1.")
        }

        if !(0...1).contains(retailInvestorInterest) {
            errors.append("Интерес розничных инвесторов должен быть в диапазоне от 0 до 1.")
        }

        if !(0...1).contains(institutionalSupport) {
            errors.append("Поддержка институционалов должна быть в диапазоне от 0 до 1.")
        }

        if !(0...1).contains(bullsStrength) {
            errors.append("Бычья сила должна быть в диапазоне от 0 до 1.")
        }

        if !(0...1).contains(bearsStrength) {
            errors.append("Медвежья сила должна быть в диапазоне от 0 до 1.")
        }

        if !(-1...1).contains(newsPositivity) {
            errors.append("Позитив новостного фона должен быть в диапазоне от -1 до 1.")
        }

        if !(-1...1).contains(marketFearGreed) {
            errors.append("Индекс страха и жадности должен быть в диапазоне от -1 до 1.")
        }

        return errors
    }

    var isValid: Bool {
        validationErrors.isEmpty
    }
}

// статические математические помощники
extension AssetInputData {

    static func clamp(_ value: Double, min minValue: Double = 0, max maxValue: Double = 1) -> Double {
        if value < minValue { return minValue }
        if value > maxValue { return maxValue }
        return value
    }

    static func normalizeMinusOneToOne(_ value: Double) -> Double {
        clamp((value + 1) / 2)
    }

    static func closenessToLevel(distance: Double, atr: Double, price: Double) -> Double {
        let safeATR = atr > 0 ? atr : max(price * 0.02, 0.0001)
        let normalizedDistance = distance / safeATR

        if normalizedDistance <= 0.25 { return 1.0 }
        if normalizedDistance <= 0.50 { return 0.9 }
        if normalizedDistance <= 0.75 { return 0.75 }
        if normalizedDistance <= 1.00 { return 0.6 }
        if normalizedDistance <= 1.50 { return 0.4 }
        if normalizedDistance <= 2.00 { return 0.2 }
        return 0.05
    }

    static func normalizedRelativeVolume(_ relativeVolume: Double) -> Double {
        if relativeVolume <= 0.8 { return 0.15 }
        if relativeVolume <= 1.0 { return 0.30 }
        if relativeVolume <= 1.2 { return 0.50 }
        if relativeVolume <= 1.5 { return 0.70 }
        if relativeVolume <= 2.0 { return 0.88 }
        return 1.0
    }

    static func normalizedATR(_ atr: Double, price: Double) -> Double {
        guard price > 0 else { return 0 }
        let ratio = atr / price

        if ratio <= 0.01 { return 0.15 }
        if ratio <= 0.02 { return 0.30 }
        if ratio <= 0.03 { return 0.50 }
        if ratio <= 0.05 { return 0.72 }
        if ratio <= 0.08 { return 0.88 }
        return 1.0
    }
}
