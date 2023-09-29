// ignore_for_file: prefer_function_declarations_over_variables
import 'package:test/test.dart';
import 'package:chrono_dart/src/debugging.dart' show BufferedDebugHandler;

void main() {
  test("Test - BufferedDebugHandler", () {
    final debugHandler = BufferedDebugHandler();

    int a = 1;
    final debugBlockA = () => a = 2;
    debugHandler.debug(() => debugBlockA());
    expect(a, 1);

    int b = 2;
    final debugBlockB = () => b = 3;
    debugHandler.debug(() => debugBlockB());
    expect(b, 2);

    debugHandler.executeBufferedBlocks();
    expect(a, 2);
    expect(b, 3);
  });
}
