import '../models/camera_handle.dart';
import '../models/control_prop_type.dart';

abstract class CameraRemoteService<H extends CameraHandle> {
  Future<CameraHandle> connect();

  Future<void> setProp(H handle, ControlPropType propType, String value);

  Future<void> triggerRecord(H handle);
}
