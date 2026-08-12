import 'package:flutter_test/flutter_test.dart';
import 'package:goel_church/features/biblia/data/planos.dart';
import 'package:goel_church/features/biblia/data/reading_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('lista os planos e carrega o Plano Goel Church', () async {
    final repo = PlanoRepository();
    final metas = await repo.listar();
    expect(
      metas.map((p) => p.id),
      containsAll(['anual', '90-dias', '30-dias', 'goel-church']),
    );

    final goel = await repo.carregar('goel-church');
    expect(goel.totalDias, 21);
    expect(goel.dias.first.first.bookId, 'joao');
    expect(goel.dias.first.first.capitulo, 1);
  });

  test('plano anual cobre 365 dias', () async {
    final anual = await PlanoRepository().carregar('anual');
    expect(anual.totalDias, 365);
  });

  test('progresso do plano marca/desmarca e persiste', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await ReadingStore.abrir();
    expect(store.diaLido('anual', 1), isFalse);
    expect(await store.alternarDia('anual', 1), isTrue);
    expect(store.diaLido('anual', 1), isTrue);
    expect(await store.alternarDia('anual', 1), isFalse);
    expect(store.diaLido('anual', 1), isFalse);
  });
}
