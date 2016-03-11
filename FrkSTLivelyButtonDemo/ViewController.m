//
//  ViewController.m
//  FrkSTLivelyButtonDemo
//
//  Created by Mr.Psychosis on 16/3/10.
//  Copyright © 2016年 Frank. All rights reserved.
//

#import "ViewController.h"
#import "FrkSTLivelyButton.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet FrkSTLivelyButton *bigButton;
@property (weak, nonatomic) IBOutlet FrkSTLivelyButton *burgerButton;
@property (weak, nonatomic) IBOutlet FrkSTLivelyButton *plustButton;
@property (weak, nonatomic) IBOutlet FrkSTLivelyButton *plusCircleButton;
@property (weak, nonatomic) IBOutlet FrkSTLivelyButton *closeButton;
@property (weak, nonatomic) IBOutlet FrkSTLivelyButton *closeCircleButton;
@property (weak, nonatomic) IBOutlet FrkSTLivelyButton *upCareButton;
@property (weak, nonatomic) IBOutlet FrkSTLivelyButton *downCareButton;
@property (weak, nonatomic) IBOutlet FrkSTLivelyButton *leftCareButton;
@property (weak, nonatomic) IBOutlet FrkSTLivelyButton *rightCareButton;
@property (weak, nonatomic) IBOutlet FrkSTLivelyButton *leftArrowButton;
@property (weak, nonatomic) IBOutlet FrkSTLivelyButton *rightArrowButton;

@end

@implementation ViewController
{
    kFrkSTLivelyButtonStyle newStyle;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.burgerButton setStyle:kFrkSTLivelyButtonStyleHamburger animated:NO];
    [self.plusCircleButton setStyle:kFrkSTLivelyButtonStyleCirclePlus animated:NO];
    [self.plustButton setStyle:kFrkSTLivelyButtonStylePlus animated:NO];
    [self.closeButton setStyle:kFrkSTLivelyButtonStyleClose animated:NO];
    [self.closeCircleButton setStyle:kFrkSTLivelyButtonStyleCircleClose animated:NO];
    [self.upCareButton setStyle:kFrkSTLivelyButtonStyleCaretUp animated:NO];
    [self.downCareButton setStyle:kFrkSTLivelyButtonStyleCaretDown animated:NO];
    [self.leftCareButton setStyle:kFrkSTLivelyButtonStyleCaretLeft animated:NO];
    [self.rightCareButton setStyle:kFrkSTLivelyButtonStyleCaretRight animated:NO];
    [self.leftArrowButton setStyle:kFrkSTLivelyButtonStyleArrowLeft animated:NO];
    [self.rightArrowButton setStyle:kFrkSTLivelyButtonStyleArrowRight animated:NO];
    
    [self.bigButton setStyle:kFrkSTLivelyButtonStyleClose animated:YES];
    [self.bigButton setOptions:@{kFrkSTLivelyButtonLineWidth: @(4.0f)}];
}
- (IBAction)changeButtonStyleAction:(FrkSTLivelyButton *)sender {
    [self.bigButton setStyle:sender.buttonStyle animated:YES];
}

@end
