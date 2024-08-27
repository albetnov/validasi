import 'package:validasi/validasi.dart';

void main() {
  var schema = Validasi.string().custom((value) async {
    await Future.delayed(Duration(milliseconds: 200));
    return false;
  }, 'User is not registered in the database!');

  schema.parse('value');
}
