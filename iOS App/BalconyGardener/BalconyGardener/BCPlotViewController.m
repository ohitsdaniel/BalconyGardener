//
//  BCPlotViewController.m
//  BalconyGardener
//
//  Created by Thomas Engelmeier on 19.10.14.
//  Copyright (c) 2014 Daniel Peter. All rights reserved.
//

#import "BCPlotViewController.h"
#import <CorePlot/CPTPlot.h>

@interface BCPlotViewController ()
@property (nonatomic) NSArray *sensorValues;
@end

@implementation BCPlotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) viewWillAppear {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) internalInit {
#if 0
    // Update the user interface for the detail item.
    if( self.sensorController && !self.sensorController.hostView && self.graphHostView) {
        
        CPTGraphHostingView *view = [[CPTGraphHostingView alloc] initWithFrame:CGRectZero];
        // view.backgroundColor = [UIColor greenColor];
        NSDictionary *viewsDict = @{ @"graphView": view };
        self.sensorController.hostView = view;
        self.graphHostView.translatesAutoresizingMaskIntoConstraints = NO;
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self.graphHostView addSubview:view];
        
        NSMutableArray *constraints = [NSMutableArray array];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[graphView]|" options:0 metrics:nil views:viewsDict]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[graphView]|" options:0 metrics:nil views:viewsDict]];
        [self.graphHostView addConstraints:constraints];
    }
#endif
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
