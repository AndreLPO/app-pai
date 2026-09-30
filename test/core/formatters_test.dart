import 'package:app_pai/core/datas.dart';
import 'package:app_pai/core/formatters.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

String _aplicar(TextInputFormatter f, String texto) => f
    .formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: texto))
    .text;

void main() {
  test('CEP', () {
    expect(_aplicar(cepFormatter, '11071486'), '11071-486');
    expect(_aplicar(cepFormatter, '110714869999'), '11071-486');
  });

  test('telefone de 8 e 9 dígitos', () {
    expect(_aplicar(const TelefoneFormatter(), '60345419'), '6034-5419');
    expect(_aplicar(const TelefoneFormatter(), '960345419'), '9 6034-5419');
  });

  test('DDD aceita 2 dígitos', () {
    var v = const TextEditingValue(text: '1a93');
    for (final f in dddFormatters) {
      v = f.formatEditUpdate(TextEditingValue.empty, v);
    }
    expect(v.text, '19');
  });

  test('maiúsculas', () {
    expect(_aplicar(const MaiusculasFormatter(), 'café'), 'CAFÉ');
  });

  test('moeda entra pela direita', () {
    expect(_aplicar(const MoedaFormatter(), '799'), '7,99');
    expect(_aplicar(const MoedaFormatter(), '123456'), '1.234,56');
    expect(_aplicar(const MoedaFormatter(), ''), '');
  });

  test('datas', () {
    expect(formatarData(dataDeSerialExcel(45911)), '11/09/2025');
    expect(serialExcelDeData(DateTime(2025, 9, 11)), 45911);
    expect(parseData('31/03/2026'), DateTime(2026, 3, 31));
    expect(parseData('31/02/2026'), isNull);
  });
}
