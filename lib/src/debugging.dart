typedef AsyncDebugBlock = dynamic Function();
typedef DebugConsume = void Function(AsyncDebugBlock debugLog);

abstract class DebugHandler {
  void debug(AsyncDebugBlock debugLog);
}

class BufferedDebugHandler implements DebugHandler {

  List<AsyncDebugBlock> _buffer;

  BufferedDebugHandler(): _buffer = [], super();

  constructor() {
    _buffer = [];
  }

  @override
  void debug(AsyncDebugBlock debugMsg) {
    _buffer.add(debugMsg);
  }

  List<dynamic> executeBufferedBlocks() {
    final logs = _buffer.map((block) => block());
    _buffer = [];
    return logs.toList();
  }
}
