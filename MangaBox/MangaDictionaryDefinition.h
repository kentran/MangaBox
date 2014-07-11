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
#define PARSE_MANGA_ERROR @"Unable to download manga. Please check if the URL is correct and the website is still running"

// Page Setting
#define SHOW_2_PAGES @"Show 2 pages"
#define SHOW_1_PAGE @"Show 1 page"
#define SETTING_2_PAGES 2
#define SETTING_1_PAGE 1

// Advanced Search
#define STATUS_SELECTED @"Yes"
#define STATUS_DESELECTED @"No"

#define STATUS_SELECTED_LABEL_BACKGROUND_COLOR UIColorFromRGB(0x648f00)
#define STATUS_SELECTED_BORDER_BACKGROUND_COLOR [UIColor whiteColor]
#define STATUS_DESELECTED_LABEL_BACKGROUND_COLOR UIColorFromRGB(0xfafafa)
#define STATUS_DESELECTED_BORDER_BACKGROUND_COLOR [UIColor lightGrayColor]

#define POPULAR_MANGA_URL @"http://mangafox.me/search.php?name_method=cw&name=&type=&author_method=cw&author=&artist_method=cw&artist=&genres%5BAction%5D=0&genres%5BAdult%5D=0&genres%5BAdventure%5D=0&genres%5BComedy%5D=0&genres%5BDoujinshi%5D=0&genres%5BDrama%5D=0&genres%5BEcchi%5D=0&genres%5BFantasy%5D=0&genres%5BGender+Bender%5D=0&genres%5BHarem%5D=0&genres%5BHistorical%5D=0&genres%5BHorror%5D=0&genres%5BJosei%5D=0&genres%5BMartial+Arts%5D=0&genres%5BMature%5D=0&genres%5BMecha%5D=0&genres%5BMystery%5D=0&genres%5BOne+Shot%5D=0&genres%5BPsychological%5D=0&genres%5BRomance%5D=0&genres%5BSchool+Life%5D=0&genres%5BSci-fi%5D=0&genres%5BSeinen%5D=0&genres%5BShoujo%5D=0&genres%5BShoujo+Ai%5D=0&genres%5BShounen%5D=0&genres%5BShounen+Ai%5D=0&genres%5BSlice+of+Life%5D=0&genres%5BSmut%5D=0&genres%5BSports%5D=0&genres%5BSupernatural%5D=0&genres%5BTragedy%5D=0&genres%5BWebtoons%5D=0&genres%5BYaoi%5D=0&genres%5BYuri%5D=0&released_method=eq&released=&rating_method=eq&rating=&is_completed=&advopts=1&sort=views&order=za"

#endif
