//
//  AxisRendererBase.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

@objc(ChartAxisRendererBase)
open class AxisRendererBase: Renderer
{
    
    public var timeIntervals : Bool?
    public var timeIntervalsForSeconds : Bool?
    public var decimalIntervals : Bool?

    
    /// base axis this axis renderer works with
    open var axis: AxisBase?
    
    /// transformer to transform values to screen pixels and return
    open var transformer: Transformer?
    
    public override init()
    {
        super.init()
    }
    
    public init(viewPortHandler: ViewPortHandler?, transformer: Transformer?, axis: AxisBase?)
    {
        super.init(viewPortHandler: viewPortHandler)
        
        self.transformer = transformer
        self.axis = axis
    }
    
    /// Draws the axis labels on the specified context
    open func renderAxisLabels(context: CGContext)
    {
        fatalError("renderAxisLabels() cannot be called on AxisRendererBase")
    }
    
    /// Draws the grid lines belonging to the axis.
    open func renderGridLines(context: CGContext)
    {
        fatalError("renderGridLines() cannot be called on AxisRendererBase")
    }
    
    /// Draws the line that goes alongside the axis.
    open func renderAxisLine(context: CGContext)
    {
        fatalError("renderAxisLine() cannot be called on AxisRendererBase")
    }
    
    /// Draws the LimitLines associated with this axis to the screen.
    open func renderLimitLines(context: CGContext)
    {
        fatalError("renderLimitLines() cannot be called on AxisRendererBase")
    }
    
    /// Computes the axis values.
    /// - parameter min: the minimum value in the data object for this axis
    /// - parameter max: the maximum value in the data object for this axis
    open func computeAxis(min: Double, max: Double, inverted: Bool)
    {
        var min = min, max = max
        
        if let transformer = self.transformer
        {
            // calculate the starting and entry point of the y-labels (depending on zoom / contentrect bounds)
            if let viewPortHandler = viewPortHandler
            {
                if viewPortHandler.contentWidth > 10.0 && !viewPortHandler.isFullyZoomedOutY
                {
                    let p1 = transformer.valueForTouchPoint(CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentTop))
                    let p2 = transformer.valueForTouchPoint(CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentBottom))
                    
                    if !inverted
                    {
                        min = Double(p2.y)
                        max = Double(p1.y)
                    }
                    else
                    {
                        min = Double(p1.y)
                        max = Double(p2.y)
                    }
                }
            }
        }
        
        computeAxisValues(min: min, max: max)
    }
    
    
    
    /// Sets up the axis values. Computes the desired number of labels between the two given extremes.
    open func computeAxisValues(min: Double, max: Double)
    {
        guard let axis = self.axis else { return }
        
        let yMin = min
        let yMax = max
        
        let labelCount = axis.labelCount
        let range = abs(yMax - yMin)
        
        if labelCount == 0 || range <= 0 || range.isInfinite
        {
            axis.entries = [Double]()
            axis.centeredEntries = [Double]()
            return
        }
        
        // Find out how much spacing (in y value space) between axis values
        let rawInterval = range / Double(labelCount)
        var interval = ChartUtils.roundToNextSignificant(number: Double(rawInterval))
        
        // If granularity is enabled, then do not allow the interval to go below specified granularity.
        // This is used to avoid repeated values when rounding values for display.
        if axis.granularityEnabled
        {
            interval = interval < axis.granularity ? axis.granularity : interval
        }
        
        // Normalize interval
        let intervalMagnitude = ChartUtils.roundToNextSignificant(number: pow(10.0, Double(Int(log10(interval)))))
        let intervalSigDigit = Int(interval / intervalMagnitude)
        if intervalSigDigit > 5
        {
            // Use one order of magnitude higher, to avoid intervals like 0.9 or 90
            interval = floor(10.0 * Double(intervalMagnitude))
        }
        
        var n = axis.centerAxisLabelsEnabled ? 1 : 0
        
        // Custom intervals overriding
        // Two main modes are available here
        //   - time intervals: 1,5,15,30,60,120,180,240,360,720
        //   - 'standard intervals': 0.5,1,5,10,20,25,50,100
        //
        // Also possible to deactivate the 0.5 interval
        
        if timeIntervals ?? false {
            if (interval<1) {
                interval = 1
            }
            
            if (interval>1) && (interval<5) {
                interval = 5
            }
            
            if (interval > 5) && (interval < 15) {
                interval = 15
            }
            
            if (interval > 15) && (interval < 30) {
                interval = 30
            }
            
            if (interval > 30) && (interval < 60) {
                interval = 60
            }
            
            if (interval > 60) && (interval < 120) {
                interval = 120
            }
            
            if (interval > 120) && (interval < 180) {
                interval = 180
            }
            
            if (interval > 180) && (interval < 240) {
                interval = 240
            }
            
            if (interval > 240) && (interval < 360) {
                interval = 360
            }
            
            if (interval > 360) && (interval < 720) {
                interval = 720
            }
        } else {
            if timeIntervalsForSeconds ?? false {
                if (interval < 1) {
                    interval = 1
                }
                
                if (interval > 1) && (interval < 10) {
                    interval = 10
                }
                
                if (interval > 10) && (interval < 30) {
                    interval = 30
                }
                
                if (interval > 30) && (interval<60) {
                    interval = 60
                }
                
                if (interval>60) && (interval<300) {
                    interval = 300
                }
                
                if (interval > 300) && (interval < 900) {
                    interval = 900
                }
                
                if (interval > 900) && (interval < 1800) {
                    interval = 1800
                }
                
                if (interval > 1800) && (interval < 3600) {
                    interval = 3600
                }
                
                if (interval > 3600) && (interval < 7200) {
                    interval = 7200
                }
                
                if (interval > 7200) && (interval < 10800) {
                    interval = 10800
                }
                
                if (interval > 10800) && (interval < 14400) {
                    interval = 14400
                }
                
                if (interval > 14400) && (interval < 21600) {
                    interval = 21600
                }
                
                if (interval > 21600) && (interval < 43200) {
                    interval = 43200
                }
            } else {
                
                // Are decimals intervals enabled?
                if (decimalIntervals ?? false) {
                    if (interval<0.5) {
                        interval = 0.5
                    }
                } else {
                    if (interval < 1) {
                        interval = 1
                    }
                }
                
                if (interval>0.5) && (interval<1) {
                    interval = 1
                }
                
                if (interval > 1) && (interval<5) {
                    interval = 5
                }
                
                if (interval > 5) && (interval < 10) {
                    interval = 10
                }
                
                if (interval > 10) && (interval < 20) {
                    interval = 20
                }
                
                if (interval > 20) && (interval < 25) {
                    interval = 25
                }
                
                if (interval > 25) && (interval < 50) {
                    interval = 50
                }
                
                if (interval > 50) && (interval < 100) {
                    interval = 100
                }
            }
        }
        
        // force label count
        if axis.isForceLabelsEnabled
        {
            interval = Double(range) / Double(labelCount - 1)
            
            // Ensure stops contains at least n elements.
            axis.entries.removeAll(keepingCapacity: true)
            axis.entries.reserveCapacity(labelCount)
            
            var v = yMin
            
            for _ in 0 ..< labelCount
            {
                axis.entries.append(v)
                v += interval
            }
            
            n = labelCount
        }
        else
        {
            // no forced count
            
            var first = interval == 0.0 ? 0.0 : ceil(yMin / interval) * interval
            
            if axis.centerAxisLabelsEnabled
            {
                first -= interval
            }
            
            let last = interval == 0.0 ? 0.0 : ChartUtils.nextUp(floor(yMax / interval) * interval)
            
            if interval != 0.0 && last != first
            {
                for _ in stride(from: first, through: last, by: interval)
                {
                    n += 1
                }
            }
            
            // Ensure stops contains at least n elements.
            axis.entries.removeAll(keepingCapacity: true)
            axis.entries.reserveCapacity(labelCount)
            
            var f = first
            var i = 0
            while i < n
            {
                if f == 0.0
                {
                    // Fix for IEEE negative zero case (Where value == -0.0, and 0.0 == -0.0)
                    f = 0.0
                }
                
                axis.entries.append(Double(f))
                
                f += interval
                i += 1
            }
        }
        
        // set decimals
        if interval < 1
        {
            axis.decimals = Int(ceil(-log10(interval)))
        }
        else
        {
            axis.decimals = 0
        }
        
        if axis.centerAxisLabelsEnabled
        {
            axis.centeredEntries.reserveCapacity(n)
            axis.centeredEntries.removeAll()
            
            let offset: Double = interval / 2.0
            
            for i in 0 ..< n
            {
                axis.centeredEntries.append(axis.entries[i] + offset)
            }
        }
    }
}
