# Flutter ProGuard Rules - Simplified and Safe
# Keep all Flutter classes
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Keep all plugin classes
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.plugins.**

# Keep Google Play Services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Keep Google Sign-In
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }

# Keep AndroidX
-keep class androidx.** { *; }
-dontwarn androidx.**

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep all enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelable implementations
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Optimization settings
-optimizationpasses 5
-dontusemixedcaseclassnames
-verbose

# Keep line numbers for debugging
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
