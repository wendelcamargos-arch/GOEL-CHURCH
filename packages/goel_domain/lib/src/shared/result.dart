/// Resultado explícito de uma operação de domínio.
///
/// Torna sucesso e falha parte da assinatura, evitando exceções implícitas
/// como fluxo de controle. É Dart puro (sem Flutter).
sealed class Result<T, E> {
  const Result();

  R fold<R>(R Function(T value) onOk, R Function(E error) onErr) =>
      switch (this) {
        Ok<T, E>(:final value) => onOk(value),
        Err<T, E>(:final error) => onErr(error),
      };
}

final class Ok<T, E> extends Result<T, E> {
  final T value;
  const Ok(this.value);
}

final class Err<T, E> extends Result<T, E> {
  final E error;
  const Err(this.error);
}
