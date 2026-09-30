/// Datas sem horário (as compras só guardam o dia).
DateTime soData(DateTime d) => DateTime(d.year, d.month, d.day);

/// `dd/mm/aaaa`
String formatarData(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/'
    '${d.year.toString().padLeft(4, '0')}';

/// `aaaa-mm-dd`
String formatarDataIso(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// Interpreta `dd/mm/aaaa` (também aceita `-` ou `.` como separador).
DateTime? parseData(String texto) {
  final m = RegExp(r'^\s*(\d{1,2})[/.-](\d{1,2})[/.-](\d{4})\s*$').firstMatch(texto);
  if (m == null) return null;
  final dia = int.parse(m.group(1)!);
  final mes = int.parse(m.group(2)!);
  final ano = int.parse(m.group(3)!);
  final d = DateTime(ano, mes, dia);
  if (d.day != dia || d.month != mes) return null;
  return d;
}

final _baseExcel = DateTime(1899, 12, 30);

/// Serial do Excel (ex.: `45911`) -> data.
DateTime dataDeSerialExcel(num serial) =>
    DateTime(_baseExcel.year, _baseExcel.month, _baseExcel.day + serial.floor());

/// Data -> serial do Excel.
int serialExcelDeData(DateTime d) =>
    DateTime.utc(d.year, d.month, d.day)
        .difference(DateTime.utc(1899, 12, 30))
        .inDays;

const nomesMesesAbrev = [
  'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
  'jul', 'ago', 'set', 'out', 'nov', 'dez',
];
