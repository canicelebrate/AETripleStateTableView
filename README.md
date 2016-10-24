AETripleStateTableView
==================
Inspired by the project TextFieldValidator and most of logic code comes from there
AETripleStateTableView is a lightweight, customizable subclass of UITableView that supports triple states(loading, no data, normal) to meet the generic requirement that the UITableView need to consume data from external system(Web API, Web Service and etc.)


# AETripleStateTableView
A lightweight, customizable subclass of UITableView that supports triple states(loading, no data, normal). And it provides ability to customize it's UI elements using UIAppearance mechanism.

![AETripleStateTableView](https://github.com/canicelebrate/AETripleStateTableView/blob/master/Screenshot.png?raw=true)

## Setup
### Using [CocoaPods](http://cocoapods.org)
1. Add the pod `AETripleStateTableView` to your [Podfile](http://guides.cocoapods.org/using/the-podfile.html).

```ruby
pod 'AETripleStateTableView'
```

1. Run `pod install` from Terminal, then open your app's `.xcworkspace` file to launch Xcode.
2. Import the `AETripleStateTableView.h` umbrella header.
* Objective-C: `#import "AETripleStateTableView.h"`

## Utilize
1. Navigate to the UIViewController in the storyboard which contains the UITableView. Select the UITableView you want to implement tripe states on, then set its class to 'AETripleStateTableView'.
2. Add an outlet of that AETripleStateTableView in the relevant subclass of the UIViewControoler
3. Setup AETripleStateTableView's property 'NoDataView' or 'setNoDataCellIdentifier' for the no data state. This step is required if there is no UI appearance customation for 'NoDataView' before you initialize AETripleStateTableView.  Please see the sample code below for UI customization.

## Customizable UI
```objective-c
    //AETripleStateTableView UI Customization
    UILabel* lbl = [[UILabel alloc] init];
    lbl.translatesAutoresizingMaskIntoConstraints = NO;
    lbl.text = @"NO DATA";
    lbl.textAlignment = NSTextAlignmentCenter;
    [[AETripleStateTableView appearance] setNoDataView:lbl];
```

That's it - now go to design a TableView with AETripleStateTableView!
