#include "webview/webview.h"

#include <iostream>
#include <string>

#if defined(__APPLE__)
#include <mach-o/dyld.h>
#endif

static std::string html_file_url() {
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

  return "file://" + path.substr(0, macos_pos) + "/Resources/index.html";
#else
  return "";
#endif
}

int main() {
  try {
    webview::webview window(false, nullptr);
    window.set_title("Hello World");
    window.set_size(480, 320, WEBVIEW_HINT_NONE);

    const std::string url = html_file_url();
    if (url.empty()) {
      std::cerr << "index.html not found in app bundle\n";
      return 1;
    }

    window.navigate(url);
    window.run();
  } catch (const webview::exception &error) {
    std::cerr << error.what() << std::endl;
    return 1;
  }

  return 0;
}
