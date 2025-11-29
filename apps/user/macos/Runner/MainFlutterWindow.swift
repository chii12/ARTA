import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    
    // Set minimum and initial window size for desktop
    self.minSize = NSSize(width: 1024, height: 768)
    self.setContentSize(NSSize(width: 1280, height: 800))
    self.setFrame(windowFrame, display: true)
    
    // Center the window on screen
    self.center()

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
