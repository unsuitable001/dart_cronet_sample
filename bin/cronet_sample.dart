import 'package:cronet_sample/src/prepare_cronet.dart';

Future<void> main(List<String> platforms) async {
  for (final platform in platforms) {
    if (platform.startsWith('linux')) {
      buildWrapper();
    }
    await downloadCronetBinaries(platform);
  }
}
