# Razorpay ProGuard rules
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class com.razorpay.** {*;}
-keep class com.google.android.gms.** { *; }
-dontwarn com.razorpay.**
-dontwarn com.google.android.gms.**

# Additional rules for R8 compatibility
-keep class com.razorpay.LifecycleContext { *; }
-keep class com.razorpay.PerformanceUtil { *; }
