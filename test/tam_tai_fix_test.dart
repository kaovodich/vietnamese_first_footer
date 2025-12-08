import 'package:flutter_test/flutter_test.dart';
import 'package:vietnamese_first_footer/src/first_footer_engine.dart';

void main() {
  test('Tam Tai Fix Verification: Guest 1980 (Than) in Year 2024 (Thin)', () {
    // Scenario:
    // Host: 1980 (Canh Thân)
    // Guest: 1980 (Canh Thân) - Checking strict compliance for 1980 person.
    // Current Year: 2024 (Giáp Thìn)

    // Rule: Than-Ty-Thin group suffers Tam Tai in years Dan, Mao, Thin.
    // 2024 is Thin -> Tam Tai.

    final result = FirstFooterEngine.inspectPair(1980, 1980, 2024);

    print("Guest CanChi: ${result.canChi}");
    print("Cons: ${result.cons}");
    print("Score: ${result.score}");

    final hasTamTai = result.cons.any((c) => c.contains("Tam Tai"));

    expect(
      hasTamTai,
      isTrue,
      reason: "Guest 1980 (Than) must be flagged as Tam Tai in 2024 (Thin)",
    );
    expect(result.score, lessThan(0), reason: "Score should be penalized");
  });
}
