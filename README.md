DCScrollView [![Build Status](https://travis-ci.org/hirohisa/DCScrollView.png?branch=master)](https://travis-ci.org/hirohisa/DCScrollView)
==================

DCScrollView is an extension of UIScrollView that scrolling through the body, the title scrolls with a delay like Etsy app for iOS.

![screenshot](https://raw.github.com/hirohisa/DCScrollView/master/DCScrollView Example/screenshot1.png)


Usage
----------

### Set Delegate, DataSource

DCScrollView uses a simple methodology. It defines a delegate and a data source, its client implement.
DCScrollViewDelegate and DCScrollViewDataSource are like UITableViewDelegate and UITableViewDatasource.

```objc


@protocol DCScrollViewDataSource <NSObject>

@required

- (NSInteger)numberOfCellsInDCScrollView:(DCScrollView *)scrollView;
- (DCScrollViewCell *)dcscrollView:(DCScrollView *)scrollView cellAtIndex:(NSInteger)index;

@optional

- (NSString *)titleOfDCScrollViewCellAtIndex:(NSInteger)index;
- (DCScrollViewNavigationViewCell *)dcscrollView:(DCScrollView *)scrollView navigationViewCellAtIndex:(NSInteger)index;

@end

@protocol DCScrollViewDelegate <NSObject>

@optional

- (CGSize)sizeOfDCScrollViewNavigationViewCell;
- (void)dcscrollViewDidScroll:(DCScrollView *)scrollView didChangeVisibleCell:(DCScrollViewCell *)cell atIndex:(NSInteger)index;

@end

```

#### Example

```objc


- (void)viewDidLoad
{
    [super viewDidLoad];
    DCScrollView *scrollView = [[DCScrollView alloc]initWithFrame:self.view.bounds];
    scrollView.dataSource = self;
    scrollView.delegate = self;
}

- (NSInteger)numberOfCellsInDCScrollView:(DCScrollView *)scrollView
{
    return 10;
}

- (DCScrollViewCell *)dcscrollView:(DCScrollView *)scrollView cellAtIndex:(NSInteger)index
{
    NSString *identifier = @"Cell";
    DCScrollViewCell *cell = [scrollView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell  = [[DCScrollViewCell alloc] initWithReuseIdentifier:identifier];
    }

    return cell;
}

- (NSString *)titleOfDCScrollViewCellAtIndex:(NSInteger)index
{
    return @"title";
}

```


### Reload

Reset cells and redisplays visible cells. Current page keep visible after reloading.

```objc
- (void)reloadData;
```

### Remove Cache

If UIViewController received memory warnings, control to clear the memory that DCScrollView has.

```objc
- (void)clearData;
```


Features
----------

#### Deprecate

```objc
- (void)setFont:(UIFont *)font textColor:(UIColor *)textColor highlightedTextColor:(UIColor *)highlightedTextColor
```

## License

DCScrollView is available under the MIT license.
