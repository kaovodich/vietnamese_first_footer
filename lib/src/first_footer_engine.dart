import 'package:vietnamese_lunar_core/vietnamese_lunar_core.dart';
import 'package:vietnamese_calendar_attributes/vietnamese_calendar_attributes.dart';

/// Data model for a First Footer suggestion
class FooterSuggestion {
  final int birthYear;
  final String canChi; // e.g., "Mậu Thìn"
  final String napAm; // e.g., "Đại Lâm Mộc"
  final int score;
  final List<String> pros;
  final List<String> cons;

  FooterSuggestion({
    required this.birthYear,
    required this.canChi,
    required this.napAm,
    required this.score,
    required this.pros,
    required this.cons,
  });

  @override
  String toString() {
    return 'FooterSuggestion(year: $birthYear, canChi: $canChi, napAm: $napAm, score: $score)';
  }
}

/// The core engine for finding the best First Footer
class FirstFooterEngine {
  static const _cans = [
    "Canh",
    "Tân",
    "Nhâm",
    "Quý",
    "Giáp",
    "Ất",
    "Bính",
    "Đinh",
    "Mậu",
    "Kỷ",
  ];
  static const _chis = [
    "Thân",
    "Dậu",
    "Tuất",
    "Hợi",
    "Tý",
    "Sửu",
    "Dần",
    "Mão",
    "Thìn",
    "Tỵ",
    "Ngọ",
    "Mùi",
  ];

  static String getCan(int year) => _cans[year % 10];
  static String getChi(int year) => _chis[year % 12];

  // Expose scoreCandidate for stress testing specific pairs
  static FooterSuggestion scoreCandidate(
    int guestYear,
    int hostBirthYear,
    int currentYear,
  ) {
    // 1. Host Info
    final hostCan = getCan(hostBirthYear);
    final hostChi = getChi(hostBirthYear);
    final hostDate = LunarDate(
      day: 1,
      month: 1,
      year: hostBirthYear,
      timeZone: '7',
      isLeap: false,
    );
    final hostNapAmElement = VnAttributeUtils.napAmElement(hostDate);

    // 2. Current Year Info
    final currentYearCan = getCan(currentYear);
    final currentYearChi = getChi(currentYear);

    // 3. Guest Info
    int score = 0;
    List<String> pros = [];
    List<String> cons = [];

    final guestCan = getCan(guestYear);
    final guestChi = getChi(guestYear);
    final guestDate = LunarDate(
      day: 1,
      month: 1,
      year: guestYear,
      timeZone: '7',
      isLeap: false,
    );
    final guestNapAmElement = VnAttributeUtils.napAmElement(guestDate);
    final guestNapAm = guestNapAmElement.toString();

    // --- PHASE 1: COMPATIBILITY (GUEST vs HOST) ---

    // A. Thien Can
    if (checkCanHop(guestCan, hostCan)) {
      score += 2;
      pros.add("Thiên Can Hợp với gia chủ (+2)");
    } else if (checkCanHinhPha(guestCan, hostCan)) {
      score -= 1;
      cons.add("Thiên Can Hình/Phá với gia chủ (-1)");
    } else {
      score += 1;
    }

    // B. Dia Chi
    if (checkChiTamHop(guestChi, hostChi)) {
      score += 4;
      pros.add("Địa Chi Tam Hợp với gia chủ (+4)");
    } else if (checkChiLucHop(guestChi, hostChi)) {
      score += 3;
      pros.add("Địa Chi Lục Hợp với gia chủ (+3)");
    } else if (checkChiLucXung(guestChi, hostChi)) {
      score -= 2;
      cons.add("Địa Chi Lục Xung với gia chủ (-2)");
    } else if (checkChiLucHai(guestChi, hostChi)) {
      score -= 1;
      cons.add("Địa Chi Lục Hại với gia chủ (-1)");
    } else if (checkChiTuHinh(guestChi, hostChi)) {
      score -= 1;
      cons.add("Địa Chi Tự Hình với gia chủ (-1)");
    } else {
      score += 1;
    }

    // C. Ngu Hanh (Nap Am Element)
    final elementCheck = checkElement(guestNapAmElement, hostNapAmElement);
    if (elementCheck == 3) {
      score += 3;
      pros.add("Ngũ Hành Tương Sinh với gia chủ (+3)");
    } else if (elementCheck == 1) {
      score += 1;
    } else if (elementCheck == -2) {
      score -= 2;
      cons.add("Ngũ Hành Tương Khắc với gia chủ (-2)");
    }

    // --- PHASE 1.5: LUCKY STARS ---
    if (checkLocTon(guestChi, currentYearCan)) {
      score += 2;
      pros.add("Mang Lộc Tồn của năm (+2)");
    }
    if (checkThienMa(guestChi, currentYearChi)) {
      score += 2;
      pros.add("Mang Thiên Mã của năm (+2)");
    }
    if (checkQuyNhan(guestChi, currentYearCan)) {
      score += 2;
      pros.add("Là Quý Nhân của năm (+2)");
    }

    // --- PHASE 2: THAI TUE FILTER ---
    if (guestChi == currentYearChi) {
      score -= 5;
      cons.add("Phạm Thái Tuế (Trực Thái Tuế) (-5)");
    }

    if (checkChiLucXung(guestChi, currentYearChi)) {
      score = -999;
      cons.add("Phạm Thái Tuế (Lục Xung) - KỴ XÔNG ĐẤT");
    }

    // --- PHASE 3: TAM TAI FILTER ---
    if (checkTamTai(guestChi, currentYearChi)) {
      score -= 10;
      cons.add("Đang hạn Tam Tai (-10)");
    }

    return FooterSuggestion(
      birthYear: guestYear,
      canChi: "$guestCan $guestChi",
      napAm: guestNapAm,
      score: score,
      pros: pros,
      cons: cons,
    );
  }

  // Alias for stress testing
  static FooterSuggestion inspectPair(
    int hostYear,
    int guestYear,
    int currentYear,
  ) {
    return scoreCandidate(guestYear, hostYear, currentYear);
  }

  /// Main function to find best footers
  static List<FooterSuggestion> findBestFooters(
    int hostBirthYear,
    int currentYear,
  ) {
    List<FooterSuggestion> suggestions = [];

    // 3. Iterate Candidates (CurrentYear - 60 to CurrentYear - 10)
    for (int y = currentYear - 60; y <= currentYear - 10; y++) {
      suggestions.add(scoreCandidate(y, hostBirthYear, currentYear));
    }

    suggestions.sort((a, b) => b.score.compareTo(a.score));
    return suggestions.take(20).toList();
  }

  // --- Logic Helpers ---

  static bool checkCanHop(String guest, String host) {
    const pairs = {
      "Giáp": "Kỷ",
      "Kỷ": "Giáp",
      "Ất": "Canh",
      "Canh": "Ất",
      "Bính": "Tân",
      "Tân": "Bính",
      "Đinh": "Nhâm",
      "Nhâm": "Đinh",
      "Mậu": "Quý",
      "Quý": "Mậu",
    };
    return pairs[guest] == host;
  }

  static bool checkCanHinhPha(String guest, String host) {
    // Precise Can Clashes (Tuong Khac) often used as Hinh/Pha in this context
    // Giáp - Canh, Ất - Tân, Bính - Nhâm, Đinh - Quý.
    if ((guest == "Giáp" && host == "Canh") ||
        (guest == "Canh" && host == "Giáp"))
      return true;
    if ((guest == "Ất" && host == "Tân") || (guest == "Tân" && host == "Ất"))
      return true;
    if ((guest == "Bính" && host == "Nhâm") ||
        (guest == "Nhâm" && host == "Bính"))
      return true;
    if ((guest == "Đinh" && host == "Quý") ||
        (guest == "Quý" && host == "Đinh"))
      return true;
    // Mậu - Giáp? (Wood controls Earth)
    if ((guest == "Mậu" && host == "Giáp") ||
        (guest == "Giáp" && host == "Mậu"))
      return true; // Often considered clash
    if ((guest == "Kỷ" && host == "Ất") || (guest == "Ất" && host == "Kỷ"))
      return true;

    // Mậu - Nhâm? (Earth controls Water)?
    // For this algorithm, we stick to the main 4 clashes + explicit controls.
    return false;
  }

  static bool checkChiTamHop(String a, String b) {
    const groups = [
      {"Thân", "Tý", "Thìn"},
      {"Dần", "Ngọ", "Tuất"},
      {"Tỵ", "Dậu", "Sửu"},
      {"Hợi", "Mão", "Mùi"},
    ];
    for (var g in groups) {
      if (g.contains(a) && g.contains(b) && a != b) return true;
    }
    return false;
  }

  static bool checkChiLucHop(String a, String b) {
    const pairs = {
      "Tý": "Sửu",
      "Sửu": "Tý",
      "Dần": "Hợi",
      "Hợi": "Dần",
      "Mão": "Tuất",
      "Tuất": "Mão",
      "Thìn": "Dậu",
      "Dậu": "Thìn",
      "Tỵ": "Thân",
      "Thân": "Tỵ",
      "Ngọ": "Mùi",
      "Mùi": "Ngọ",
    };
    return pairs[a] == b;
  }

  static bool checkChiLucXung(String a, String b) {
    const pairs = {
      "Tý": "Ngọ",
      "Ngọ": "Tý",
      "Sửu": "Mùi",
      "Mùi": "Sửu",
      "Dần": "Thân",
      "Thân": "Dần",
      "Mão": "Dậu",
      "Dậu": "Mão",
      "Thìn": "Tuất",
      "Tuất": "Thìn",
      "Tỵ": "Hợi",
      "Hợi": "Tỵ",
    };
    return pairs[a] == b;
  }

  static bool checkChiLucHai(String a, String b) {
    const pairs = {
      "Tý": "Mùi",
      "Mùi": "Tý",
      "Sửu": "Ngọ",
      "Ngọ": "Sửu",
      "Dần": "Tỵ",
      "Tỵ": "Dần",
      "Mão": "Thìn",
      "Thìn": "Mão",
      "Thân": "Hợi",
      "Hợi": "Thân",
      "Dậu": "Tuất",
      "Tuất": "Dậu",
    };
    return pairs[a] == b;
  }

  static bool checkChiTuHinh(String a, String b) {
    const set = {"Thìn", "Ngọ", "Dậu", "Hợi"};
    return a == b && set.contains(a);
  }

  static int checkElement(dynamic guest, dynamic host) {
    try {
      int gIdx = getElementIndex(guest);
      int hIdx = getElementIndex(host);

      // Generating: (g + 1) % 5 == h ?? No, Generator -> Generated.
      // Kim(0) generates Thuy(1).
      // Guest Sinh Host -> Guest is Generator.
      if ((gIdx + 1) % 5 == hIdx) return 3; // Sinh(+3)
      if (gIdx == hIdx) return 1; // Binh(+1)

      // Guest Khac Host.
      // Kim(0) Khac Moc(2).
      if ((gIdx + 2) % 5 == hIdx) return -2; // Khac(-2)

      return 0;
    } catch (e) {
      return 0;
    }
  }

  static int getElementIndex(dynamic e) {
    final s = e.toString().toUpperCase();
    if (s.contains("KIM")) return 0;
    if (s.contains("THUY") || s.contains("THỦY")) return 1;
    if (s.contains("MOC") || s.contains("MỘC")) return 2;
    if (s.contains("HOA") || s.contains("HỎA")) return 3;
    if (s.contains("THO") || s.contains("THỔ")) return 4;
    return -1; // Unknown
  }

  static bool checkLocTon(String guestChi, String yearCan) {
    Map<String, String> map = {
      "Giáp": "Dần",
      "Ất": "Mão",
      "Bính": "Tỵ",
      "Mậu": "Tỵ",
      "Đinh": "Ngọ",
      "Kỷ": "Ngọ",
      "Canh": "Thân",
      "Tân": "Dậu",
      "Nhâm": "Hợi",
      "Quý": "Tý",
    };
    return map[yearCan] == guestChi;
  }

  static bool checkThienMa(String guestChi, String yearChi) {
    if (["Dần", "Ngọ", "Tuất"].contains(yearChi)) return guestChi == "Thân";
    if (["Thân", "Tý", "Thìn"].contains(yearChi)) return guestChi == "Dần";
    if (["Tỵ", "Dậu", "Sửu"].contains(yearChi)) return guestChi == "Hợi";
    if (["Hợi", "Mão", "Mùi"].contains(yearChi)) return guestChi == "Tỵ";
    return false;
  }

  static bool checkQuyNhan(String guestChi, String yearCan) {
    if (["Giáp", "Mậu"].contains(yearCan))
      return ["Sửu", "Mùi"].contains(guestChi);
    if (["Ất", "Kỷ"].contains(yearCan))
      return ["Tý", "Thân"].contains(guestChi);
    if (["Bính", "Đinh"].contains(yearCan))
      return ["Hợi", "Dậu"].contains(guestChi);
    if (["Canh", "Tân"].contains(yearCan))
      return ["Dần", "Ngọ"].contains(guestChi);
    if (["Nhâm", "Quý"].contains(yearCan))
      return ["Tỵ", "Mão"].contains(guestChi);
    return false;
  }

  static bool checkTamTai(String guestChi, String currentYearChi) {
    const group1 = {"Thân", "Tý", "Thìn"};
    const bad1 = {"Dần", "Mão", "Thìn"};
    if (group1.contains(guestChi) && bad1.contains(currentYearChi)) return true;

    const group2 = {"Tỵ", "Dậu", "Sửu"};
    const bad2 = {"Hợi", "Tý", "Sửu"};
    if (group2.contains(guestChi) && bad2.contains(currentYearChi)) return true;

    const group3 = {"Dần", "Ngọ", "Tuất"};
    const bad3 = {"Thân", "Dậu", "Tuất"};
    if (group3.contains(guestChi) && bad3.contains(currentYearChi)) return true;

    const group4 = {"Hợi", "Mão", "Mùi"};
    const bad4 = {"Tỵ", "Ngọ", "Mùi"};
    if (group4.contains(guestChi) && bad4.contains(currentYearChi)) return true;

    return false;
  }
}
