//
//  BCPlotDataSource.h
//  BalconyGardener
//
//  Created by Thomas Engelmeier on 19.10.14.
//  Copyright (c) 2014 Daniel Peter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CorePlot-CocoaTouch.h"


@interface BCPlotDataSource : NSObject<CPTPlotDataSource, CPTPlotSpaceDelegate>
@property (nonatomic, strong) IBOutlet CPTGraphHostingView *hostView;
@property (nonatomic, readonly, strong) NSString *sensorName;
@property (nonatomic, readonly, strong) NSArray *sensorData;

- (void) displaySensorTitle:(NSString *)name values:(NSArray *) sensorValues;
@end
