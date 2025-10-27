# BookMyDoc Android App Setup Guide

This guide will help you set up and run the BookMyDoc Android app using Hotwire Native.

## Quick Start

### 1. Install Android Studio

```bash
# Download from: https://developer.android.com/studio
# Or on Ubuntu/Debian:
sudo snap install android-studio --classic
```

### 2. Open the Project

1. Launch Android Studio
2. Click "Open" → Navigate to `seva_care/android-app`
3. Wait for Gradle sync (first time takes 5-10 minutes)
4. If Gradle sync fails, click "Sync Project with Gradle Files" button in toolbar

**Note**: The Android app must be built using Android Studio, which includes the required Java Development Kit (JDK 17) and Android SDK. Command-line builds require separate JDK installation.

### 3. Configure Server URL

The app needs to connect to your Rails server. Edit the URL in:

**File**: `android-app/app/src/main/java/com/bookmydoc/app/MainActivity.kt`

```kotlin
companion object {
    // Choose the appropriate URL for your setup:

    // For Android Emulator (default)
    const val BASE_URL = "http://10.0.2.2:7000"

    // For physical device on same WiFi
    // const val BASE_URL = "http://YOUR_COMPUTER_IP:7000"

    // For production
    // const val BASE_URL = "https://your-domain.com"
}
```

**Finding your computer's IP**:
```bash
# On Linux/Mac
ifconfig | grep "inet " | grep -v 127.0.0.1

# On Windows
ipconfig | findstr IPv4
```

### 4. Start the Rails Server

```bash
# Make sure Docker is running
docker compose up

# Server should be accessible at http://localhost:7000
```

**Important**: For physical device testing, update `docker-compose.yml`:

```yaml
services:
  web:
    ports:
      - "0.0.0.0:7000:7000"  # Expose on all interfaces
```

### 5. Run the App

**Option A: Using Android Emulator**

1. In Android Studio: Tools → Device Manager
2. Create a new virtual device (Pixel 6, API 34 recommended)
3. Click the green "Run" button
4. Select your emulator

**Option B: Using Physical Device**

1. Enable Developer Options on your Android device:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
   - Go back to Settings → Developer Options
   - Enable "USB Debugging"

2. Connect device via USB
3. Click "Run" in Android Studio
4. Select your device

## Features

### ✅ What Works Out of the Box

- Full Rails app wrapped in native Android
- Native navigation with smooth transitions
- Pull-to-refresh on all pages
- Back button navigation
- Hardware back button support
- Session persistence
- Automatic authentication handling

### 🎯 Native Features Implemented

**QR Code Scanner**:
```kotlin
// Call from JavaScript
NativeBridge.scanQRCode()
```

**Toast Messages**:
```kotlin
NativeBridge.showToast("Hello!")
```

**Device Vibration**:
```kotlin
NativeBridge.vibrate(100)  // milliseconds
```

**Share Dialog**:
```kotlin
NativeBridge.shareText("Check this out!", "Share")
```

## Integrating with Rails App

### Add Native Bridge Detection

In your Rails views, detect if running in native app:

```erb
<% if request.user_agent&.include?("Turbo Native") %>
  <!-- Native app specific content -->
  <button onclick="NativeBridge.scanQRCode()">
    Scan QR Code
  </button>
<% else %>
  <!-- Web only content -->
<% end %>
```

### Add Native Helpers

Create `app/helpers/native_helper.rb`:

```ruby
module NativeHelper
  def native_app?
    request.user_agent&.include?("Turbo Native")
  end

  def native_bridge_available?
    native_app?
  end
end
```

### Add JavaScript Helpers

In `app/javascript/application.js`:

```javascript
// Check if running in native app
export const isNativeApp = () => {
  return typeof window.NativeBridge !== 'undefined'
}

// Safe native bridge calls
export const nativeCall = (method, ...args) => {
  if (isNativeApp() && typeof window.NativeBridge[method] === 'function') {
    window.NativeBridge[method](...args)
    return true
  }
  return false
}

// Usage examples
document.addEventListener('DOMContentLoaded', () => {
  // Show toast when appointment booked
  const bookingButton = document.getElementById('book-appointment')
  if (bookingButton) {
    bookingButton.addEventListener('click', () => {
      nativeCall('showToast', 'Appointment booked successfully!')
      nativeCall('vibrate', 50)
    })
  }

  // QR scan button
  const qrButton = document.getElementById('scan-qr')
  if (qrButton && isNativeApp()) {
    qrButton.style.display = 'block'
    qrButton.addEventListener('click', () => {
      nativeCall('scanQRCode')
    })
  }
})
```

### Enhanced QR Code Page

Update `app/views/doctors/qr_codes/show.html.erb`:

```erb
<div class="qr-code-container">
  <%= image_tag @qr_code_url, class: "qr-code" %>

  <% if native_app? %>
    <button onclick="NativeBridge.shareText('<%= doctor_url(@doctor) %>', 'Share Doctor Profile')"
            class="btn btn-primary mt-4">
      Share Profile
    </button>
  <% else %>
    <!-- Web share fallback -->
  <% end %>
</div>
```

## Building APK

### Debug Build (for testing)

```bash
cd android-app
./gradlew assembleDebug

# APK location:
# android-app/app/build/outputs/apk/debug/app-debug.apk
```

### Release Build (for production)

1. **Create signing key** (first time only):

```bash
keytool -genkey -v -keystore bookmydoc-release-key.keystore \
  -alias bookmydoc \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

2. **Create keystore properties**:

Create `android-app/keystore.properties`:

```properties
storePassword=YourKeystorePassword
keyPassword=YourKeyPassword
keyAlias=bookmydoc
storeFile=../bookmydoc-release-key.keystore
```

3. **Update app/build.gradle**:

```gradle
android {
    signingConfigs {
        release {
            def keystorePropertiesFile = rootProject.file("keystore.properties")
            def keystoreProperties = new Properties()
            keystoreProperties.load(new FileInputStream(keystorePropertiesFile))

            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

4. **Build release APK**:

```bash
./gradlew assembleRelease

# APK location:
# android-app/app/build/outputs/apk/release/app-release.apk
```

## Installing APK on Device

### Via USB

```bash
adb install app/build/outputs/apk/debug/app-debug.apk
```

### Via File Transfer

1. Copy APK to device
2. Open Files app
3. Tap APK file
4. Click "Install"
5. Allow "Install Unknown Apps" if prompted

## Testing Checklist

- [ ] Login/Logout works
- [ ] Find doctors page loads
- [ ] Doctor profile page loads
- [ ] Autocomplete works
- [ ] Book appointment flow
- [ ] Messages page works
- [ ] QR code scanner opens
- [ ] Back button navigation
- [ ] Pull-to-refresh works
- [ ] Network error handling
- [ ] Deep linking works

## Common Issues

### "Cannot connect to server"

**For Emulator**:
- Use `10.0.2.2:7000` not `localhost:7000`
- Ensure Rails server is running

**For Physical Device**:
- Use computer's IP address (e.g., `192.168.1.100:7000`)
- Ensure device and computer on same WiFi
- Check firewall allows connections on port 7000
- Update docker-compose.yml to bind to `0.0.0.0:7000:7000`

### Build Errors

```bash
# Clean and rebuild
./gradlew clean
./gradlew build --stacktrace

# Or in Android Studio
Build → Clean Project
Build → Rebuild Project
```

### Gradle Sync Failed

1. File → Invalidate Caches → Invalidate and Restart
2. Delete `.gradle` folder
3. Sync again

## Production Deployment

### 1. Update Server URL

```kotlin
const val BASE_URL = "https://your-production-domain.com"
```

### 2. Generate App Bundle (for Play Store)

```bash
./gradlew bundleRelease

# AAB location:
# android-app/app/build/outputs/bundle/release/app-release.aab
```

### 3. Upload to Google Play Console

1. Create app in Play Console
2. Upload AAB file
3. Fill in store listing
4. Submit for review

## Next Steps

1. **Add Push Notifications**:
   - Integrate Firebase Cloud Messaging
   - Send notifications for appointments, messages

2. **Add App Icons**:
   - Create launcher icons
   - Add splash screen

3. **Improve Offline Support**:
   - Cache critical pages
   - Show offline indicator

4. **Add Analytics**:
   - Integrate Google Analytics
   - Track user flows

5. **Optimize Performance**:
   - Enable ProGuard
   - Optimize images
   - Implement code splitting

## Resources

- [Hotwire Native Android Docs](https://native.hotwired.dev/android)
- [Turbo Android GitHub](https://github.com/hotwired/turbo-android)
- [Android Developer Guide](https://developer.android.com/guide)

## Support

For issues:
1. Check the troubleshooting section above
2. Review Hotwire Native documentation
3. Check Android Studio logs (Logcat)
4. Open an issue on GitHub
