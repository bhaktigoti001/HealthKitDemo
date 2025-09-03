//
//  DGBarChart.swift
//  HealthApp
//
//  Created by DREAMWORLD on 03/09/25.
//

import SwiftUI
import DGCharts

struct DGBarChart: UIViewRepresentable {
    var data: [DailyProgress]
    var range: TimeRange
    
    func makeUIView(context: Context) -> BarChartView {
        let chart = BarChartView()
        chart.rightAxis.enabled = false
        
        chart.xAxis.labelPosition = .bottom
        chart.xAxis.drawGridLinesEnabled = false
        chart.leftAxis.drawGridLinesEnabled = true
        
        // Disable vertical zoom & scrolling
        chart.scaleYEnabled = false        // prevents vertical zoom
        chart.dragYEnabled = false         // disables vertical scroll
        
        // Disable tap selection on bars
        chart.highlightPerTapEnabled = false
        chart.highlightPerDragEnabled = false
        
        chart.animate(yAxisDuration: 0.5)
        chart.legend.enabled = false
        return chart
    }
    
    func updateUIView(_ uiView: BarChartView, context: Context) {
        let entries = data.enumerated().map { index, day in
            BarChartDataEntry(x: Double(index), y: day.steps)
        }
        
        let set = BarChartDataSet(entries: entries)
        set.colors = [NSUIColor.systemBlue]
        set.valueTextColor = .label
        set.valueFont = .systemFont(ofSize: 10)
        set.drawValuesEnabled = false
        
        let chartData = BarChartData(dataSet: set)
        chartData.barWidth = 0.6
        uiView.data = chartData
        
        // X-Axis labels
        uiView.xAxis.valueFormatter = IndexAxisValueFormatter(values: data.map { xAxisLabel(for: $0.date, range: range) })
        uiView.xAxis.granularity = 1
        uiView.notifyDataSetChanged()
    }
    
    func xAxisLabel(for date: Date, range: TimeRange) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        
        switch range {
        case .week:
            formatter.dateFormat = "E"
            return formatter.string(from: date)
        case .month:
            let day = calendar.component(.day, from: date)
            return "\(day)"
        case .sixMonths:
            formatter.dateFormat = "MMM"
            return formatter.string(from: date)
        case .year:
            formatter.dateFormat = "MMM"
            return formatter.string(from: date)
        }
    }
}
