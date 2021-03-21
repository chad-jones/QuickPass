//
//  ContentView.swift
//  QuickPass
//
//  Created by Chad Jones on 3/12/21.
//

import SwiftUI
import KeyboardShortcuts

struct ContentView: View {
    
    @ObservedObject var settingsStore: SettingsStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("QuickPass")
                            .font(Font.system(size: 18.0))
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 16.0)
                            .padding(.vertical, 12.0)
                            .frame(width: 360.0, alignment: .topLeading)
            Text("The slightly more awesome gopass UI for macOS")
                            .font(Font.system(size: 12.0))
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 16.0)
                            .padding(.bottom, 30.0)
                            .frame(width: 360.0, alignment: .topLeading)
            HStack {
                Text("QuickPass Hotkey:").font(Font.system(size: 12.0))
                Spacer()
                KeyboardShortcuts.Recorder(for: .toggleQuickPass)
                
            }
            .padding(.horizontal, 16.0)
            .padding(.bottom, 12)
            .frame(width: 360.0, alignment: .topLeading)
            HStack {
                Text("Persist window position:").font(Font.system(size: 12.0))
                Spacer()
                Toggle("", isOn: self.$settingsStore.persistPosition)
                
            }
            .padding(.horizontal, 16.0)
            .frame(width: 360.0, alignment: .topLeading)
            HStack {
                Text("Persist matches:").font(Font.system(size: 12.0))
                Spacer()
                Toggle("", isOn: self.$settingsStore.persistMatches)
                
            }
            .padding(.horizontal, 16.0)
            .padding(.bottom, 12.0)
            .frame(width: 360.0, alignment: .topLeading)
            Button(action: {
                NSApplication.shared.terminate(self)
            })
            {
                Text("Quit App")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .padding(.top, 20)
            .padding(.trailing, 16.0)
            .frame(width: 360.0, alignment: .trailing)
        }
        .padding(0)
        .padding(.bottom, 18)
        .frame(width: 360.0, alignment: .top)
    }
}
