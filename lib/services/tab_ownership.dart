import 'tab_ownership_native.dart'
    if (dart.library.js_interop) 'tab_ownership_web.dart'
    as platform;

abstract interface class TabOwnership {
  Future<bool> acquire();
  void release();
}

TabOwnership createTabOwnership() => platform.createTabOwnership();
