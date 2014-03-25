//
//  Manga+Download.h
//  MangaBox
//
//  Created by Ken Tran on 25/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "Manga.h"

@interface Manga (Download)

- (void)startDownloadingAllChapters;
- (void)stopDownloadingAllChapters;

@end
