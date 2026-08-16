#include "webui.hpp"

#include <iostream>
#include <string>

#if defined(__APPLE__)
#include <mach-o/dyld.h>
#endif

static std::string bundle_resources_dir() {
#if defined(__APPLE__)
  char exe_path[4096];
  uint32_t size = sizeof(exe_path);
  if (_NSGetExecutablePath(exe_path, &size) != 0) {
    return "";
  }

  std::string path(exe_path);
  const auto macos_pos = path.rfind("/MacOS/");
  if (macos_pos == std::string::npos) {
    return "";
  }

  return path.substr(0, macos_pos) + "/Resources";
#else
  return "";
#endif
}

int main() {
  const std::string resources = bundle_resources_dir();
  if (resources.empty()) {
    std::cerr << "Resources directory not found in app bundle\n";
    return 1;
  }

  webui::window window;
  if (!window.set_root_folder(resources)) {
    std::cerr << "Failed to set root folder\n";
    return 1;
  }

  if (!window.show_wv("index.html")) {
    std::cerr << "Failed to show window\n";
    return 1;
  }

  webui::wait();
  return 0;
}
