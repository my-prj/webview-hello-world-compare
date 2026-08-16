#include <saucer/smartview.hpp>

#include <filesystem>
#include <print>

#if defined(__APPLE__)
#include <mach-o/dyld.h>
#endif

namespace fs = std::filesystem;

static fs::path bundle_resource_path(const char *name) {
#if defined(__APPLE__)
  char exe_path[4096];
  uint32_t size = sizeof(exe_path);
  if (_NSGetExecutablePath(exe_path, &size) != 0) {
    return {};
  }

  std::string path(exe_path);
  const auto macos_pos = path.rfind("/MacOS/");
  if (macos_pos == std::string::npos) {
    return {};
  }

  return fs::path(path.substr(0, macos_pos)) / "Resources" / name;
#else
  (void)name;
  return {};
#endif
}

coco::stray start(saucer::application *app) {
  auto window = saucer::window::create(app).value();
  auto webview = saucer::smartview::create({.window = window});

  window->set_title("Hello World");

  const auto html_path = bundle_resource_path("index.html");
  if (html_path.empty()) {
    std::println(stderr, "index.html not found in app bundle");
    co_return;
  }

  auto url = saucer::url::from(html_path);
  if (!url.has_value()) {
    std::println(stderr, "{}", url.error().message());
    co_return;
  }

  webview->set_url(url.value());
  window->show();

  co_await app->finish();
}

int main() {
  return saucer::application::create({.id = "com.webview-hello-world-compare.saucer"})
      ->run(start);
}
