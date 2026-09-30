import 'package:app_pai/core/text_normalize.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizar remove acentos e caixa', () {
    expect(normalizar('SÃO LUIZ'), 'sao luiz');
    expect(normalizar('CONDOMÍNIO DE ARAÚJO'), 'condominio de araujo');
  });

  test('busca sem acento encontra texto acentuado', () {
    expect(contemNormalizado('VILA SÃO LUIZ', 'sao luiz'), isTrue);
    expect(contemNormalizado('CAMPINAS', 'lime'), isFalse);
  });

  test('maiusculasOuNulo', () {
    expect(maiusculasOuNulo('  isis '), 'ISIS');
    expect(maiusculasOuNulo('   '), isNull);
    expect(maiusculasOuNulo(null), isNull);
  });
}
