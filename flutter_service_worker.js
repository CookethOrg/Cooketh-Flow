'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter_bootstrap.js": "491667eae005da47319efacb364d881d",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"favicon.ico": "98d2e4bd562a2fe16c94a563bbfcf928",
"index.html": "e03ac4e806c409c4470c8560fd29fb77",
"/": "e03ac4e806c409c4470c8560fd29fb77",
"main.dart.js": "9c81ea981e4a690fe90e2d76e4b21a5c",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/chromium/canvaskit.js": "34beda9f39eb7d992d46125ca868dc61",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/canvaskit.js": "86e461cf471c1640fd2b461ece4589df",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"version.json": "977bfc579083127c05283d15f90b2677",
"404.html": "cef21d6764ec98b451effc26f93e1232",
"manifest.json": "46748a1ae6d528dd3f6dcfafbb523f5f",
"assets/AssetManifest.bin.json": "eeda3233d0757137c7e889943bab99e2",
"assets/AssetManifest.bin": "d79e693def92cb65faaf223dd9c04bf8",
"assets/NOTICES": "72710ddc39ce9562775e9d94391c1ce3",
"assets/AssetManifest.json": "69157113cc7804b44f6780f7d023f831",
"assets/fonts/MaterialIcons-Regular.otf": "bef2bd155a9ae36abbf214b941d60dcc",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/quill_native_bridge_linux/assets/xclip": "d37b0dbbc8341839cde83d351f96279e",
"assets/packages/phosphor_flutter/lib/fonts/Phosphor-Fill.ttf": "5d304fa130484129be6bf4b79a675638",
"assets/packages/phosphor_flutter/lib/fonts/Phosphor-Bold.ttf": "8fedcf7067a22a2a320214168689b05c",
"assets/packages/phosphor_flutter/lib/fonts/Phosphor-Thin.ttf": "f128e0009c7b98aba23cafe9c2a5eb06",
"assets/packages/phosphor_flutter/lib/fonts/Phosphor-Duotone.ttf": "c48df336708c750389fa8d06ec830dab",
"assets/packages/phosphor_flutter/lib/fonts/Phosphor.ttf": "003d691b53ee8fab57d5db497ddc54db",
"assets/packages/phosphor_flutter/lib/fonts/Phosphor-Light.ttf": "f2dc1cd993671b155e3235044280ba47",
"assets/FontManifest.json": "81df3118734fd29a365bdc9b37b2c6c6",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/assets/images/pfp.png": "7b6b52ecc9981b8d9a45c8cbdcdf92e2",
"assets/assets/images/Frame%2520400.png": "9ca70fad4518b40066b9c167d6cf0043",
"assets/assets/images/Frame%2520402.png": "9c8144cd0e463b2623b06e97dc59ec8f",
"assets/assets/images/Frame%2520401.png": "39701607e41ece04dab9a09db7a2f7a1",
"assets/assets/fonts/Frederik-BoldItalic-BF645d9bff9bf5e.otf": "f100452593b358c47806236e50a128af",
"assets/assets/fonts/Frederik-Medium-BF645d9bffbc329.otf": "8d5eba328145c08ecf22fada96cf6b76",
"assets/assets/fonts/Frederik-ThinItalic-BF645d9bff5ad07.otf": "35bcbca3c00225fb1256f79032884f13",
"assets/assets/fonts/Frederik-Regular-BF645d9bffaa893.otf": "1bec578c865b9021b8eb8131c958f35a",
"assets/assets/fonts/Frederik-MediumItalic-BF645d9bff71c45.otf": "b4fff068368cc84b08d1e0ab12b0d73c",
"assets/assets/fonts/Frederik-Heavy-BF645d9bffbbbdd.otf": "52503cdf5e505bc4aff4b2525286d085",
"assets/assets/fonts/Frederik-DemiBoldItalic-BF645d9bff9aca4.otf": "ce962d8d7471e5b19e63ea0aca506aa2",
"assets/assets/fonts/Frederik-ExtraBoldItalic-BF645d9bffa90f8.otf": "56873a23de962703e2ca6fd39c382456",
"assets/assets/fonts/Frederik-UltraLightItalic-BF645d9bff6ec22.otf": "067bbe67930e09fa0a5b0750dc47ba55",
"assets/assets/fonts/Frederik-HeavyItalic-BF645d9bffd6fec.otf": "1ace45b69d33fafa9201c0a3cfab3d8f",
"assets/assets/fonts/Frederik-BlackItalic-BF645d9bffac1de.otf": "3de7c3d8d8563773aad64c8e0f3087e6",
"assets/assets/fonts/Frederik-Bold-BF645d9bff85e69.otf": "fa9b00a3187a799700686168e7decd3d",
"assets/assets/fonts/Frederik-ExtraBold-BF645d9bffc1a5a.otf": "e09d416c40738e2800c510c08c40e250",
"assets/assets/fonts/Frederik-Black-BF645d9bff26630.otf": "d342505895adfac90073c7fe5581edcd",
"assets/assets/fonts/Frederik-DemiBold-BF645d9bff7b6ff.otf": "3d5f80a86b0fcc5a47f706164f698eb8",
"assets/assets/fonts/Frederik-Thin-BF645d9bffb3edf.otf": "a26a237a4f003bbf6b198c1ff135e951",
"assets/assets/fonts/Frederik-UltraLight-BF645d9bffae149.otf": "eb7e6043026ab069f2034af1e1605e6a",
"assets/assets/fonts/Frederik-LightItalic-BF645d9bffa496e.otf": "b2386aa9b5497c30354a8355133503ce",
"assets/assets/fonts/Frederik-Light-BF645d9bffbac92.otf": "aad05a97589caa9db65efbf8a5fc904e",
"assets/assets/fonts/Frederik-RegularItalic-BF645d9bffb230a.otf": "96f2af291f1e0f25bdabd797cc7e30f4"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
