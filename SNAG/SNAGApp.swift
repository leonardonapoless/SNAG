import SwiftUI

@main
struct SNAGApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    NSWindow.allowsAutomaticWindowTabbing = false
            }
        }
        .windowStyle(.hiddenTitleBar)
    }
}
