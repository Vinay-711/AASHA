{{flutter_js}}
{{flutter_build_config}}

// Disable service worker registration to avoid stale cached bundles
// during local demos.
_flutter.loader.load({
  serviceWorkerSettings: null,
});
