import 'package:cronet_sample/src/prepare_cronet.dart';

void main(List<String> arguments) {
  arguments.forEach((platform) async {
    if (platform.startsWith('linux')) {
      buildWrapper();
    }
    await downloadCronetBinaries(platform);
  });
}
