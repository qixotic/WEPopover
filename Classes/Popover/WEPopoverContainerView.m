//
//  WEPopoverContainerViewProperties.m
//  WEPopover
//
//  Created by Werner Altewischer on 02/09/10.
//  Copyright 2010 Werner IT Consultancy. All rights reserved.
//

#import "WEPopoverContainerView.h"

@implementation WEPopoverContainerViewProperties

@synthesize bgImageName, upArrowImageName, downArrowImageName, leftArrowImageName, rightArrowImageName, topBgMargin, bottomBgMargin, leftBgMargin, rightBgMargin, topBgCapSize, leftBgCapSize;
@synthesize leftContentMargin, rightContentMargin, topContentMargin, bottomContentMargin, arrowMargin, noAnchor;


@end

@interface WEPopoverContainerView(Private)

- (void)determineGeometryForSize:(CGSize)theSize anchorRect:(CGRect)anchorRect displayArea:(CGRect)displayArea permittedArrowDirections:(UIPopoverArrowDirection)permittedArrowDirections;
- (CGRect)contentRect;
- (CGSize)contentSize;
- (void)setProperties:(WEPopoverContainerViewProperties *)props;
- (void)initFrame;

@end

@implementation WEPopoverContainerView

@synthesize arrowDirection, contentView;

- (id)initWithSize:(CGSize)theSize 
		anchorRect:(CGRect)anchorRect 
	   displayArea:(CGRect)displayArea
permittedArrowDirections:(UIPopoverArrowDirection)permittedArrowDirections
		properties:(WEPopoverContainerViewProperties *)theProperties {
	if ((self = [super initWithFrame:CGRectZero])) {
		
		[self setProperties:theProperties];
		correctedSize = CGSizeMake(theSize.width + properties.leftBgMargin + properties.rightBgMargin + properties.leftContentMargin + properties.rightContentMargin, 
								   theSize.height + properties.topBgMargin + properties.bottomBgMargin + properties.topContentMargin + properties.bottomContentMargin);	
		[self determineGeometryForSize:correctedSize anchorRect:anchorRect displayArea:displayArea permittedArrowDirections:permittedArrowDirections];
		[self initFrame];
		self.backgroundColor = [UIColor clearColor];
		UIImage *theImage = [UIImage imageNamed:properties.bgImageName];
		bgImage = [theImage stretchableImageWithLeftCapWidth:properties.leftBgCapSize topCapHeight:properties.topBgCapSize];
		
		self.clipsToBounds = YES;
		self.userInteractionEnabled = YES;
	}
	return self;
}


- (void)drawRect:(CGRect)rect {
	[bgImage drawInRect:bgRect blendMode:kCGBlendModeNormal alpha:1.0];
	[arrowImage drawInRect:arrowRect blendMode:kCGBlendModeNormal alpha:1.0]; 
}

- (void)updatePositionWithAnchorRect:(CGRect)anchorRect 
						 displayArea:(CGRect)displayArea
			permittedArrowDirections:(UIPopoverArrowDirection)permittedArrowDirections {
	[self determineGeometryForSize:correctedSize anchorRect:anchorRect displayArea:displayArea permittedArrowDirections:permittedArrowDirections];
	[self initFrame];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	return CGRectContainsPoint(self.contentRect, point);	
} 

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

- (void)setContentView:(UIView *)v {
	if (v != contentView) {
		contentView = v;		
		contentView.frame = self.contentRect;		
		[self addSubview:contentView];
	}
}



@end

@implementation WEPopoverContainerView(Private)

- (void)initFrame {
	CGRect theFrame = CGRectOffset(CGRectUnion(bgRect, arrowRect), offset.x, offset.y);
	
	//If arrow rect origin is < 0 the frame above is extended to include it so we should offset the other rects
	arrowOffset = CGPointMake(MAX(0, -arrowRect.origin.x), MAX(0, -arrowRect.origin.y));
	bgRect = CGRectOffset(bgRect, arrowOffset.x, arrowOffset.y);
	arrowRect = CGRectOffset(arrowRect, arrowOffset.x, arrowOffset.y);
	
	self.frame = CGRectIntegral(theFrame);	
}																		 

- (CGSize)contentSize {
	return self.contentRect.size;
}

- (CGRect)contentRect {
	CGRect rect = CGRectMake(properties.leftBgMargin + properties.leftContentMargin + arrowOffset.x, 
							 properties.topBgMargin + properties.topContentMargin + arrowOffset.y, 
							 bgRect.size.width - properties.leftBgMargin - properties.rightBgMargin - properties.leftContentMargin - properties.rightContentMargin,
							 bgRect.size.height - properties.topBgMargin - properties.bottomBgMargin - properties.topContentMargin - properties.bottomContentMargin);
	return rect;
}

- (void)setProperties:(WEPopoverContainerViewProperties *)props {
	if (properties != props) {
		properties = props;
	}
}

- (void)determineGeometryForSize:(CGSize)theContentSize anchorRect:(CGRect)anchorRect displayArea:(CGRect)displayArea permittedArrowDirections:(UIPopoverArrowDirection)supportedArrowDirections {	
	
	//Determine the frame, it should not go outside the display area
	UIPopoverArrowDirection theArrowDirection = UIPopoverArrowDirectionUp;
	
	offset =  CGPointZero;
	bgRect = CGRectNull;
	arrowRect = CGRectZero;
	arrowDirection = UIPopoverArrowDirectionUnknown;

    // If we have no anchor point, don't draw any arrows and just display the popup centered on and clipped to the display area.
    if (properties.noAnchor) {
        CGSize theSize = theContentSize;
        CGPoint theOffset = CGPointZero;
        CGFloat shift = 0.0;

        // First center the content on the display area.
        theOffset.x = CGRectGetMidX(displayArea) - theSize.width/2;
        theOffset.y = CGRectGetMidY(displayArea) - theSize.height/2;

        // If still going past right, resize width
        if (theOffset.x + theSize.width > CGRectGetMaxX(displayArea)) {
            shift = theOffset.x + theSize.width - CGRectGetMaxX(displayArea);
            theSize.width -= shift;
        }
        // If going past the bottom bounds, resize height
        if (theOffset.y + theSize.height > CGRectGetMaxY(displayArea)) {
            shift = theOffset.y + theSize.height - CGRectGetMaxY(displayArea);
            theSize.height -= shift;
        }
        // If still going past the top bounds, shift down and resize
        if (theOffset.y < CGRectGetMinY(displayArea)) {
            shift = CGRectGetMinY(displayArea) - theOffset.y;
            theOffset.y += shift;
            theSize.height -= shift;
        }
        // If going past the left bounds, shift right and resize width
        if (theOffset.x < CGRectGetMinX(displayArea)) {
            shift = CGRectGetMinX(displayArea) - theOffset.x;
            theOffset.x += shift;
            theSize.width -= shift;
        }
        offset = theOffset;
        bgRect = CGRectMake(0, 0, theSize.width, theSize.height);
        arrowImage = nil;
        return;
    }
    // Otherwise, figure out which of the allowed arrow directions would yield the biggest surface area to display the popover.

	CGFloat biggestSurface = 0.0f;

	UIImage *upArrowImage = [UIImage imageNamed:properties.upArrowImageName];
	UIImage *downArrowImage = [UIImage imageNamed:properties.downArrowImageName];
	UIImage *leftArrowImage = [UIImage imageNamed:properties.leftArrowImageName];
	UIImage *rightArrowImage = [UIImage imageNamed:properties.rightArrowImageName];
	
	while (theArrowDirection <= UIPopoverArrowDirectionRight) {
		
		if ((supportedArrowDirections & theArrowDirection)) {
			
            CGSize theSize = theContentSize;
            CGRect theBgRect = CGRectZero;
			CGRect theArrowRect = CGRectZero;
			CGPoint theOffset = CGPointZero;
			CGFloat xArrowOffset = 0.0;
			CGFloat yArrowOffset = 0.0;
			CGPoint anchorPoint = CGPointZero;
            CGFloat shift = 0.0;
			
			switch (theArrowDirection) {
				case UIPopoverArrowDirectionUp:
					
					anchorPoint = CGPointMake(CGRectGetMidX(anchorRect), CGRectGetMaxY(anchorRect));
					
                    // Check if anchorPoint is under the displayArea (due to keyboard showing)
                    if (anchorPoint.y > CGRectGetMaxY(displayArea)) {
                        // Skip this test since we need ArrowDirectionDown in this case.
                        NSAssert(supportedArrowDirections & UIPopoverArrowDirectionDown, @"ArrowDirectionDown is needed but wasn't allowed");
                        break;
                    }
                    
					xArrowOffset = theSize.width / 2 - upArrowImage.size.width / 2;
					yArrowOffset = properties.topBgMargin - upArrowImage.size.height;
					
					theOffset = CGPointMake(anchorPoint.x - xArrowOffset - upArrowImage.size.width / 2, anchorPoint.y  - yArrowOffset);
					
                    // If going past the right bounds, shit left
                    if (theOffset.x + theSize.width > CGRectGetMaxX(displayArea)) {
                        shift = CGRectGetMaxX(displayArea) - (theOffset.x + theSize.width);
                        xArrowOffset -= shift;
                        theOffset.x += shift;
                    } 
                    // If going past the left bounds, shift right
					if (theOffset.x < CGRectGetMinX(displayArea)) {
                        shift = CGRectGetMinX(displayArea) - theOffset.x;
                        xArrowOffset -= shift;
                        theOffset.x += shift;
					}
                    // If still going past right, resize width
                    if (theOffset.x + theSize.width > CGRectGetMaxX(displayArea)) {
                        shift = theOffset.x + theSize.width - CGRectGetMaxX(displayArea);
                        theSize.width -= shift;
                    } 
                    // If going past the bottom bounds, resize height
                    if (theOffset.y + theSize.height > CGRectGetMaxY(displayArea)) {
                        shift = theOffset.y + theSize.height - CGRectGetMaxY(displayArea);
                        theSize.height -= shift;
                    }
                    
					//Cap the arrow offset
					xArrowOffset = MAX(xArrowOffset, properties.leftBgMargin + properties.arrowMargin);
					xArrowOffset = MIN(xArrowOffset, theSize.width - properties.rightBgMargin - properties.arrowMargin - upArrowImage.size.width);
					
					theArrowRect = CGRectMake(xArrowOffset, yArrowOffset, upArrowImage.size.width, upArrowImage.size.height);
                    theBgRect = CGRectMake(0, 0, theSize.width, theSize.height);
					
					break;
                    
                    
				case UIPopoverArrowDirectionDown:
					
					anchorPoint = CGPointMake(CGRectGetMidX(anchorRect), CGRectGetMinY(anchorRect));
					
                    // Check if anchorPoint is under the displayArea (due to keyboard showing)
                    if (anchorPoint.y > CGRectGetMaxY(displayArea)) {
                        // Shift the point to the visible area
                        anchorPoint.y = CGRectGetMaxY(displayArea);
                    }
                    
					xArrowOffset = theSize.width / 2 - downArrowImage.size.width / 2;
					yArrowOffset = theSize.height - properties.bottomBgMargin;
					
					theOffset = CGPointMake(anchorPoint.x - xArrowOffset - downArrowImage.size.width / 2, anchorPoint.y - yArrowOffset - downArrowImage.size.height);
					
					// If going past the right bounds, shit left
                    if (theOffset.x + theSize.width > CGRectGetMaxX(displayArea)) {
                        shift = CGRectGetMaxX(displayArea) - (theOffset.x + theSize.width);
                        xArrowOffset -= shift;
                        theOffset.x += shift;
                    } 
                    // If going past the left bounds, shift right
					if (theOffset.x < CGRectGetMinX(displayArea)) {
                        shift = CGRectGetMinX(displayArea) - theOffset.x;
                        xArrowOffset -= shift;
                        theOffset.x += shift;
					}

                    // If still going past right, resize width
                    if (theOffset.x + theSize.width > CGRectGetMaxX(displayArea)) {
                        shift =  theOffset.x + theSize.width - CGRectGetMaxX(displayArea);
                        theSize.width -= shift;
                    } 
                    // If going past the top bounds, resize height and shift offset
                    if (theOffset.y < CGRectGetMinY(displayArea)) {
                        shift = CGRectGetMinY(displayArea) - theOffset.y;
                        theSize.height -= shift;
                        theOffset.y += shift;
                        yArrowOffset -= shift;
                    }
					
					//Cap the arrow offset
					xArrowOffset = MAX(xArrowOffset, properties.leftBgMargin + properties.arrowMargin);
					xArrowOffset = MIN(xArrowOffset, theSize.width - properties.rightBgMargin - properties.arrowMargin - downArrowImage.size.width);
					
					theArrowRect = CGRectMake(xArrowOffset , yArrowOffset, downArrowImage.size.width, downArrowImage.size.height);
                    theBgRect = CGRectMake(0, 0, theSize.width, theSize.height);
					
					break;
                    
                    
				case UIPopoverArrowDirectionLeft:
					
					anchorPoint = CGPointMake(CGRectGetMaxX(anchorRect), CGRectGetMidY(anchorRect));
					
                    // Check if anchorPoint is under the displayArea (due to keyboard showing)
                    if (anchorPoint.y > CGRectGetMaxY(displayArea)) {
                        // Skip this test since we need ArrowDirectionDown in this case.
                        NSAssert(supportedArrowDirections & UIPopoverArrowDirectionDown, @"ArrowDirectionDown is needed but wasn't allowed");
                        break;
                    }
                    
					xArrowOffset = properties.leftBgMargin - leftArrowImage.size.width;
					yArrowOffset = theSize.height / 2  - leftArrowImage.size.height / 2;
					
					theOffset = CGPointMake(anchorPoint.x - xArrowOffset, anchorPoint.y - yArrowOffset - leftArrowImage.size.height / 2);                    
                    
                    // If going past the top bounds, shift down
                    if (theOffset.y < CGRectGetMinY(displayArea)) {
                        shift = CGRectGetMinY(displayArea) - theOffset.y;
                        theOffset.y += shift;
                        yArrowOffset -= shift;
                    }
                    // If going past the bottom bounds, shift up
                    if (theOffset.y + theSize.height > CGRectGetMaxY(displayArea)) {
                        shift = CGRectGetMaxY(displayArea) - (theOffset.y + theSize.height);
                        theOffset.y += shift;
                        yArrowOffset -= shift;
                    }
                    // If still going past the top bounds, shift down and resize
                    if (theOffset.y < CGRectGetMinY(displayArea)) {
                        shift = CGRectGetMinY(displayArea) - theOffset.y;
                        theOffset.y += shift;
                        yArrowOffset -= shift;
                        theSize.height -= shift;
                    }
                    // If going past the right bounds, resize width
                    if (theOffset.x + theSize.width > CGRectGetMaxX(displayArea)) {
                        shift = theOffset.x + theSize.width - CGRectGetMaxX(displayArea);
                        theSize.width -= shift;
                    } 
					
					//Cap the arrow offset
					yArrowOffset = MAX(yArrowOffset, properties.topBgMargin + properties.arrowMargin);
					yArrowOffset = MIN(yArrowOffset, theSize.height - properties.bottomBgMargin - properties.arrowMargin - leftArrowImage.size.height);
					
					theArrowRect = CGRectMake(xArrowOffset, yArrowOffset, leftArrowImage.size.width, leftArrowImage.size.height);
                    theBgRect = CGRectMake(0, 0, theSize.width, theSize.height);
					
					break;
                    
                    
				case UIPopoverArrowDirectionRight:
					
					anchorPoint = CGPointMake(CGRectGetMinX(anchorRect), CGRectGetMidY(anchorRect));
                    
                    // Check if anchorPoint is under the displayArea (due to keyboard showing)
                    if (anchorPoint.y > CGRectGetMaxY(displayArea)) {
                        // Skip this test since we need ArrowDirectionDown in this case.
                        NSAssert((supportedArrowDirections & UIPopoverArrowDirectionDown), @"ArrowDirectionDown is needed but wasn't allowed");
                        break;
                    }
                    
					xArrowOffset = theSize.width - properties.rightBgMargin;
					yArrowOffset = theSize.height / 2  - rightArrowImage.size.width / 2;
					
					theOffset = CGPointMake(anchorPoint.x - xArrowOffset - rightArrowImage.size.width, anchorPoint.y - yArrowOffset - rightArrowImage.size.height / 2);
                    
                    // If going past the top bounds, shift down
                    if (theOffset.y < CGRectGetMinY(displayArea)) {
                        shift = CGRectGetMinY(displayArea) - theOffset.y;
                        theOffset.y += shift;
                        yArrowOffset -= shift;
                    }
                    // If going past the bottom bounds, shift up
                    if (theOffset.y + theSize.height > CGRectGetMaxY(displayArea)) {
                        shift = CGRectGetMaxY(displayArea) - (theOffset.y + theSize.height);
                        theOffset.y += shift;
                        yArrowOffset -= shift;
                    }
                    // If still going past the top bounds, shift down and resize
                    if (theOffset.y < CGRectGetMinY(displayArea)) {
                        shift = CGRectGetMinY(displayArea) - theOffset.y;
                        theOffset.y += shift;
                        yArrowOffset -= shift;
                        theSize.height -= shift;
                    }
                    // If going past the left bounds, shift right and resize width
                    if (theOffset.x < CGRectGetMinX(displayArea)) {
                        shift = CGRectGetMinX(displayArea) - theOffset.x;
                        theOffset.x += shift;
                        xArrowOffset -= shift;
                        theSize.width -= shift;
                    } 
					
					//Cap the arrow offset
					yArrowOffset = MAX(yArrowOffset, properties.topBgMargin + properties.arrowMargin);
					yArrowOffset = MIN(yArrowOffset, theSize.height - properties.bottomBgMargin - properties.arrowMargin - rightArrowImage.size.height);
					
					theArrowRect = CGRectMake(xArrowOffset, yArrowOffset, rightArrowImage.size.width, rightArrowImage.size.height);
                    theBgRect = CGRectMake(0, 0, theSize.width, theSize.height);
					
					break;
			}
			
			CGFloat surface = fabsf(theBgRect.size.width) * fabsf(theBgRect.size.height);
            
			if (surface > biggestSurface) {
				biggestSurface = surface;
				offset = theOffset;
				arrowRect = theArrowRect;
				bgRect = theBgRect;
				arrowDirection = theArrowDirection;
			}
		}
		
		theArrowDirection <<= 1;
	}
	
	switch (arrowDirection) {
		case UIPopoverArrowDirectionUp:
			arrowImage = upArrowImage;
			break;
		case UIPopoverArrowDirectionDown:
			arrowImage = downArrowImage;
			break;
		case UIPopoverArrowDirectionLeft:
			arrowImage = leftArrowImage;
			break;
		case UIPopoverArrowDirectionRight:
			arrowImage = rightArrowImage;
			break;
	}

	NSAssert(!CGRectEqualToRect(bgRect, CGRectNull), @"bgRect is null");
	
}

@end
