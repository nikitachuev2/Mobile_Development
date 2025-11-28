//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <csounddart/csounddart_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) csounddart_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "CsounddartPlugin");
  csounddart_plugin_register_with_registrar(csounddart_registrar);
}
