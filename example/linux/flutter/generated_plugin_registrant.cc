//
//  Generated file. Do not edit.
//

#include "generated_plugin_registrant.h"

#include <cronet_sample/cronet_sample_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) cronet_sample_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "CronetSamplePlugin");
  cronet_sample_plugin_register_with_registrar(cronet_sample_registrar);
}
