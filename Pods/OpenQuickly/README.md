# OpenQuickly

[![Swift 5](https://img.shields.io/badge/swift-5-orange.svg?style=flat)](https://github.com/apple/swift)
[![Platform](http://img.shields.io/badge/platform-macOS-red.svg?style=flat)](https://developer.apple.com/macos/)
[![Github](http://img.shields.io/badge/github-lukakerr-green.svg?style=flat)](https://github.com/lukakerr)

A custom 'open quickly' window that imitates macOS' Spotlight, written in Swift.

### Installation

#### CocoaPods

```ruby
pod 'OpenQuickly', :git => 'https://github.com/lukakerr/OpenQuickly.git'
```

### Usage

A demo can be found at [OpenQuickly Demo](./OpenQuickly%20Demo). Everything outlined below
can be found in the [OpenQuickly Demo ViewController](./OpenQuickly%20Demo/ViewController.swift).

Most of the functionality is provided already, but some options can be implemented to control the look and feel of the OpenQuickly dialog.

#### Options

Options include:

- Font used
- Radius of window
- Width and height of window
- Max number of matches shown
- Height of each matches row
- Placeholder text
- Whether to persist the window position
- Padding (i.e. edge insets)
- Material (i.e. theme/window appearance)

If there are any options you think are missing, please raise an issue.

#### Delegate

You must set your `OpenQuicklyOptions` instance's delegate to a class that conforms to `OpenQuicklyDelegate`.

This allows you to get when an item was selected, return an array of matches when a value is
typed into the search field, and provide your own custom view to be used as the view for each
row in the matches list.

### Screenshots

<p align="center">
  <img src="https://i.imgur.com/PLCRasq.png" width="400">
  <img src="https://i.imgur.com/SPOwsbN.png" width="400">
</p>

<br>

<p align="center">
  <img src="https://i.imgur.com/SVMAjEJ.png" width="600">
</p>
