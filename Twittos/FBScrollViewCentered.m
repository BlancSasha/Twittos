//
//  FBScrollViewCentered.m
//  Twittos
//
//  Created by François Blanc on 09/02/2016.
//  Copyright © 2016 François Blanc. All rights reserved.
//

#import "FBScrollViewCentered.h"

@implementation FBScrollViewCentered

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self centerScrollViewContent];
}

-(void)centerScrollViewContent
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(viewForZoomingInScrollView:)])
    {
        UIView *imageViewForCentering = [self.delegate viewForZoomingInScrollView:self];
        
        CGSize boundsSize = UIEdgeInsetsInsetRect(self.bounds, self.contentInset).size;
        CGRect frameToCenter = imageViewForCentering.frame;
        
        // center horizontally
        if (frameToCenter.size.width < boundsSize.width)
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
        else
            frameToCenter.origin.x = 0;
        
        // center vertically
        if (frameToCenter.size.height < boundsSize.height)
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
        else
            frameToCenter.origin.y = 0;
        
        imageViewForCentering.frame = frameToCenter;

    }

}
@end
