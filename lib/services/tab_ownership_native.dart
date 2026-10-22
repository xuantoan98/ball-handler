import 'tab_ownership.dart';

TabOwnership createTabOwnership() => _SingleAppOwnership();

class _SingleAppOwnership implements TabOwnership {
  @override
  Future<bool> acquire() async => true;

  @override
  void release() {}
}
