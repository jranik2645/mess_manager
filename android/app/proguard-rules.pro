# Flutter Proguard Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.** { *; }

# Firebase Proguard Rules
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Fix for missing Play Store classes
-dontwarn com.google.android.play.core.**

# Keep your model classes to prevent Firestore data mapping issues in release mode
-keep class com.example.mess_manager.models.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
