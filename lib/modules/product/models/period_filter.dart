enum PeriodFilter {
  today('Hari Ini'),
  sevenDays('7 Hari'),
  monthly('Bulan Ini');

  final String label;
  const PeriodFilter(this.label);
}
