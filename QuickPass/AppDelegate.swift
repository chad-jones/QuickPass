//
//  AppDelegate.swift
//  QuickPass
//
//  Created by Chad Jones on 3/12/21.
//

import Cocoa
import OpenQuickly
import SwiftUI
import KeyboardShortcuts

struct GoPassEntry {
    var name: String
    var short: String
    var icon: String
}

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarItem: NSStatusItem!
    var popover = NSPopover.init()
    var statusBar: StatusBarController?
    var settingsStore = SettingsStore()
    private var openQuicklyWindowController: OpenQuicklyWindowController!
    private var searchPhrase: String!
    private var gopassEntries: Array<GoPassEntry> = []
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        self.openQuicklyWindowController = OpenQuicklyWindowController(options: self.openQuicklyOptions())
        
        // Create the SwiftUI view that provides the contents
        let contentView = ContentView(settingsStore: settingsStore)
        
        // Set the SwiftUI's ContentView to the Popover's ContentViewController
        popover.contentViewController = MainViewController()
        popover.contentSize = NSSize(width: 360, height: 0)
        popover.contentViewController?.view = NSHostingView(rootView: contentView)
        
        // Create the Status Bar Item with the Popover
        statusBar = StatusBarController.init(popover)
        
        KeyboardShortcuts.onKeyUp(for: .toggleQuickPass) { [self] in
            DispatchQueue.global(qos: .background).async {
                self.loadPasswords()
            }
            self.openQuicklyWindowController.toggle()
        }
    }
    
    func openQuicklyOptions() -> OpenQuicklyOptions {
        let openQuicklyOptions = OpenQuicklyOptions()
        openQuicklyOptions.width = 600
        openQuicklyOptions.rowHeight = 60
        openQuicklyOptions.matchesShown = 9
        openQuicklyOptions.persistMatches = userDefaults.bool(forKey: "persistMatches")
        openQuicklyOptions.font = NSFont.systemFont(ofSize: 36, weight: .light)
        openQuicklyOptions.height = 64
        openQuicklyOptions.radius = 2
        openQuicklyOptions.material = .popover
        openQuicklyOptions.delegate = self
        openQuicklyOptions.persistPosition = userDefaults.bool(forKey: "persistPosition")
        openQuicklyOptions.placeholder = "Search gopass..."
        return openQuicklyOptions
    }
    
    func loadPasswords() {
        let task = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        var environment =  ProcessInfo.processInfo.environment
        environment["PATH"] = "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:/Users/$USER/bin"
        task.environment = environment
        task.launchPath = "/usr/bin/env"
        task.arguments = ["gopass", "ls", "-f"]
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        do {
            try task.run()
        } catch {
            print(error.localizedDescription, error)
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            if !errorData.isEmpty {
                let error = String(decoding: errorData, as: UTF8.self)
                print(error)
            }
            return
        }
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        if !errorData.isEmpty {
            let error = String(decoding: errorData, as: UTF8.self)
            print(error)
        }
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(decoding: outputData, as: UTF8.self)
        let entries = output.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")
        var gpArray: Array<GoPassEntry> = []
        entries.forEach {
            let pass = $0
            let range = NSRange(location: 0, length: pass.utf16.count)
            let regex = try! NSRegularExpression(pattern: "[^/]+$")
            let results = regex.firstMatch(in: pass, options: [], range: range)
            let short = results.map {
                String(pass[Range($0.range, in: pass)!])
            }
            let icon = iconMap.first(where: {pass.lowercased().contains($0.key)})?.value ?? "\u{fcf3}"
            let entry = GoPassEntry (
                name: pass,
                short: short ?? "",
                icon: icon
            )
            gpArray.append(entry)
        }
        self.gopassEntries = gpArray
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @objc private func quitClicked() {
        NSApp.terminate(self)
    }
    
}

extension AppDelegate: OpenQuicklyDelegate {
    
    func openQuickly(item: Any) -> NSView? {
        guard let pass = item as? GoPassEntry else { return nil }
        
        let view = NSStackView()
        
        // let imageView = NSImageView(image: pass.image)
        let icon = NSTextField()
        
        icon.isEditable = false
        icon.isBezeled = false
        icon.isSelectable = false
        icon.focusRingType = .none
        icon.drawsBackground = false
        icon.stringValue = pass.icon
        icon.font = NSFont(name: "NotoSansDisplay Nerd Font", size: 28)
        
        let title = NSTextField()
        
        title.isEditable = false
        title.isBezeled = false
        title.isSelectable = false
        title.focusRingType = .none
        title.drawsBackground = false
        title.font = NSFont.systemFont(ofSize: 12)
        title.stringValue = pass.name
        
        let subtitle = NSTextField()
        
        subtitle.isEditable = false
        subtitle.isBezeled = false
        subtitle.isSelectable = false
        subtitle.focusRingType = .none
        subtitle.drawsBackground = false
        subtitle.stringValue = pass.short
        subtitle.font = NSFont.systemFont(ofSize: 16)
        
        let text = NSStackView()
        text.orientation = .vertical
        text.spacing = 2.0
        text.alignment = .left
        text.widthAnchor.constraint(equalToConstant: self.openQuicklyOptions().width * 0.80).isActive = true
        text.addArrangedSubview(title)
        text.addArrangedSubview(subtitle)
        
        let indicator = NSTextField()
        
        indicator.isEditable = false
        indicator.isBezeled = false
        indicator.isSelectable = false
        indicator.focusRingType = .none
        indicator.drawsBackground = false
        indicator.stringValue = ""
        indicator.font = NSFont.systemFont(ofSize: 14)
        indicator.tag = 69
        
        view.addArrangedSubview(icon)
        view.addArrangedSubview(text)
        view.addArrangedSubview(indicator)
        
        return view
    }
    
    func valueWasEntered(_ value: String) -> [Any] {
        let matches = gopassEntries.filter {
            $0.name.lowercased().contains(value.lowercased())
        }
        
        return matches
    }
    
    func itemWasSelected(selected item: Any) {
        guard let pass = item as? GoPassEntry else { return }
        
        DispatchQueue.global(qos: .background).async {
            self.copyPassword(selected: pass)
        }
        
    }
    
    func setPersistMatchesOption(option: Bool) {
        self.openQuicklyWindowController.options.persistMatches = option
    }
    
    func setPersistPositionOption(option: Bool) {
        self.openQuicklyWindowController.options.persistPosition = option
        self.openQuicklyWindowController = OpenQuicklyWindowController(options: self.openQuicklyOptions())
    }
    
    func windowDidClose() {
        // print("Window did close")
    }
    
    func copyPassword(selected item: Any) {
        guard let item = item as? GoPassEntry else { return }
        let task = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        var environment =  ProcessInfo.processInfo.environment
        environment["PATH"] = "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:/Users/$USER/bin"
        task.environment = environment
        task.launchPath = "/usr/bin/env"
        task.arguments = ["gopass", "-c", "\(item.name)"]
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        do {
            try task.run()
        } catch {
            print(error.localizedDescription, error)
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            if !errorData.isEmpty {
                let error = String(decoding: errorData, as: UTF8.self)
                notify(title: "Error copying password for \(item.short)", informativeText: error)
                print ("notification generated for \(error)");
            }
            return
        }
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        if !errorData.isEmpty {
            let error = String(decoding: errorData, as: UTF8.self)
            notify(title: "Error copying password for \(item.short)", informativeText: error)
            return
        }
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(decoding: outputData, as: UTF8.self)
        // password copy notification
        notify(title: "gopass - clipboard", informativeText: output)
        
    }
    
    func notify(title: String, informativeText: String) {
        let notification = NSUserNotification()
        notification.identifier = UUID.init().uuidString
        notification.title = title;
        notification.informativeText = informativeText
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.delegate = self
        NSUserNotificationCenter.default.deliver(notification)
    }
}

extension AppDelegate: NSUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
}
