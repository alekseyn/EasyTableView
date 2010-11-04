//
//  NSIndexPath+Same.m
//  FloatingTable
//
//  Created by Aleksey Novicov on 6/4/10.
//  Copyright 2010 Yodel Code LLC. All rights reserved.
//

#import "NSIndexPath+Same.h"


@implementation NSIndexPath (Same)

// This makes an extra for nil

- (BOOL)isSameAs:(NSIndexPath *)indexPath {
	if (indexPath == nil)
		return NO;
	
	return ([self compare:indexPath] == NSOrderedSame);
}


@end
