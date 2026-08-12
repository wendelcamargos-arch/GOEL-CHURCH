/// Superfície pública da camada de domínio do Goel Church.
///
/// Stable Module Boundaries (ADR GOEL-ARCH-P2A-02B-A1): apenas o que é
/// exportado aqui é público. Tudo em `src/` que não for reexportado permanece
/// interno ao módulo.
///
/// Framework Independence: este pacote é Dart puro e NÃO importa Flutter.
library goel_domain;

export 'src/shared/result.dart';

// Autenticação (Slice 03)
export 'src/auth/auth_gateway.dart';
export 'src/auth/auth_models.dart';
export 'src/auth/identity_selection.dart';
export 'src/auth/identity_state.dart';
export 'src/auth/identity_summary.dart';

// Membro / cadastro (Slice 04)
export 'src/member/member_profile.dart';
export 'src/member/profile_gateway.dart';

// Conteúdo (Slice 06-07)
export 'src/content/daily_verse.dart';
export 'src/content/verse_repository.dart';
export 'src/content/devotional.dart';

// Bible Engine (Sprint 5)
export 'src/biblia/bible_models.dart';
export 'src/biblia/bible_repository.dart';
export 'src/biblia/reference_parser.dart';
