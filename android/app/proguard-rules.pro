########################################
# General attributes (keep stack traces)
########################################
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable,EnclosingMethod,InnerClasses

########################################
# Razorpay (CRITICAL)
########################################
-keep class com.razorpay.** { *; }
-keep interface com.razorpay.** { *; }
-dontwarn com.razorpay.**

# Razorpay internal lifecycle & analytics (IMPORTANT)
-keepattributes Signature
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**
-keep class com.razorpay.AnalyticsUtil { *; }
-keepclassmembers class com.razorpay.AnalyticsUtil {
    public static <methods>;
    public <methods>;
}
-keep class com.razorpay.BaseCheckoutActivity { *; }
-keep class com.razorpay.CheckoutActivity { *; }
-keep class com.razorpay.LifecycleContext { *; }
-keep class com.razorpay.PerformanceUtil { *; }

########################################
# Google Play Services (used by Razorpay)
########################################
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

########################################
# AndroidX lifecycle (required)
########################################
-keep class androidx.lifecycle.** { *; }
-dontwarn androidx.lifecycle.**

########################################
# Flutter (safe)
########################################
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**
