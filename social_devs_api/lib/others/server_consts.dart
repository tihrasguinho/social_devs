const kProfileMode = bool.fromEnvironment('dart.vm.profile');
const kReleaseMode = bool.fromEnvironment('dart.vm.product');
const kDebugMode = !kProfileMode && !kReleaseMode;
