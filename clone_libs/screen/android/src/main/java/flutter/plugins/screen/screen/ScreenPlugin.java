package flutter.plugins.screen.screen;

import android.app.Activity;
import android.provider.Settings;
import android.view.WindowManager;
import androidx.annotation.NonNull;

import org.jetbrains.annotations.NotNull;

import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.embedding.engine.plugins.FlutterPlugin;

/**
 * ScreenPlugin
 */
public class ScreenPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {

  private MethodChannel _channel;
  private FlutterPluginBinding _binding;
  private Activity _activity;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    _binding = flutterPluginBinding;
    _channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "github.com/clovisnicolas/flutter_screen");
    _channel.setMethodCallHandler(this);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    _binding = null;
    _channel.setMethodCallHandler(null);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch(call.method){
      case "brightness":
        result.success(getBrightness());
        break;
      case "setBrightness":
        double brightness = call.argument("brightness");
        WindowManager.LayoutParams layoutParams = _activity.getWindow().getAttributes();
        layoutParams.screenBrightness = (float)brightness;
        _activity.getWindow().setAttributes(layoutParams);
        result.success(null);
        break;
      case "isKeptOn":
        int flags = _activity.getWindow().getAttributes().flags;
        result.success((flags & WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON) != 0) ;
        break;
      case "keepOn":
        Boolean on = call.argument("on");
        if (on) {
          System.out.println("Keeping screen on ");
          _activity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        }
        else{
          System.out.println("Not keeping screen on");
          _activity.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        }
        result.success(null);
        break;

      default:
        result.notImplemented();
        break;
    }
  }

  private float getBrightness(){
    float result = _activity.getWindow().getAttributes().screenBrightness;
    if (result < 0) { // the application is using the system brightness
      try {
        result = Settings.System.getInt(_activity.getContentResolver(), Settings.System.SCREEN_BRIGHTNESS) / (float)255;
      } catch (Settings.SettingNotFoundException e) {
        result = 1.0f;
        e.printStackTrace();
      }
    }
    return result;
  }

  @Override
  public void onAttachedToActivity(@NonNull @NotNull ActivityPluginBinding binding) {
    _activity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {

  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull @NotNull ActivityPluginBinding binding) {

  }

  @Override
  public void onDetachedFromActivity() {
    _activity = null;
  }
}
