# Chrono - Date parser for Dart (Flutter)

[![pub.dev/packages/chrono_dart](https://img.shields.io/pub/v/chrono_dart.svg "chrono_dart on pub.dev")](https://pub.dev/packages/chrono_dart)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A natural language date parser in Dart.

It is designed to handle most date/time format and extract information from any given text:

* Today, Tomorrow, Yesterday, Last Friday, etc
* 17 August 2013 - 19 August 2013
* This Friday from 13:00 - 16.00
* 5 days ago
* 2 weeks from now
* Sat Aug 17 2013 18:40:39 GMT+0900 (JST)
* 2014-11-30T08:15:30-05:30

# Usage
Simply pass a string to functions chrono.parseDate or chrono.parse.

```dart
import 'package:chrono_dart/chrono_dart.dart' as chrono;

chrono.parseDate('An appointment on Sep 12');
// Tue Sep 12 2023 12:00:00 GMT-0500 (CDT)
    
chrono.parse('An appointment on Sep 12');
/* [<ParsedResult>{ 
    index: 18,
    text: 'Sep 12',
    date() => DateTime('2023-09-12T12:00:00'),
    start: ...
}] */
```

-----------
Port of Chrono to Dart lang.
For extended API information see [the original package](https://github.com/wanasit/chrono/).
