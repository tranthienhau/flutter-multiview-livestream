# Screenshot / GIF regeneration

How the README screenshots and `screenshots/demo.gif` are produced. Real captures from a running app on the iOS Simulator, not mockups.

## How it works

- `integration_test/screenshot_test.dart` boots the app, waits for the 4 HLS streams to buffer, then navigates each key screen and calls `binding.convertFlutterSurfaceToImage()` + `binding.takeScreenshot('NN-name')`. Fixed `pump(Duration)` is used (not `pumpAndSettle`) because the video tiles animate continuously.
- `test_driver/integration_test.dart` uses `integrationDriver(onScreenshot:)` to write each PNG into `screenshots/`.

## Steps

```bash
# 1. Boot a simulator
xcrun simctl boot "iPhone 17 Pro"

# 2. Install deps
flutter pub get

# 3. Capture screenshots -> screenshots/01..04.png
flutter drive \
  --driver test_driver/integration_test.dart \
  --target integration_test/screenshot_test.dart \
  -d "iPhone 17 Pro"

# 4. Rebuild the demo gif from the captured PNGs
cd screenshots
ffmpeg -y -framerate 1 -pattern_type glob -i '0*.png' \
  -vf "scale=540:-1:flags=lanczos,split[s0][s1];[s0]palettegen=max_colors=128[p];[s1][p]paletteuse=dither=bayer" \
  -loop 0 demo.gif
```

A `Bad state: Cannot use "ref" after the widget was disposed` line at teardown is harmless - all screenshots are already written before the driver tears the widget tree down.
