import 'package:neo2/classes/pronote/crypto.dart';

void main() async {
  String hash = await Aes().aesToHexa("1");
  assert(hash == "3fa959b13967e0ef176069e01e23c8d7");
}
