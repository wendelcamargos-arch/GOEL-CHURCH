/// Um versículo com referência e texto.
class DailyVerse {
  final String reference;
  final String text;

  const DailyVerse({required this.reference, required this.text});
}

/// Seleção determinística do "versículo do dia" (Framework Independence).
///
/// Offline-first (ADR-015): dada a lista local de versículos, o mesmo dia
/// resolve sempre o mesmo versículo, sem depender de rede.
class DailyVerseSelector {
  const DailyVerseSelector._();

  static DailyVerse pick(List<DailyVerse> verses, DateTime day) {
    if (verses.isEmpty) {
      throw StateError('Nenhum versículo disponível.');
    }
    final normalized = DateTime(day.year, day.month, day.day);
    final ordinal = normalized.difference(DateTime(day.year, 1, 1)).inDays;
    return verses[ordinal % verses.length];
  }
}
