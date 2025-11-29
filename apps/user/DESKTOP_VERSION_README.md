# Desktop Version - ARTA User Application

## Overview
I've created a desktop-optimized version of your ARTA User application that provides an enhanced experience for Windows, macOS, and Linux platforms.

## What's New

### 1. Desktop-Optimized Landing Page (`landing_page_desktop.dart`)
- **Responsive Layout**: Automatically adjusts based on screen width
- **Wide Screen Layout (>1200px)**: 
  - Two-column layout with information on the left and agreement card on the right
  - Better use of horizontal space
  - Larger fonts and improved spacing
- **Medium Screen Layout (900-1200px)**:
  - Centered single-column layout
  - Optimized for tablets and smaller desktop displays
- **Enhanced Typography**: Larger, more readable fonts for desktop viewing
- **Improved Card Design**: 
  - Larger agreement card (500px wide on wide screens)
  - Better padding and spacing
  - Taller content area (300px)

### 2. Smart Platform Detection (`main.dart`)
The app automatically detects the platform and screen size:
- Desktop platforms (Windows/macOS/Linux): Uses desktop layout
- Wide screens (>900px): Uses desktop layout even on web
- Mobile/narrow screens: Uses original mobile layout

### 3. Window Configuration

#### Windows (`windows/runner/`)
- Initial size: 1280x720
- Minimum size: 1024x768
- Prevents users from making the window too small

#### macOS (`macos/Runner/MainFlutterWindow.swift`)
- Initial size: 1280x800
- Minimum size: 1024x768
- Window automatically centered on screen

## Project Structure
```
lib/
├── main.dart                    # Entry point with platform detection
├── landing_page.dart            # Original mobile-optimized layout
├── landing_page_desktop.dart    # New desktop-optimized layout
├── survey_form.dart             # Survey form (works on all platforms)
└── cc_pages.dart                # CC pages
```

## How to Run

### Windows
```powershell
# First, enable Developer Mode to support symlinks:
# 1. Press Win + I to open Settings
# 2. Go to "Update & Security" > "For developers"
# 3. Turn on "Developer Mode"

# Then run:
flutter run -d windows
```

### macOS
```bash
flutter run -d macos
```

### Linux
```bash
flutter run -d linux
```

## Features by Screen Size

### Wide Desktop (>1200px)
- Side-by-side layout
- Information panel on left
- Agreement card on right (500px wide)
- Optimal for large monitors

### Medium Desktop (900-1200px)
- Centered vertical layout
- Max width constrained to 800px
- Good for laptops and medium displays

### Mobile/Tablet (<900px)
- Original mobile layout
- Optimized for touch interaction
- Perfect for phones and small tablets

## Desktop-Specific Enhancements

1. **Better Typography**
   - Larger header (48px vs 34px)
   - Increased body text (15px vs 13px)
   - Better line height for readability

2. **Improved Spacing**
   - More generous padding (8% horizontal vs 4%)
   - Larger vertical spacing between elements
   - Better visual hierarchy

3. **Enhanced Card Design**
   - Larger elevation (16 vs 12)
   - Bigger border radius (16px vs 12px)
   - Taller content area for agreement text
   - Larger button (50px vs 44px height)

4. **Window Management**
   - Minimum window sizes prevent cramped UI
   - Initial sizes optimized for desktop viewing
   - macOS windows automatically centered

## Testing the Desktop Version

To see different layouts, resize your window:
- **>1200px width**: Two-column layout
- **900-1200px width**: Single column, centered
- **<900px width**: Mobile layout

## Troubleshooting

### Windows Symlink Error
If you see "Building with plugins requires symlink support":
1. Run `start ms-settings:developers` in PowerShell
2. Enable "Developer Mode"
3. Restart VS Code/Terminal
4. Try running again

### Build Errors
```powershell
# Clean the build and try again
flutter clean
flutter pub get
flutter run -d windows
```

### Font Loading Issues
If Google Fonts don't load:
- Ensure internet connection (fonts are downloaded)
- Or pre-download fonts for offline use

## Next Steps

You can further customize the desktop version by:
1. Adding keyboard shortcuts (Ctrl+N for next, etc.)
2. Implementing desktop-specific navigation (side panels, tabs)
3. Adding file picker for desktop file uploads
4. Creating desktop-specific menus (File, Edit, View)
5. Adding window state persistence (remember size/position)

## Notes

- The original mobile layout (`landing_page.dart`) is preserved and unchanged
- The survey form already works well on desktop, so no separate version was needed
- The app automatically chooses the best layout for the current platform and screen size
- All features from the mobile version are available in the desktop version
