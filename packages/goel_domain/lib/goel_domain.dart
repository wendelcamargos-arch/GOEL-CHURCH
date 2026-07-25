/// Superfície pública da camada de domínio do Goel Church.
///
/// Stable Module Boundaries (ADR GOEL-ARCH-P2A-02B-A1): apenas o que é
/// exportado aqui é público. Tudo em `src/` que não for reexportado permanece
/// interno ao módulo.
///
/// Framework Independence: este pacote é Dart puro e NÃO importa Flutter.
library goel_domain;

export 'src/shared/result.dart';
