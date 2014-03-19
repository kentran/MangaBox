//
//  Chapter+Download.h
//  MangaBox
//
//  Created by Ken Tran on 18/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "Chapter.h"

@interface Chapter (Download)

+ (void)startDownloadingChapterPages:(Chapter *)chapter;

@end
