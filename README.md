# My Custom Swift Splash Screen

A beautiful and adaptive splash screen plugin for iOS applications that automatically adjusts to different device sizes and orientations.

## Features

✨ **Beautiful Animations** - Smooth, eye-catching splash screen animations  
📱 **Device Adaptive** - Automatically adapts to all iPhone and iPad screen sizes  
🎨 **Customizable** - Easy to customize colors, animations, and content  
⚡ **Lightweight** - Minimal performance impact on app launch  
🔧 **Easy Integration** - Simple setup with just a few lines of code  

## Requirements

- iOS 17.0+
- Swift 6.1+
- Xcode 16.0+

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/my_cus_swift.git", from: "1.0.0")
]
```

Or add it directly in Xcode:
1. Go to File → Add Package Dependencies
2. Enter the repository URL
3. Select the version and add to your target

## Usage

```swift
import my_cus_swift
import SwiftUI

struct ContentView: View {
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            if showSplash {
                CustomSplashView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation {
                                showSplash = false
                            }
                        }
                    }
            } else {
                MainAppView()
            }
        }
    }
}
```

## Customization

The splash screen automatically adapts to:
- All iPhone screen sizes (iPhone SE to iPhone 15 Pro Max)
- All iPad screen sizes
- Portrait and landscape orientations
- Different safe area configurations
- Dynamic Type accessibility settings

## Configuration Options

```swift
CustomSplashView(
    animationDuration: 1.5,
    backgroundColor: .black,
    accentColor: .blue,
    logoScale: 1.2
)
```

## License

MIT License - see LICENSE file for details.

## Contributing

Pull requests are welcome! Please read our contributing guidelines before submitting.