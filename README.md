# samurai


[![version 0.0.0](https://img.shields.io/badge/pub-0.0.0-red.svg)](https://pub.dartlang.org/packages/samurai)
[![build status](https://travis-ci.org/samurai-dart/samurai.svg)](https://travis-ci.org/samurai-dart/samurai)

JS Interpreter in Dart. No `mirrors` dependency. Runs ES5.

Samurai by itself includes nothing but the [standard libraries](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects).
Other functionality will be in [separate packages](https://pub.dartlang.org/search?q=samurai).

## Possibilities
* Enhanced Web scraping (perhaps with [Rapier](https://github.com/thosakwe/rapier))
* Existing JS libraries that cannot be easily ported can be wrapped
(I'm looking at you, Hammer, and esprima!)
* Server-side rendering of compiled JS apps
  * Will require a headless DOM for Samurai

# Acknowledgements and Contributions
* A *huge* thanks to Asger Feldthaus and his [parsejs](https://github.com/asgerf/parsejs.dart) library.
