//
//  BCPlotDataSource.m
//  BalconyGardener
//
//  Created by Thomas Engelmeier on 19.10.14.
//  Copyright (c) 2014 Daniel Peter. All rights reserved.
//



#import "BCPlotDataSource.h"

@interface BCPlotDataSource() {
    CPTXYGraph *graph;
    CPTFill *areaFill;
    CPTLineStyle *barLineStyle;
    
    NSDate *startDate;
    NSDate *endDate;
    
    double minValue, maxValue;
    
    CPTTimeFormatter *dateFormatter;
    CPTTimeFormatter *timeFormatter;
    
    NSArray *currentPlots;
}
@property (nonatomic, strong) NSString *sensorName;
@property (nonatomic, strong) NSArray *sensorData;

@end

@implementation BCPlotDataSource

-(void) configureGraph {
    if( self.hostView && !self.hostView.hostedGraph) {
        // If you make sure your dates are calculated at noon, you shouldn't have to
        // worry about daylight savings. If you use midnight, you will have to adjust
        // for daylight savings time.
        //  NSDate *refDate       = [NSDate dateWithTimeIntervalSince1970:0.];
        
        // Create graph from theme
        graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
#if TARGET_OS_IPHONE
        [graph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
        graph.paddingLeft = 20.;
        graph.paddingRight = 20.;
        graph.paddingTop = 20.;
        graph.paddingBottom = 20.;
        CPTMutableLineStyle *borderStyle = [[CPTMutableLineStyle alloc] init];
        borderStyle.lineWidth = 0.;
        graph.borderLineStyle = borderStyle;
#else
        [graph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
#endif
        
        self.hostView.hostedGraph = graph;
        
        CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
        textStyle.color         = [CPTColor whiteColor];
        textStyle.fontSize      = 18.0;
        textStyle.fontName      = @"Helvetica";
        graph.titleTextStyle    = textStyle;
        
        CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = kCFDateFormatterShortStyle;
        dateFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:formatter] ;
        dateFormatter.referenceDate = [NSDate dateWithTimeIntervalSince1970:0.];
        
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = kCFDateFormatterNoStyle;
        formatter.timeStyle = kCFDateFormatterShortStyle;
        timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:formatter] ;
        timeFormatter.referenceDate = [NSDate dateWithTimeIntervalSince1970:0.];
        
        axisSet.xAxis.labelFormatter            = dateFormatter;
        [self generateLegend];
        
        graph.defaultPlotSpace.allowsUserInteraction = YES;
        graph.defaultPlotSpace.delegate = self;
        
        for( CPTPlot *plot in currentPlots ) {
            [graph addPlot:plot];
        }
    }
}

-(void)awakeFromNib
{
    [super awakeFromNib];
}

- (void) setHostView:(CPTGraphHostingView *)hostView {
    _hostView = hostView;
    [self configureGraph];
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    NSUInteger count = self.sensorData.count;
    NSLog( @"have %i records", (int) count );
    return  count;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSDictionary *valueDict = self.sensorData[index];
    NSNumber *value = nil;
   
    
    switch ( fieldEnum ) {
        case CPTBarPlotFieldBarLocation:
            value = [NSNumber numberWithUnsignedInteger:index];
            break;
            
        default:
            
            value = valueDict[@"value"];
            // NSLog( @"Value %@ at %i", value, (int)index );
            break;
    }
    
    return value; // [@(fieldEnum)];
}

- (CPTPlotRange *)plotSpace:(CPTPlotSpace *)space
      willChangePlotRangeTo:(CPTPlotRange *)newRange
              forCoordinate:(CPTCoordinate)coordinate {
    
    NSLog( @"%s: newRange(%@) coord:%i", __PRETTY_FUNCTION__, newRange, coordinate );
 
    return newRange;
}


double exp10( double value ) {
    int val = value;
    double result = 1.;
    while ( val > 0 ) {
        result *= 10.;
        val -= 1;
    }
    return result;
}

- (void) adjustYScale {
    double exponent = log10( maxValue );
    double tmp = maxValue / exp10( exponent );
    tmp = ceil( tmp );
    int ticks = tmp;
    
    double newMax = tmp * exp10( exponent );
    
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *y          = axisSet.yAxis;
    
    y.majorIntervalLength         = CPTDecimalFromDouble( newMax / ticks );
    y.minorTicksPerInterval       = ticks;
    y.orthogonalCoordinateDecimal = CPTDecimalFromDouble( startDate.timeIntervalSince1970 );
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    double yLength = newMax - minValue;
    
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble( - (yLength * 0.1) ) length:CPTDecimalFromDouble( yLength * 1.2 )];
}

- (void) adjustTimeScale {
    NSTimeInterval oneDay = 24 * 60 * 60;
    
    NSRange currentDisplayRange = NSMakeRange( startDate.timeIntervalSince1970, endDate.timeIntervalSince1970 - startDate.timeIntervalSince1970 );
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt( currentDisplayRange.location - (currentDisplayRange.length * 0.1) ) length:CPTDecimalFromDouble( currentDisplayRange.length * 1.2 )];
    
    // Axes
    // Y-Axis is adjusted to values
    
    // X-Axis adjustment to display range:
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.orthogonalCoordinateDecimal = CPTDecimalFromFloat( 0. );
    axisSet.yAxis.orthogonalCoordinateDecimal = CPTDecimalFromDouble( currentDisplayRange.location );
    
    x.majorIntervalLength   = CPTDecimalFromFloat(oneDay / 24.);
    x.minorTicksPerInterval = 0;
    x.labelFormatter         = timeFormatter;
}


- (void) generateLegend {
    if( self.sensorData.count > 1 ) {
        // Add legend
        CPTLegend *theLegend = [CPTLegend legendWithGraph:graph];
        theLegend.fill            = [CPTFill fillWithColor:[CPTColor colorWithGenericGray:0.15]];
        theLegend.borderLineStyle = barLineStyle;
        theLegend.cornerRadius    = 10.0;
        theLegend.swatchSize      = CGSizeMake(16.0, 16.0);
        CPTMutableTextStyle *whiteTextStyle = [CPTMutableTextStyle textStyle];
        whiteTextStyle.color    = [CPTColor whiteColor];
        whiteTextStyle.fontSize = 12.0;
        theLegend.textStyle     = whiteTextStyle;
        theLegend.rowMargin     = 10.0;
        theLegend.numberOfRows  = 1; // self.sensorStreams.count;
        theLegend.paddingLeft   = 12.0;
        theLegend.paddingTop    = 12.0;
        theLegend.paddingRight  = 12.0;
        theLegend.paddingBottom = 12.0;
        
        graph.legend             = theLegend;
        graph.legendAnchor       = CPTRectAnchorTopRight;
        graph.legendDisplacement = CGPointMake(-30.0, -30.0);
    } else {
        graph.legend = nil;
    }
}

- (void) findBoundaries {
    NSTimeInterval minDate = MAXFLOAT;
    NSTimeInterval maxDate = 0.;
    
    minValue = MAXFLOAT;
    maxValue = 0.;
    
    NSDateFormatter *dateUnFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateUnFormatter setLocale:locale];
    [dateUnFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    // does not work...
    [dateUnFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    
    for( NSDictionary *d in self.sensorData ) {
        NSString *t = d[@"time"];
        NSDate *dateValue = [dateUnFormatter dateFromString:t];
        NSTimeInterval secs = [dateValue timeIntervalSince1970];
        minDate = secs < minDate ? secs : minDate;
        maxDate = secs > maxDate ? secs : maxDate;

        
        double v = [d[@"value"] doubleValue];
        minValue =  v < minValue ? v : minValue; // MAX( minValue, v );
        maxValue = v > maxValue ? v : maxValue; // MIN( maxValue, v );
    }
    
    startDate = [NSDate dateWithTimeIntervalSince1970:minDate];
    endDate = [NSDate dateWithTimeIntervalSince1970:maxDate];
    
    
}
- (void) displaySensorTitle:(NSString *)name values:(NSArray *) sensorValues {
    self.sensorName = name;
    self.sensorData = sensorValues;
    
    NSArray *plots = [graph.allPlots copy];
    for( CPTPlot *plot in plots ) {
        [graph removePlot:plot];
    }
    
    // iterate thrøugh all plots to grab plots:
    NSMutableArray *tempPlots = [NSMutableArray array];
    
    int index = 4;
    if( 1 ) {
#if TARGET_OS_IPHONE
        // UIColor *c = [UIColor  colorWithHue:(.1 * index) saturation:1.0 brightness:1.0 alpha:0.7];
        UIColor *c = [UIColor darkGrayColor];
        CPTColor *color = [CPTColor colorWithCGColor:c.CGColor];
#else
        CPTColor *color = [CPTColor colorWithCGColor:[NSColor colorWithCalibratedHue:(.1 * index) saturation:1.0 brightness:1.0 alpha:0.7].CGColor];
#endif
        ++index;
        
        CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init] ;
        dataSourceLinePlot.identifier = @"sensorStream";
        dataSourceLinePlot.title = self.sensorName;
        
        CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
        lineStyle.lineWidth              = 2.0;
        lineStyle.lineColor              = color;
        dataSourceLinePlot.dataLineStyle = lineStyle;
        
        dataSourceLinePlot.dataSource = self;
        [graph addPlot:dataSourceLinePlot];
        [tempPlots addObject:dataSourceLinePlot];
    }
    
    currentPlots = tempPlots;
    [self configureGraph];
    
    if( self.sensorData.count ) {
        [self findBoundaries];
        [self generateLegend];
        [self adjustTimeScale];
        [self adjustYScale];
    }
    
   
}
@end

