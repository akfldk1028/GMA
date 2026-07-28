# MediaPipe classes referenced by flutter_gemma can be absent in the packaged
# runtime. R8 reports them as missing unless explicitly suppressed.
-dontwarn com.google.mediapipe.proto.CalculatorProfileProto$CalculatorProfile
-dontwarn com.google.mediapipe.proto.GraphTemplateProto$CalculatorGraphTemplate
