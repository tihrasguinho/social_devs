import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_devs_app/src/core/models/user_model.dart';
import 'package:social_devs_app/src/core/others/custom_uno.dart';
import 'package:uno/uno.dart';

class ProfileRepository {
  final CustomUno _customUno;

  ProfileRepository(this._customUno);

  final app = Hive.box('app');

  final picker = ImagePicker();

  Future<void> changePhoto() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      return;
    }

    final form = FormData();

    form.addBytes('image', await pickedFile.readAsBytes());

    final response = await _customUno.uno.post(
      '/images/upload-user-image',
      data: form,
    );

    final user = UserModel.fromMap(response.data['user']);

    await app.put('user', user.toJson());

    return;
  }
}
