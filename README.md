# 🧧 Vietnamese First Footer (Xông Đất 2025)

**Status:** ✅ Production Ready | 🛡️ Battle-Tested with "Thien La Dia Vong" Suite (30 Edge Cases).

## 1. Introduction
*   **What is it?** An advanced algorithm to find the perfect "First Footer" (Người xông đất) for the Lunar New Year.
*   **Why use it?** Unlike simple apps that only check "Tam Hợp" (Triple Harmony), this engine analyzes **Deep Compatibility** (Nap Am Element), **Luck Factors** (Loc/Ma/Quy Nhan), and applies strict **Bad Luck Filters** (Tam Tai/Thai Tue).

## 2. Key Features (The "Secret Sauce")
*   **3-Way Matching:** Evaluates the relationship between **Host vs. Guest vs. Current Year** (not just Host vs. Guest).
*   **Deep Element Logic:** Uses **Nạp Âm** (Melodic Element) for precise conflict detection (e.g., Water guests dampen Fire hosts), moving beyond generic Stem elements.
*   **Luck Boosting:** Automatically awards bonus points for guests who act as **Lộc Tồn** (Wealth), **Thiên Mã** (Travel/Progress), and **Quý Nhân** (Helpful People) for the current year.
*   **Safety First:** Applies strict filters to penalize or disqualify candidates carrying **Tam Tai** (Three Disasters) or **Xung Thái Tuế** (Year Clash).

## 3. Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  vietnamese_first_footer:
    git:
      url: https://github.com/kaovodich/vietnamese_first_footer.git
      ref: main
```

## 4. Usage Example

```dart
import 'package:vietnamese_first_footer/vietnamese_first_footer.dart';

void main() {
  // Example: Host born in 1981 (Tân Dậu) looking for Xông Đất in 2024 (Giáp Thìn)
  int hostYear = 1981;
  int currentYear = 2024;

  List<FooterSuggestion> results = FirstFooterEngine.findBestFooters(hostYear, currentYear);

  print("Top Candidates for Owner $hostYear:");
  for (var candidate in results.take(5)) {
    print("--- Age: ${candidate.birthYear} (${candidate.canChi}) ---");
    print("Score: ${candidate.score}");
    print("Pros: ${candidate.pros.join(', ')}");
    print("Cons: ${candidate.cons.join(', ')}");
  }
}
```

## 5. QA & Certification
This library has been verified against the **"Thien La Dia Vong" Stress Test Suite**, ensuring that:
*   Guests with **Tam Tai** are strictly penalized.
*   Guests with **Thai Tue Clash** are disqualified immediately.
*   **Example Victory:** Correctly identified that for a 1981 Host, a 1989 (Kỷ Tỵ) guest is superior to a 1985 (Ất Sửu) guest due to better Nạp Âm harmony (despite both being Tam Hợp).

## 6. Disclaimer
Algorithm based on traditional Vietnamese "Thông Thư" principles. For reference purposes only.
