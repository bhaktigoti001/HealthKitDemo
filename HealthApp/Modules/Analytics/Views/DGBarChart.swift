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
        let marker = BarMarkerView(frame: CGRect(x: 0, y: 0, width: 60, height: 30))

        let chart = BarChartView()
        chart.rightAxis.enabled = false
        marker.chartView = chart
        chart.marker = marker
        
        chart.xAxis.labelPosition = .bottom
        chart.xAxis.drawGridLinesEnabled = false
        chart.leftAxis.drawGridLinesEnabled = true
        chart.leftAxis.axisMinimum = 0.0
        
        // Disable vertical zoom & scrolling
        chart.scaleYEnabled = false        // prevents vertical zoom
        chart.dragYEnabled = false         // disables vertical scroll
        
//        chart.renderer = RoundedBarChartRenderer(
//            dataProvider: chart,
//            animator: chart.chartAnimator,
//            viewPortHandler: chart.viewPortHandler
//        )
        
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
        uiView.xAxis.valueFormatter = IndexAxisValueFormatter(values: data.map { xAxisLabel(for: $0.date, range: range) })
        
        uiView.highlightValues(nil)
        uiView.fitScreen()
        uiView.viewPortHandler.setMaximumScaleX(range.maxZoomScale)
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

//class GradientBarChartRenderer: BarChartRenderer {
//    override func drawData(context: CGContext) {
//        guard let barData = dataProvider?.barData else { return }
//
//        for i in 0 ..< barData.dataSetCount {
//            guard let set = barData.dataSets[i] as? BarChartDataSetProtocol else { continue }
//            if set.isVisible {
//                drawGradientDataSet(context: context, dataSet: set, index: i)
//            }
//        }
//    }
//
//    private func drawGradientDataSet(context: CGContext,
//                                     dataSet: BarChartDataSetProtocol,
//                                     index: Int) {
//        guard let dataProvider = dataProvider else { return }
//        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
//        let phaseY = animator.phaseY
//
//        var barRect = CGRect()
//
//        for j in 0 ..< dataSet.entryCount {
//            guard let e = dataSet.entryForIndex(j) as? BarChartDataEntry else { continue }
//
//            let x = CGFloat(e.x)
//            let y = CGFloat(e.y)
//
//            let left = x - 0.4
//            let right = x + 0.4
//            let top = y >= 0 ? y * CGFloat(phaseY) : 0
//            let bottom = y <= 0 ? y * CGFloat(phaseY) : 0
//
//            barRect = CGRect(x: left, y: top, width: right - left, height: bottom - top)
//            trans.rectValueToPixel(&barRect)
//
//            let gradientColors = [UIColor.systemBlue.cgColor,
//                                  UIColor.systemIndigo.cgColor,
//                                  UIColor.systemPurple.cgColor] as CFArray
//            let colorLocations: [CGFloat] = [0.0, 0.5, 1.0]
//
//            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
//                                         colors: gradientColors,
//                                         locations: colorLocations) {
//                context.saveGState()
//                context.addRect(barRect)
//                context.clip()
//                context.drawLinearGradient(
//                    gradient,
//                    start: CGPoint(x: barRect.midX, y: barRect.maxY),
//                    end: CGPoint(x: barRect.midX, y: barRect.minY),
//                    options: []
//                )
//                context.restoreGState()
//            }
//        }
//    }
//}


class RoundedBarChartRenderer: BarChartRenderer {
    override func drawData(context: CGContext) {
        guard let barData = dataProvider?.barData else { return }

        for i in 0 ..< barData.dataSetCount {
            guard let set = barData.dataSets[i] as? BarChartDataSetProtocol else { continue }
            if set.isVisible {
                drawRoundedDataSet(context: context, dataSet: set, index: i)
            }
        }
    }

    private func drawRoundedDataSet(context: CGContext,
                                    dataSet: BarChartDataSetProtocol,
                                    index: Int) {
        guard let dataProvider = dataProvider else { return }
        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        let phaseY = animator.phaseY

        for j in 0 ..< dataSet.entryCount {
            guard let e = dataSet.entryForIndex(j) as? BarChartDataEntry else { continue }

            let x = CGFloat(e.x)
            let y = CGFloat(e.y)

            var barRect = CGRect(x: x - 0.4,
                                 y: y >= 0 ? y * CGFloat(phaseY) : 0,
                                 width: 0.8,
                                 height: -y * CGFloat(phaseY))

            trans.rectValueToPixel(&barRect)

            // Round only top corners
            let cornerRadius: CGFloat = 4
            let path = UIBezierPath(
                roundedRect: barRect,
                byRoundingCorners: [.topLeft, .topRight],
                cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
            )
            
            context.saveGState()
            context.setFillColor(UIColor.systemBlue.cgColor)
            context.addPath(path.cgPath)
            context.fillPath()
            context.restoreGState()
            /*
            // Gradient fill (optional)
            let gradientColors = [UIColor.systemBlue.cgColor,
                                  UIColor.systemIndigo.cgColor,
                                  UIColor.systemPurple.cgColor] as CFArray
            let colorLocations: [CGFloat] = [0.0, 0.5, 1.0]

            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                         colors: gradientColors,
                                         locations: colorLocations) {
                context.saveGState()
                context.addPath(path.cgPath)
                context.clip()
                context.drawLinearGradient(
                    gradient,
                    start: CGPoint(x: barRect.midX, y: barRect.maxY),
                    end: CGPoint(x: barRect.midX, y: barRect.minY),
                    options: []
                )
                context.restoreGState()
            }*/
        }
    }
}
