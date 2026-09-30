import 'package:app_pai/core/cnpj.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CNPJ válido com e sem máscara', () {
    expect(Cnpj.isValido('11.222.333/0001-81'), isTrue);
    expect(Cnpj.isValido('11222333000181'), isTrue);
  });

  test('CNPJ inválido', () {
    expect(Cnpj.isValido('11.222.333/0001-82'), isFalse);
    expect(Cnpj.isValido('11111111111111'), isFalse);
    expect(Cnpj.isValido('1122233300018'), isFalse);
  });

  test('formatar', () {
    expect(Cnpj.formatar('70193852000128'), '70.193.852/0001-28');
    expect(Cnpj.formatar('123'), '123');
  });
}
