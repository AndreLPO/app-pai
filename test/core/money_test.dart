import 'package:app_pai/core/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromDouble remove ruído de ponto flutuante', () {
    expect(Money.fromDouble(73.06999999999999), 7307);
    expect(Money.fromDouble(8.720000000000001), 872);
  });

  test('format no padrão brasileiro', () {
    expect(Money.format(7307), r'R$ 73,07');
    expect(Money.format(123456), r'R$ 1.234,56');
    expect(Money.format(5), r'R$ 0,05');
    expect(Money.format(0), r'R$ 0,00');
    expect(Money.format(-150), r'R$ -1,50');
  });

  test('quantidade x valor unitário em centavos', () {
    expect(Money.format(93 * 7307), r'R$ 6.795,51');
  });

  test('parse de entradas brasileiras', () {
    expect(Money.parse(r'R$ 1.234,56'), 123456);
    expect(Money.parse('1234,5'), 123450);
    expect(Money.parse('7'), 700);
    expect(Money.parse('7.50'), 750);
    expect(Money.parse('1.234'), 123400);
    expect(Money.parse(''), isNull);
    expect(Money.parse('abc'), isNull);
    expect(Money.parse('1,234'), isNull);
  });

  test('formatInteiro agrupa milhares', () {
    expect(formatInteiro(1200), '1.200');
    expect(formatInteiro(93), '93');
  });
}
