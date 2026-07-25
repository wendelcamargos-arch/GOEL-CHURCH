import 'daily_verse.dart';

/// Contrato de acesso ao versículo do dia (Stable Module Boundaries).
///
/// A origem (API licenciada online via Edge Function, com fallback offline) é
/// detalhe da camada de dados. O domínio não conhece HTTP nem provedor.
abstract interface class VerseRepository {
  Future<DailyVerse> verseForToday(DateTime today);
}
