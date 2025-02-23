-keep class io.flutter.plugins.inappwebview.** { *; }
-keep class com.android.inappbrowser.** { *; }
-keep interface com.android.inappbrowser.** { *; }
-keep class org.chromium.ui.** { *; }
-keep class org.chromium.base.** { *; }
-keep class org.chromium.content.** { *; }

# Keep any other dependencies that might be required
-keep class com.hbncompany.foods.** { *; }  # Replace with your app's package
-dontwarn android.window.BackEvent