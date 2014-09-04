//
//  ViewController.m
//  pdfPOC
//
//  Created by Amit Jain on 04/09/14.
//  Copyright (c) 2014 ajonnet. All rights reserved.
//

#import "ViewController.h"

#define CellID @"CellID"

@interface ViewController () <UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableV;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
}

#pragma mark - UITableViewDelegate,UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1000;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    
    NSString *txt = [NSString stringWithFormat:@"%d",indexPath.row];
    UILabel *lbl = (UILabel *)[cell viewWithTag:1];
    lbl.text = txt;
    lbl = (UILabel *)[cell viewWithTag:2];
    lbl.text = txt;
    lbl = (UILabel *)[cell viewWithTag:3];
    lbl.text = txt;
    
    NSLog(@"Cell loaded for index: %d",indexPath.row);
    
    return cell;
}

#pragma mark - IBAction methods
- (IBAction)onPdfItBtClick:(id)sender {
    /*
    NSData *data = [self pdfDataWithTableView:self.tableV];
    NSLog(@"PDF bytes[%d] kb[%d] mb[%d]",data.length,data.length/1024,(data.length/1024)/1024);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        // Generate the file path
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"tableV.pdf"];
        
        // Save it into file system
        [data writeToFile:dataPath atomically:YES];
        
        NSLog(@"file saved at path: %@",dataPath);
    });
     */
    
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"tableV.pdf"];
        
        [self pdfData2WithTableView:self.tableV filePath:dataPath];
    }
}

-(NSData *) pdfDataWithTableView:(UITableView *) tableView
{
    CGRect priorBounds = tableView.bounds;
    CGSize fittedSize = [tableView sizeThatFits:CGSizeMake(priorBounds.size.width, HUGE_VALF)];
    tableView.bounds = CGRectMake(0, 0, fittedSize.width, fittedSize.height);
    
    // Standard US Letter dimensions 8.5" x 11"
    CGRect pdfPageBounds = CGRectMake(0, 0, 612, 792);
    
    NSMutableData *pdfData = [[NSMutableData alloc] init];
    UIGraphicsBeginPDFContextToData(pdfData, pdfPageBounds, nil);
    {
        for (CGFloat pageOriginY = 0; pageOriginY < fittedSize.height; pageOriginY += pdfPageBounds.size.height) {
            UIGraphicsBeginPDFPageWithInfo(pdfPageBounds, nil);
            CGContextSaveGState(UIGraphicsGetCurrentContext());
            {
                CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0, -pageOriginY);
                [tableView.layer renderInContext:UIGraphicsGetCurrentContext()];
            }
            CGContextRestoreGState(UIGraphicsGetCurrentContext());
        }
    }
    UIGraphicsEndPDFContext();
    
    tableView.bounds = priorBounds;
    
    return pdfData;
}

-(void) pdfDataWithTableView:(UITableView *) tableView filePath:(NSString *) filePath
{
    CGRect priorBounds = tableView.bounds;
    
    CGSize fittedSize = [tableView sizeThatFits:CGSizeMake(priorBounds.size.width, HUGE_VALF)];
    tableView.bounds = CGRectMake(0, 0, fittedSize.width, fittedSize.height);
    
    // Standard US Letter dimensions 8.5" x 11"
    CGRect pdfPageBounds = CGRectMake(0, 0, 612, 792);
    
    UIGraphicsBeginPDFContextToFile(filePath, pdfPageBounds, nil);
    {
        for (CGFloat pageOriginY = 0; pageOriginY < fittedSize.height; pageOriginY += pdfPageBounds.size.height) {
            CGFloat pageheight = pdfPageBounds.size.height;
            NSLog(@"%f/%f",pageOriginY/pageheight,fittedSize.height/pageheight);
            
            UIGraphicsBeginPDFPageWithInfo(pdfPageBounds, nil);
            CGContextSaveGState(UIGraphicsGetCurrentContext());
            {
                CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0, -pageOriginY);
                [tableView.layer renderInContext:UIGraphicsGetCurrentContext()];
            }
            CGContextRestoreGState(UIGraphicsGetCurrentContext());
        }
    }
    UIGraphicsEndPDFContext();
    
    tableView.bounds = priorBounds;
}
CGContextRef ctxRef;
-(void) pdfData2WithTableView:(UITableView *) tableView filePath:(NSString *) filePath
{
    CGRect priorBounds = tableView.bounds;
    CGPoint priorOffset = tableView.contentOffset;
    
    CGSize fittedSize = [tableView sizeThatFits:CGSizeMake(priorBounds.size.width, HUGE_VALF)];

    
    // Standard US Letter dimensions 8.5" x 11"
    CGRect pdfPageBounds = CGRectMake(0, 0, 612, 792);
    
    tableView.bounds = CGRectMake(0, 0, fittedSize.width, pdfPageBounds.size.height);
    
    BOOL flag =  UIGraphicsBeginPDFContextToFile(filePath, pdfPageBounds, nil);
    assert(flag);
    ctxRef = UIGraphicsGetCurrentContext();
    [self performSelector:@selector(addNextPage) withObject:nil afterDelay:0.125];
/*
    {
        for (CGFloat pageOriginY = 0; pageOriginY < fittedSize.height; pageOriginY += pdfPageBounds.size.height) {
            CGFloat pageheight = pdfPageBounds.size.height;
            NSLog(@"%f/%f",pageOriginY/pageheight,fittedSize.height/pageheight);
            
            tableView.contentOffset = CGPointMake(0, pageOriginY);
            
            UIGraphicsBeginPDFPageWithInfo(pdfPageBounds, nil);

            //CGContextStrokeEllipseInRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, 100, 100));
            //CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0, pageOriginY);
            [tableView.layer renderInContext:UIGraphicsGetCurrentContext()];
            
        }
    }
    UIGraphicsEndPDFContext();
    
    tableView.bounds = priorBounds;
    tableView.contentOffset = priorOffset;
 */
}

-(void) addNextPage
{
    UITableView *tableView = self.tableV;
    
    CGRect priorBounds = tableView.bounds;
    CGRect pdfPageBounds = CGRectMake(0, 0, 612, 792);
    CGSize fittedSize = [tableView sizeThatFits:CGSizeMake(priorBounds.size.width, HUGE_VALF)];
    
    UIGraphicsBeginPDFPageWithInfo(pdfPageBounds, nil);
    [self.tableV.layer renderInContext:ctxRef];

    CGFloat newOffset = tableView.contentOffset.y + pdfPageBounds.size.height;
    if (newOffset < fittedSize.height) {
        tableView.contentOffset = CGPointMake(0,newOffset );
        [self performSelector:@selector(addNextPage) withObject:nil afterDelay:0.125];
    }else {
        UIGraphicsEndPDFContext();
    }

    
}

@end
