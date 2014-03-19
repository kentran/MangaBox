//
//  MangaCDTVC.m
//  MangaBox
//
//  Created by Ken Tran on 9/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "MangasCDTVC.h"
#import "Manga+Create.h"
#import "Chapter+Create.h"
#import "MangaDictionaryDefinition.h"
#import "MangafoxFetcher.h"
#import "ChaptersByMangaCDTVC.h"
#import "CoverImage.h"

@interface MangasCDTVC ()
@property (strong, nonatomic) NSArray *addedChapterDictionaryList;
@end

@implementation MangasCDTVC

- (void)setAddedMangaDictionary:(NSDictionary *)addedMangaDictionary\
{
    _addedMangaDictionary = addedMangaDictionary;
    if (_addedMangaDictionary)
        [self storeNewManga:_addedMangaDictionary];
}

- (void)setAddedChapterDictionaryList:(NSArray *)addedChapterDictionaryList
{
    _addedChapterDictionaryList = addedChapterDictionaryList;
    if (_addedChapterDictionaryList)
        [self loadNewChapterList:_addedChapterDictionaryList ofManga:[Manga mangaWithInfo:self.addedMangaDictionary inManagedObjectContext:self.managedObjectContext]];
}

- (void)storeNewManga:(NSDictionary *)newManga
{
    [Manga mangaWithInfo:newManga inManagedObjectContext:self.managedObjectContext];
    [self fetchChapterList];
    [self.tableView reloadData];
}

- (void)loadNewChapterList:(NSArray *)newChapterList
                  ofManga:(Manga *)manga
{
    [Chapter loadChaptersFromArray:self.addedChapterDictionaryList
                           ofManga:manga
          intoManagedObjectContext:self.managedObjectContext];
    [self.managedObjectContext save:NULL];
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Manga"];
    request.predicate = nil;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"created"
                                                              ascending:NO
                                                               selector:@selector(compare:)]];
    

    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Manga Collection Cell"];
    
    Manga *manga = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = manga.title;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d chapters", [manga.chapters count]];
    cell.imageView.image = [UIImage imageWithData:manga.cover.imageData];
    
    return cell;
}

- (void)fetchChapterList
{
    if ([self.addedMangaDictionary objectForKey:MANGA_URL]) {
        NSURL *url = [NSURL URLWithString:[self.addedMangaDictionary objectForKey:MANGA_URL]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
            completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {
                if (!error) {
                    if ([request.URL isEqual:url]) {
                        NSString *urlString = [request.URL absoluteString];
                        NSData *htmlData = [NSData dataWithContentsOfURL:localfile];
                        
                        NSArray *chapterList;
                        if ([urlString rangeOfString:@"mangafox.me"].location != NSNotFound) {
                            chapterList = [MangafoxFetcher parseChapterList:htmlData];
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.addedChapterDictionaryList = chapterList;
                        });
                    }
                }
            }];
        [task resume];
    }
}

#pragma mark - Navigation

- (void)prepareViewController:(id)vc forSegue:(NSString *)segueIdentifer fromIndexPath:(NSIndexPath *)indexPath
{
    Manga *manga = [self.fetchedResultsController objectAtIndexPath:indexPath];
    // note that we don't check the segue identifier here
    // probably fine ... hard to imagine any other way this class would segue to PhotosByPhotographerCDTVC
    if ([vc isKindOfClass:[ChaptersByMangaCDTVC class]]) {
        ChaptersByMangaCDTVC *clbmcdtvc = (ChaptersByMangaCDTVC *)vc;
        clbmcdtvc.title = manga.title;
        clbmcdtvc.manga = manga;
    }
}

// boilerplate
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender];
    }
    [self prepareViewController:segue.destinationViewController
                       forSegue:segue.identifier
                  fromIndexPath:indexPath];
}

// boilerplate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id detailvc = [self.splitViewController.viewControllers lastObject];
    if ([detailvc isKindOfClass:[UINavigationController class]]) {
        detailvc = [((UINavigationController *)detailvc).viewControllers firstObject];
        [self prepareViewController:detailvc
                           forSegue:nil
                      fromIndexPath:indexPath];
    }
}

@end
