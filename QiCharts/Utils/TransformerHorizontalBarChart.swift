//
//  TransformerHorizontalBarChart.swift
//  QiCharts
//
//  Created by wangdacheng on 2019/10/14.
//  Copyright © 2019 qishare. All rights reserved.
//

import Foundation
import CoreGraphics

@objc(ChartTransformerHorizontalBarChart)
open class TransformerHorizontalBarChart: ChartTransformer
{
    /// Prepares the matrix that contains all offsets.
    open override func prepareMatrixOffset(inverted: Bool)
    {
        if !inverted
        {
            _matrixOffset = CGAffineTransform(translationX: _viewPortHandler.offsetLeft, y: _viewPortHandler.chartHeight - _viewPortHandler.offsetBottom)
        }
        else
        {
            _matrixOffset = CGAffineTransform(scaleX: -1.0, y: 1.0)
            _matrixOffset = _matrixOffset.translatedBy(x: -(_viewPortHandler.chartWidth - _viewPortHandler.offsetRight),
                y: _viewPortHandler.chartHeight - _viewPortHandler.offsetBottom)
        }
    }
}
