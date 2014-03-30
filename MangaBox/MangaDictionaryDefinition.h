//
//  MangaDictionaryDefinition.h
//  MangaBox
//
//  Created by Ken Tran on 8/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#ifndef MangaBox_MangaDictionaryDefinition_h
#define MangaBox_MangaDictionaryDefinition_h

#define MANGA_UNIQUE @"unique"
#define MANGA_TITLE @"title"
#define MANGA_URL @"url"
#define MANGA_AUTHOR @"author"
#define MANGA_ARTIST @"artist"
#define MANGA_GENRES @"genres"
#define MANGA_CHAPTERS @"chaptersCount"
#define MANGA_RANK @"rank"
#define MANGA_STATUS @"status"
#define MANGA_SOURCE @"source"
#define MANGA_COMPLETION_STATUS @"completionStatus"

#define MANGA_COVER_URL @"coverURL"
#define MANGA_COVER_DATA @"coverData"

#define MANGA_SUMMARY @"summary"
#define MANGA_VIEWS @"views"
#define MANGA_RATING @"rating"
#define MANGA_RELEASED @"released"

#define CHAPTER_NAME @"ChapterName"
#define CHAPTER_URL @"url"

// Page dictionary
#define PAGE_URL @"url"
#define PAGE_IMAGE_URL @"imageURL"
#define PAGE_IMAGE_DATA @"imageData"
#define NEXT_PAGE_TO_PARSE @"nextPageToParse"
#define PAGES_COUNT @"pagesCount"

// Chapter download status
#define CHAPTER_DOWNLOADING @"downloading"
#define CHAPTER_DOWNLOADED @"downloaded"
#define CHAPTER_STOPPED_DOWNLOADING @"stopDownloading"
#define CHAPTER_CLEARED @"cleared"
#define CHAPTER_NEED_DOWNLOAD @"needDownload"

// Chapter download description
#define CHAPTER_HTML_FETCH @"chapterHtmlFetch"
#define CHAPTER_IMAGE_FETCH @"chapterImageFetch"

#define DOWNLOAD_ERROR @"Error downloading pages. Pages may not be available at the moment. Please try again later"

// Page Setting
#define SHOW_2_PAGES @"Show 2 pages"
#define SHOW_1_PAGE @"Show 1 page"
#define SETTING_2_PAGES 2
#define SETTING_1_PAGE 1

#endif
