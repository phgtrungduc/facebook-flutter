import 'package:image_picker/image_picker.dart';

class AccessHardware {
  //event with overlay element or function for callback, event
  getImageFromPhone(ImageSource imageSource) async {
    //value manage gallery and camera
    final picker = ImagePicker();
    var pickedFile = await picker.getImage(source: imageSource);

    if (pickedFile != null) {
      return pickedFile;
    } else {
      return null;
    }
  }
}
