import 'package:flutter_test/flutter_test.dart';
import 'package:vietnamese_first_footer/vietnamese_first_footer.dart';

void main() {
  group('FirstFooterEngine Tests', () {
    test('Scenario: Host 1981 (Tân Dậu) vs Year 2024 (Giáp Thìn)', () {
      final hostYear = 1981; // Tân Dậu - Mộc (Thạch Lựu Mộc)
      final currentYear = 2024; // Giáp Thìn

      final suggestions = FirstFooterEngine.findBestFooters(
        hostYear,
        currentYear,
      );

      print("\n--- TOP CANDIDATES FOR HOST 1981 IN YEAR 2024 ---");
      for (var s in suggestions.take(5)) {
        print(s.toString());
        print("Pros: ${s.pros}");
        print("Cons: ${s.cons}");
        print("---------------------------------------------------");
      }

      // Check specific candidates

      // 1. 1989 (Kỷ Tỵ) - Should be high score
      // Tỵ (Snake) vs Dậu (Rooster) -> Tam Hợp (+4)
      // Tỵ vs Thìn (Year) -> Bình Hoà (+1)? Or no relation.
      // Kỷ (Earth) vs Tân (Metal) -> Earth feeds Metal (Sinh? Or just Hop?)
      // Nap Am: Đại Lâm Mộc (1989) vs Thạch Lựu Mộc (1981) -> Same (+1).
      // 1989 Nap Am is Mộc. 1981 is Mộc.
      // Lucky Stars?
      // Year Is Giáp Thìn.
      // Loc Ton of Giáp is Dần. (1989 is Tỵ). No.
      // Thien Ma of Thìn is Dần. No.
      // Quy Nhan of Giáp is Sửu/Mùi. No.

      final candidate1989 = suggestions.firstWhere(
        (s) => s.birthYear == 1989,
        orElse: () => throw "1989 not found",
      );
      expect(candidate1989.score, greaterThan(0));
      // print("1989 Score: ${candidate1989.score}");

      // 2. 1985 (Ất Sửu)
      // Sửu (Ox) vs Dậu (Rooster) -> Tam Hợp (+4).
      // Sửu vs Thìn -> Tuong Pha? Or no relation.
      // Ất vs Tân -> Khắc (Clash). (-1 Hinh/Pha).
      // Nap Am: Hải Trung Kim (1985) vs Thạch Lựu Mộc (1981). Kim cuts Mộc (-2).
      final candidate1985 = suggestions.firstWhere(
        (s) => s.birthYear == 1985,
        orElse: () => throw "1985 not found",
      );
      // Expect 1989 > 1985
      expect(candidate1989.score, greaterThan(candidate1985.score));

      // 3. 2000 (Canh Thìn)
      // Thìn vs Dậu -> Nhị Hợp (Luc Hop +3).
      // Thìn vs Thìn (year) -> Truc Thai Tue (-5).
      // Thìn vs Thìn (Tam Tai) -> Penalty (-10).
      // Result: High penalty.
      final candidate2000 = suggestions.firstWhere(
        (s) => s.birthYear == 2000,
        orElse: () => throw "2000 not found",
      );
      expect(candidate2000.cons, contains(contains("Tam Tai")));
      expect(candidate2000.cons, contains(contains("Thái Tuế")));
      expect(candidate2000.score, lessThan(0));
    });
  });
}
