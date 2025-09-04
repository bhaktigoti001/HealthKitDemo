//
//  HealthKitManager.swift
//  HealthApp
//
//  Created by DREAMWORLD on 29/08/25.
//

import SwiftUI
import Combine
import HealthKit

// MARK: - Mock HealthKit Manager
class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    
    private let healthStore = HKHealthStore()
    private var query: HKObserverQuery?
    
    @Published var stepCount: Double = 0
    @Published var heartRate: Double = 0
    @Published var activeEnergy: Double = 0
    @Published var sleepHours: Double = 0
    @Published var lastSyncDate: Date = Date()
    @Published var isSyncing: Bool = false
    @Published var devices: [HKDevice] = []
    @Published var hasPermissions: Bool = false
    @Published var weeklyProgress: WeeklyProgress = WeeklyProgress(days: [])
    @Published var latestHeartRate: Double? = nil

    private init() {
        requestAuthorization()
        setupBackgroundDelivery()
        startObservingHealthData()
//        fetchConnectedDevices()
        fetchDevices()
    }
    
    // MARK: - HealthKit Authorization
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device")
            return
        }
        
        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        ]
        
        let shareTypes: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        ]
        
        healthStore.requestAuthorization(toShare: shareTypes, read: readTypes) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.hasPermissions = success
                if success {
                    self?.fetchAllHealthData()
                }
            }
        }
    }
    
    // MARK: - Data Fetching
    func fetchAllHealthData() {
        fetchStepCount()
        fetchHeartRate()
        fetchActiveEnergy()
        fetchSleepData()
        DispatchQueue.main.async { [weak self] in
            self?.lastSyncDate = Date()
        }
    }
    
    private func fetchStepCount() {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, error in
            guard let self = self, let result = result, let sum = result.sumQuantity() else { return }
            
            DispatchQueue.main.async {
                self.stepCount = sum.doubleValue(for: HKUnit.count())
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchHeartRate() {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { [weak self] _, samples, error in
            guard let self = self, let mostRecentSample = samples?.first as? HKQuantitySample else { return }
            
            DispatchQueue.main.async {
                self.heartRate = mostRecentSample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchActiveEnergy() {
        guard let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: energyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, error in
            guard let self = self, let result = result, let sum = result.sumQuantity() else { return }
            
            DispatchQueue.main.async {
                self.activeEnergy = sum.doubleValue(for: HKUnit.kilocalorie())
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchSleepData() {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { [weak self] _, samples, error in
            guard let self = self, let samples = samples else { return }
            
            var totalSleep: TimeInterval = 0
            for sample in samples {
                if let categorySample = sample as? HKCategorySample {
                    if categorySample.value == HKCategoryValueSleepAnalysis.inBed.rawValue ||
                       categorySample.value == HKCategoryValueSleepAnalysis.asleep.rawValue {
                        totalSleep += sample.endDate.timeIntervalSince(sample.startDate)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.sleepHours = totalSleep / 3600 // Convert to hours
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Background Sync
    private func setupBackgroundDelivery() {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        
        query = HKObserverQuery(sampleType: stepType, predicate: nil) { [weak self] _, completionHandler, error in
            self?.fetchAllHealthData()
            completionHandler()
        }
        
        if let query = query {
            healthStore.execute(query)
            healthStore.enableBackgroundDelivery(for: stepType, frequency: .immediate) { success, error in
                if success {
                    print("Background delivery enabled")
                }
            }
        }
    }
    
    private func startObservingHealthData() {
        Timer.scheduledTimer(withTimeInterval: 900, repeats: true) { [weak self] _ in // 15 minutes
            self?.fetchAllHealthData()
        }
    }
    
    // MARK: - Device Management
    func fetchConnectedDevices() {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let query = HKSampleQuery(
            sampleType: stepType,
            predicate: nil,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: nil
        ) { [weak self] _, sources, error in
            guard let self = self, let sources = sources as? [HKQuantitySample] else { return }
            
            var devices: [HKDevice] = []
            for source in sources {
                if let device = source.device {
                    devices.append(device)
                }
            }
            
            let unique = Dictionary(grouping: devices, by: {
                "\($0.name ?? "")-\($0.model ?? "")-\($0.hardwareVersion ?? "")"
            }).compactMap { $0.value.first }

            DispatchQueue.main.async {
                self.devices = unique
            }
        }
        
        healthStore.execute(query)
    }
    
    func fetchDevices() {
        guard let sampleType = HKSampleType.quantityType(forIdentifier: .stepCount) else {
            return
        }
        
        let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        let predicate = HKQuery.predicateForSamples(withStart: lastMonth, end: Date(), options: [])
        
        let query = HKSampleQuery(sampleType: sampleType,
                                  predicate: predicate,
                                  limit: HKObjectQueryNoLimit,
                                  sortDescriptors: nil) { _, samples, _ in
            let devices = samples?
                .compactMap { $0.device }
                .reduce(into: [String: HKDevice]()) { dict, device in
                    dict[device.udiDeviceIdentifier ?? UUID().uuidString] = device
                }
                .map { $0.value } ?? []
            
            let unique = Dictionary(grouping: devices, by: {
                "\($0.name ?? "")-\($0.model ?? "")-\($0.hardwareVersion ?? "")"
            }).compactMap { $0.value.first }

            DispatchQueue.main.async {
                self.devices = unique
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Manual Step Entry
    func addManualSteps(_ steps: Double, completion: @escaping (Bool) -> Void) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(false)
            return
        }
        
        let stepQuantity = HKQuantity(unit: HKUnit.count(), doubleValue: steps)
        let stepSample = HKQuantitySample(type: stepType, quantity: stepQuantity, start: Date(), end: Date())
        
        healthStore.save(stepSample) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.stepCount += steps
                    
                    // Refresh weekly progress after adding manual step
                    self?.fetchWeeklySteps { updatedProgress in
                        self?.weeklyProgress = updatedProgress
                    }
                }
                completion(success)
            }
        }
    }
    
    // MARK: - Fetch Weekly Progress
    func fetchWeeklySteps(completion: @escaping (WeeklyProgress) -> Void) {
        let calendar = Calendar.current
        let now = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: now)) else { return }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
        let interval = DateComponents(day: 1)
        let query = HKStatisticsCollectionQuery(
            quantityType: HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: calendar.startOfDay(for: now),
            intervalComponents: interval
        )

        query.initialResultsHandler = { _, results, _ in
            var days: [DailyProgress] = []
            results?.enumerateStatistics(from: startDate, to: now) { statistics, _ in
                let steps = statistics.sumQuantity()?.doubleValue(for: .count()) ?? 0
                days.append(DailyProgress(date: statistics.startDate, steps: steps))
            }
            DispatchQueue.main.async {
                completion(WeeklyProgress(days: days.sorted { $0.date < $1.date }))
            }
        }

        healthStore.execute(query)
    }

}

// MARK: - Fetch Analytics Data
extension HealthKitManager {

    func fetchMetricData(metric: HealthMetric, range: TimeRange, completion: @escaping ([DailyProgress]) -> Void) {
        let calendar = Calendar.current
        let now = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -range.days + 1, to: calendar.startOfDay(for: now)) else {
            completion([])
            return
        }

        var quantityType: HKQuantityType?

        switch metric {
        case .steps:
            quantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)
        case .heartRate:
            quantityType = HKQuantityType.quantityType(forIdentifier: .heartRate)
        case .activeEnergy:
            quantityType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)
        case .sleep:
            // Sleep is HKCategoryType
            fetchSleepData(startDate: startDate, endDate: now, completion: completion)
            return
        }
        
        var statisticsOption: HKStatisticsOptions = []

        switch metric {
        case .heartRate:
            statisticsOption = .discreteAverage
        default:
            statisticsOption = .cumulativeSum
        }

        guard let type = quantityType else { completion([]); return }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
        let interval = DateComponents(day: 1)

        let query = HKStatisticsCollectionQuery(
            quantityType: type,
            quantitySamplePredicate: predicate,
            options: statisticsOption,
            anchorDate: calendar.startOfDay(for: now),
            intervalComponents: interval
        )

        query.initialResultsHandler = { _, results, _ in
            var dailyData: [DailyProgress] = []

            results?.enumerateStatistics(from: startDate, to: now) { stat, _ in
                let value: Double
                if metric == .heartRate {
                    // Average HR
                    value = stat.averageQuantity()?.doubleValue(for: HKUnit(from: "count/min")) ?? 0
                } else if metric == .activeEnergy {
                    value = stat.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0
                } else {
                    value = stat.sumQuantity()?.doubleValue(for: .count()) ?? 0
                }
                dailyData.append(DailyProgress(date: stat.startDate, steps: value))
            }

            DispatchQueue.main.async {
                completion(dailyData.sorted { $0.date < $1.date })
            }
        }

        healthStore.execute(query)
    }

    private func fetchSleepData(startDate: Date, endDate: Date, completion: @escaping ([DailyProgress]) -> Void) {
        let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
            var dailyData: [DailyProgress] = []

            let calendar = Calendar.current
            let grouped = Dictionary(grouping: samples as? [HKCategorySample] ?? [], by: { calendar.startOfDay(for: $0.startDate) })
            for (day, daySamples) in grouped {
                let totalSleep = daySamples.reduce(0) { $0 + $1.endDate.timeIntervalSince($1.startDate) / 3600 } // hours
                dailyData.append(DailyProgress(date: day, steps: totalSleep)) // use `steps` field to store hours for simplicity
            }

            DispatchQueue.main.async {
                completion(dailyData.sorted { $0.date < $1.date })
            }
        }

        healthStore.execute(query)
    }
}

// MARK: - Fetch Statistics Data
extension HealthKitManager {
    func fetchStatistics(for range: DateRange, completion: @escaping (UserStats) -> Void) {
        let calendar = Calendar.current
        let now = Date()
        let startDate: Date
        
        switch range {
        case .today:
            startDate = calendar.startOfDay(for: now)
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now)!
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now)!
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: now)!
        }
        
        var stats = UserStats()
        let group = DispatchGroup()
        
        // MARK: Steps
        group.enter()
        aggregateQuantity(type: .stepCount, start: startDate, end: now) { dailyValues in
            stats.stepsToday = dailyValues.reduce(0, +)
            stats.bestStepsDay = dailyValues.max() ?? 0
            stats.avgSteps = dailyValues.isEmpty ? 0 : dailyValues.reduce(0, +) / Double(dailyValues.count)
            group.leave()
        }
        
        // MARK: Active Energy
        group.enter()
        aggregateQuantity(type: .activeEnergyBurned, start: startDate, end: now) { dailyValues in
            stats.activeEnergyToday = dailyValues.reduce(0, +)
            stats.bestActiveEnergy = dailyValues.max() ?? 0
            group.leave()
        }
        
        // MARK: Heart Rate
        group.enter()
        fetchHeartRateStats(start: startDate, end: now) { resting, max in
            stats.restingHR = resting
            stats.maxHR = max
            group.leave()
        }
        
        // MARK: Sleep
        group.enter()
        fetchSleepStats(start: startDate, end: now) { avg, best in
            stats.avgSleep = avg
            stats.bestSleep = best
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion(stats)
        }
    }

    private func aggregateQuantity(type: HKQuantityTypeIdentifier, start: Date, end: Date, completion: @escaping ([Double]) -> Void) {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: type) else { return completion([]) }
        
        let interval: DateComponents
        if Calendar.current.isDate(start, equalTo: end, toGranularity: .day) {
            interval = DateComponents(day: 1)
        } else if Calendar.current.dateComponents([.day], from: start, to: end).day! <= 7 {
            interval = DateComponents(day: 1)
        } else {
            interval = DateComponents(day: 1)
        }
        
        let query = HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: HKQuery.predicateForSamples(withStart: start, end: end),
            options: .cumulativeSum,
            anchorDate: Calendar.current.startOfDay(for: start),
            intervalComponents: interval
        )
        
        query.initialResultsHandler = { _, results, _ in
            var dailyValues: [Double] = []
            results?.enumerateStatistics(from: start, to: end) { stat, _ in
                let value = stat.sumQuantity()?.doubleValue(for: self.unit(for: type)) ?? 0
                dailyValues.append(value)
            }
            DispatchQueue.main.async {
                completion(dailyValues)
            }
        }
        
        healthStore.execute(query)
    }

    
    private func fetchHeartRateStats(start: Date, end: Date, completion: @escaping (Double, Double) -> Void) {
        guard let type = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return completion(0, 0) }
        
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: [.discreteAverage, .discreteMax]) { _, result, _ in
            let avg = result?.averageQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute())) ?? 0
            let max = result?.maximumQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute())) ?? 0
            completion(avg, max)
        }
        healthStore.execute(query)
    }
    
    private func fetchSleepStats(start: Date, end: Date, completion: @escaping (Double, Double) -> Void) {
        guard let type = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else { return completion(0, 0) }
        
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
            var durations = [Double]()
            
            let calendar = Calendar.current
            let grouped = Dictionary(grouping: samples as? [HKCategorySample] ?? [], by: { calendar.startOfDay(for: $0.startDate) })
            for (_, daySamples) in grouped {
                let totalSleep = daySamples.reduce(0) { $0 + $1.endDate.timeIntervalSince($1.startDate) / 3600 } // hours
                durations.append(totalSleep) // use `steps` field to store hours for simplicity
            }
            
            let total = durations.reduce(0, +)
            let avg = durations.isEmpty ? 0 : total / Double(durations.count) // hours
            let best = (durations.max() ?? 0)
            completion(avg, best)
        }
        healthStore.execute(query)
    }
    
    private func unit(for type: HKQuantityTypeIdentifier) -> HKUnit {
        switch type {
        case .stepCount:
            return .count()
        case .activeEnergyBurned:
            return .kilocalorie()
        default:
            return .count()
        }
    }
}

