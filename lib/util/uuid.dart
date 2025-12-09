import 'package:uuid/uuid.dart';

class UUID {
   String get build => Uuid().v7().replaceAll("-", "");
}