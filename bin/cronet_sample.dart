import 'package:cronet_sample/src/prepare_cronet.dart';

void main(List<String> arguments) async {
  buildWrapper();
  downloadCronetBinaries(['linux64']);
}
