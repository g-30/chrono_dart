# Chrono - Date parser for Dart (Flutter)

A natural language date parser in Dart. Finds and extracts dates from user-generated text content.

[![pub.dev/packages/chrono_dart](https://img.shields.io/pub/v/chrono_dart.svg "chrono_dart on pub.dev")](https://pub.dev/packages/chrono_dart)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

It is designed to handle most date/time format and extract information from any given text:

* Today, Tomorrow, Yesterday, Last Friday, etc
* 17 August 2013 - 19 August 2013
* This Friday from 13:00 - 16.00
* 5 days ago
* 2 weeks from now
* Sat Aug 17 2013 18:40:39 GMT+0900 (JST)
* 2014-11-30T08:15:30-05:30

# Usage
1. Install manually or via pub - `dart pub add chrono_dart`
2. Simply pass a string to functions Chrono.parseDate or Chrono.parse.

```dart
import 'package:chrono_dart/chrono_dart.dart' show Chrono;

Chrono.parseDate('An appointment on Sep 12');
// DateTime('2023-09-12 12:00:00.000Z')
    
Chrono.parse('An appointment on Sep 12');
/* [<ParsingResult>{ 
    index: 18,
    text: 'Sep 12',
    date() => DateTime('2023-09-12T12:00:00'),
    ...
}] */
```

-----------
Port of Chrono to Dart lang.
For extended API information see [the original package](https://github.com/wanasit/chrono/).
