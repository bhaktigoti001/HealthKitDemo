//
//  BarMarkerView.swift
//  HealthApp
//
//  Created by DREAMWORLD on 03/09/25.
//

import DGCharts

class BarMarkerView: MarkerView {
    private let label = UILabel()
    private var shouldDraw = true   // control flag

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white.withAlphaComponent(0.9)
        layer.cornerRadius = 6
        clipsToBounds = true
        
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .black
        label.textAlignment = .center
        addSubview(label)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        if entry.y == 0 {
            shouldDraw = false
            return
        }
        
        shouldDraw = true
        label.text = "\(entry.y.formattedNumberString())"
        label.sizeToFit()
        
        let paddingH: CGFloat = 12
        let paddingV: CGFloat = 6
        
        self.frame.size = CGSize(
            width: label.frame.width + paddingH,
            height: label.frame.height + paddingV
        )
        
        label.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        super.refreshContent(entry: entry, highlight: highlight)
    }

    override func draw(context: CGContext, point: CGPoint) {
        // Only draw if we have a valid value
        if shouldDraw {
            super.draw(context: context, point: point)
        }
    }

    override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint {
        return CGPoint(x: -bounds.width / 2, y: -bounds.height - 8)
    }
}
