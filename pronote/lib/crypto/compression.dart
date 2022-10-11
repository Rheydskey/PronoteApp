import 'package:archive/archive_io.dart' as archive_io;

class Compression {
  static List<int> deflate(List<int> data) {
    return archive_io.Deflate(data).getBytes();
  }

  static List<int> inflate(List<int> data) {
    return archive_io.Inflate(data).getBytes();
  }
}
