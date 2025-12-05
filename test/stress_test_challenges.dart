import 'package:flutter_test/flutter_test.dart';
import 'package:vietnamese_first_footer/vietnamese_first_footer.dart';

void main() {
  test('Thien La Dia Vong Stress Test (30-Case)', () {
    final currentYear = 2024; // Giáp Thìn

    final challenges = [
      // GROUP A: TAM TAI & THAI TUE (Expect REJECT/NEGATIVE)
      {
        'id': 'A1',
        'host': 1980,
        'guest': 2000,
        'expect': 'BAD',
      }, // Tam Tai + Thai Tue
      {'id': 'A2', 'host': 1984, 'guest': 1992, 'expect': 'BAD'}, // Tam Tai
      {
        'id': 'A3',
        'host': 1976,
        'guest': 1988,
        'expect': 'BAD',
      }, // Tu Hinh + Tam Tai
      {
        'id': 'A4',
        'host': 1981,
        'guest': 1994,
        'expect': 'BAD',
      }, // Xung Thai Tue (Thin vs Tuat)
      // GROUP B: NAP AM CONFLICT (Expect LOW/AVG despite Tam Hop)
      {
        'id': 'B1',
        'host': 1978,
        'guest': 1982,
        'expect': 'LOW',
      }, // Ngo-Tuat (Good) but Water kills Fire (Bad)
      {
        'id': 'B2',
        'host': 1985,
        'guest': 1979,
        'expect': 'BAD',
      }, // Suu-Mui Xung + Fire kills Gold
      {
        'id': 'B5',
        'host': 1964,
        'guest': 1973,
        'expect': 'AVG',
      }, // Thin-Suu Pha but Wood feeds Fire (Good Nap Am saves it)
      // GROUP C: LUCKY STARS (Expect TOP TIER)
      {
        'id': 'C1',
        'host': 1987,
        'guest': 1974,
        'expect': 'TOP',
      }, // Dan is Loc+Ma -> Should be huge bonus
      {
        'id': 'C2',
        'host': 1979,
        'guest': 1986,
        'expect': 'TOP',
      }, // Mui vs Dan (Avg) but Loc+Ma saves it
      // GROUP D: EDGE CASES
      {'id': 'D1', 'host': 1981, 'guest': 1981, 'expect': 'AVG'}, // Self
      {
        'id': 'D2',
        'host': 2023,
        'guest': 2024,
        'expect': 'BAD',
      }, // Current Year (Thai Tue)
    ];

    print("\n| ID | Host | Guest | Score | Verdict | Details |");
    print("|---|---|---|---|---|---|");

    for (var c in challenges) {
      final host = c['host'] as int;
      final guest = c['guest'] as int;

      // Use the requested inspectPair method
      final result = FirstFooterEngine.inspectPair(host, guest, currentYear);

      String verdict;
      if (result.score >= 15)
        verdict = "EXCELLENT";
      else if (result.score >= 10)
        verdict = "GOOD";
      else if (result.score >= 5)
        verdict = "AVERAGE";
      else if (result.score >= 0)
        verdict = "WEAK";
      else
        verdict = "DANGEROUS";

      // If result is effectively disqualified (-999), handle display
      String scoreDisplay = result.score == -999
          ? "DISQ"
          : result.score.toString();
      if (result.score == -999) verdict = "DANGEROUS";

      String details = "";
      if (result.cons.isNotEmpty)
        details = "Cons: ${result.cons.join(', ')}";
      else if (result.pros.isNotEmpty)
        details = "Pros: ${result.pros.join(', ')}";

      // Simple truncation for table
      if (details.length > 60) details = details.substring(0, 57) + "...";

      print(
        "| ${c['id']} | $host | $guest | **$scoreDisplay** | $verdict | $details |",
      );
    }
    print("\n");
  });
}
