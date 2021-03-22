//
//  OpenQuicklyViewController.swift
//  OpenQuickly
//
//  Created by Luka Kerr on 25/2/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Cocoa

enum KeyCode {
  static let esc: UInt16 = 53
  static let enter: UInt16 = 36
  static let upArrow: UInt16 = 126
  static let downArrow: UInt16 = 125
  // keycodes for number 1-9
  static let numbers: [UInt16:Int] = [18:1,19:2,20:3,21:4,23:5,22:6,26:7,28:8,25:9]
}


class OpenQuicklyViewController: NSViewController, NSTextFieldDelegate {

  /// KeyCodes that shouldn't update the searchField
  let IGNORED_KEYCODES = [
    KeyCode.esc, KeyCode.enter,
    KeyCode.upArrow, KeyCode.downArrow
  ]
    
    let nc =  NotificationCenter.default

  /// The data used to display the matches
  private var matches: [Any]!

  /// Configuration options
  private var options: OpenQuicklyOptions!

  /// The currently selected match
  private var selected: Int?

  /// Various views
  private var clipView: NSClipView!
  private var stackView: NSStackView!
  private var scrollView: DisablableScrollView!
  private var searchField: NSTextField!
  private var matchesList: NSOutlineView!
  private var transparentView: NSVisualEffectView!

  /// The Open Quickly window controller instance for this view
  private var openQuicklyWindowController: OpenQuicklyWindowController? {
    return view.window?.windowController as? OpenQuicklyWindowController
  }

  init(options: OpenQuicklyOptions) {
    super.init(nibName: nil, bundle: nil)

    self.options = options
    self.matches = []
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  override func loadView() {
    let frame = NSRect(
      x: 0,
      y: 0,
      width: options.width,
      height: options.height
    )

    view = NSView()
    view.frame = frame
    view.wantsLayer = true
    view.layer?.cornerRadius = options.radius + 1
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setupSearchField()
    setupTransparentView()
    setupMatchesListView()
    setupScrollView()
    setupStackView()

    stackView.addArrangedSubview(searchField)
    stackView.addArrangedSubview(scrollView)
    transparentView.addSubview(stackView)
    view.addSubview(transparentView)

    setupConstraints()

    matchesList.doubleAction = #selector(itemSelected)

    NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: keyDown)
  }

  override func viewWillAppear() {
    searchField.stringValue = ""

    if !options.persistMatches {
      clearMatches()
    }

    view.window?.makeFirstResponder(searchField)
  }

  override var acceptsFirstResponder: Bool {
    return true
  }

  func keyDown(with event: NSEvent) -> NSEvent? {
    let keyCode = event.keyCode

    // When esc pressed, close the window
    if keyCode == KeyCode.esc {
      openQuicklyWindowController?.toggle()
      return nil
    }

    // When enter pressed, indicate that an item was selected
    if keyCode == KeyCode.enter {
      itemSelected()
      return nil
    }

    // When down arrow pressed, if there is a selection move it down
    if keyCode == KeyCode.downArrow {
      if let currentSelection = selected {
        if currentSelection == matchesList.numberOfRows - 1 {
            setSelected(at: 0)
        }
        else {
            setSelected(at: currentSelection + 1)
        }
      }
      return nil
    }

    // When uo arrow pressed, if there is a selection move it up
    if keyCode == KeyCode.upArrow {
      if let currentSelection = selected {
        if currentSelection == 0 {
            setSelected(at: matchesList.numberOfRows - 1)
        }
        else {
            setSelected(at: currentSelection - 1)
        }
      }
      return nil
    }
    
    // When cmd+number pressed, indicate that item was selected
    if KeyCode.numbers[keyCode] != nil  && event.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command {
        if (matchesList.numberOfRows >= KeyCode.numbers[keyCode]!) {
            setSelected(at: KeyCode.numbers[keyCode]! - 1)
          itemSelected()
        }
          return nil
    }

    return event
  }

  override func keyUp(with event: NSEvent) {
    if IGNORED_KEYCODES.contains(event.keyCode) {
      return
    }

    let value = searchField.stringValue

    matches = options.delegate?.valueWasEntered(value)
    reloadMatches()
  }

  @objc func itemSelected() {
    let selected = matchesList.item(atRow: matchesList.selectedRow) as Any

    if let delegate = options.delegate {
      delegate.itemWasSelected(selected: selected)
    }
    openQuicklyWindowController?.toggle()
  }

  // MARK: - UI management

  private func clearMatches() {
    matches = []
    reloadMatches()
  }

  private func reloadMatches() {
    matchesList.reloadData()
    updateViewSize()
    if matches.count > 0 {
      setSelected(at: 0)
    }
  }

  private func setSelected(at index: Int) {
    if index < 0 || index >= matches.count {
      return
    }
    selected = index
    let selectedIndex = IndexSet(integer: index)
    matchesList.scrollRowToVisible(index)
    matchesList.selectRowIndexes(selectedIndex, byExtendingSelection: false)
//    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//        self.addIndicatorSelected(selectedIndex: index)
//    }
  }

  private func updateViewSize() {
    let numMatches = matches.count > options.matchesShown
      ? options.matchesShown : matches.count

    let rowHeight = CGFloat(numMatches) * (options.rowHeight + 2)
    let newHeight = options.height + rowHeight

    let newSize = NSSize(width: options.width, height: newHeight)

    guard var frame = view.window?.frame else { return }

    frame.origin.y += frame.size.height;
    frame.origin.y -= newSize.height;
    frame.size = newSize

    view.setFrameSize(newSize)
    transparentView.setFrameSize(newSize)
    view.window?.setFrame(frame, display: true)
    view.window?.isOpaque = false

    stackView.spacing = matches.count > 0 ? 5.0 : 0.0
  }

    private func addIndicator(selectedIndex: Int) {
        let numMatches = matches.count > options.matchesShown
          ? options.matchesShown : matches.count
        if selected == 0 {
            for (index, rowindex) in Range(0...(numMatches-1)).enumerated() {
                let row = matchesList.view(atColumn: 0, row: rowindex, makeIfNecessary: true)
                if row != nil {
                    let text = (row?.subviews[2] ?? nil) as! NSTextField
                    text.stringValue = "⌘\(index + 1)"
                }
            }
            return
        }
        if selected == matches.count-1 {
            for (index, rowindex) in Range((selectedIndex-numMatches+1)...(selectedIndex)).enumerated() {
                let row = matchesList.view(atColumn: 0, row: rowindex, makeIfNecessary: true)
                if row != nil {
                    let text = (row?.subviews[2] ?? nil) as! NSTextField
                    text.stringValue = "⌘\(index + 1)"
                }
            }
            return
        }
        var iter = 0
        for idx in Range(matches.startIndex...(matches.endIndex-1)) {
                let rowRect = matchesList.rect(ofRow: Int(idx))
                if NSContainsRect(matchesList.visibleRect, rowRect) {
                    let row = matchesList.view(atColumn: 0, row: idx, makeIfNecessary: true)
                    if row != nil {
                        iter+=1
                        let text = (row?.subviews[2] ?? nil) as! NSTextField
                        text.stringValue = "⌘\(iter)"
                    }
                }
                else {
                    let row = matchesList.view(atColumn: 0, row: idx, makeIfNecessary: true)
                    if row != nil {
                        let text = (row?.subviews[2] ?? nil) as! NSTextField
                        text.stringValue = ""
                    }
                }
            }
        // addIndicatorSelected(index: index)
    }
    private func addIndicatorSelected(index: Int) {
        let row = matchesList.view(atColumn: 0, row: index, makeIfNecessary: true)
        if row != nil {
            let text = (row?.subviews[2] ?? nil) as! NSTextField
            text.stringValue = "↩"
        }
    }

  // MARK: - UI setup

  private func setupSearchField() {
    searchField = NSTextField()
    searchField.delegate = self
    searchField.alignment = .left
    searchField.isEditable = true
    searchField.isBezeled = false
    searchField.isSelectable = true
    searchField.font = options.font
    searchField.focusRingType = .none
    searchField.drawsBackground = false
    searchField.placeholderString = options.placeholder
  }

  private func setupTransparentView() {
    let frame = NSRect(
      x: 0,
      y: 0,
      width: options.width,
      height: options.height
    )

    transparentView = NSVisualEffectView()
    transparentView.frame = frame
    transparentView.state = .active
    transparentView.wantsLayer = true
    transparentView.blendingMode = .behindWindow
    transparentView.layer?.cornerRadius = options.radius
    transparentView.material = options.material
  }

  private func setupMatchesListView() {
    matchesList = NSOutlineView()
    matchesList.delegate = self
    matchesList.headerView = nil
    matchesList.wantsLayer = true
    matchesList.dataSource = self
    matchesList.selectionHighlightStyle = .sourceList

    let column = NSTableColumn()
    matchesList.addTableColumn(column)
  }

  private func setupScrollView() {
    scrollView = DisablableScrollView()
    scrollView.borderType = .noBorder
    scrollView.drawsBackground = false
    scrollView.autohidesScrollers = true
    scrollView.hasVerticalScroller = false
    scrollView.documentView = matchesList
    scrollView.verticalLineScroll = options.rowHeight
    scrollView.translatesAutoresizingMaskIntoConstraints = true
  }

  private func setupStackView() {
    stackView = NSStackView()
    stackView.spacing = 0.0
    stackView.orientation = .vertical
    stackView.distribution = .fillEqually
    stackView.edgeInsets = options.edgeInsets
    stackView.translatesAutoresizingMaskIntoConstraints = false
  }

  private func setupConstraints() {
    let stackViewConstraints = [
      stackView.topAnchor.constraint(equalTo: transparentView.topAnchor),
      stackView.bottomAnchor.constraint(equalTo: transparentView.bottomAnchor),
      stackView.leadingAnchor.constraint(equalTo: transparentView.leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: transparentView.trailingAnchor)
    ]

    NSLayoutConstraint.activate(stackViewConstraints)
  }

}

extension OpenQuicklyViewController: NSOutlineViewDataSource {

  /// Number of items in the matches list
  func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
    return matches.count
  }

  /// Items to be added to the matches list
  func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
    return matches[index]
  }

  /// Whether items in the matches list are expandable by an arrow
  func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
    return false
  }

  /// Height of each item in the matches list
  func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
    return options.rowHeight
  }

  /// When an item in the matches list is clicked on should it be selected
  func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
    return true
  }

  /// The NSTableRowView instance to be used
  func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
    return OpenQuicklyTableRowView(frame: NSZeroRect)
  }

  /// When an item is selected
  func outlineViewSelectionDidChange(_ notification: Notification) {
    selected = matchesList.selectedRow
  }

}

extension OpenQuicklyViewController: NSOutlineViewDelegate {

  /// The view for each item in the matches array
  func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
    return options.delegate?.openQuickly(item: item)
  }

}

@IBDesignable
@objc(BCLDisablableScrollView)
public class DisablableScrollView: NSScrollView {
    @IBInspectable
    @objc(enabled)
    public var isEnabled: Bool = true

    public override func scrollWheel(with event: NSEvent) {
        if isEnabled {
            super.scrollWheel(with: event)
        }
        else {
            nextResponder?.scrollWheel(with: event)
        }
    }
}
