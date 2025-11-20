class CurrencyInfo {
  final String code;
  final String name;
  final String symbol;

  const CurrencyInfo({
    required this.code,
    required this.name,
    required this.symbol,
  });
}

class CurrencyData {
  static const List<CurrencyInfo> currencies = [
    CurrencyInfo(code: 'IDR', name: 'Rupiah', symbol: 'Rp'),
    CurrencyInfo(code: 'USD', name: 'US Dollar', symbol: '\$'),
    CurrencyInfo(code: 'EUR', name: 'Euro', symbol: '€'),
    CurrencyInfo(code: 'GBP', name: 'Pound Sterling', symbol: '£'),
    CurrencyInfo(code: 'JPY', name: 'Yen Jepang', symbol: '¥'),
    CurrencyInfo(code: 'CNY', name: 'Yuan Tiongkok', symbol: '¥'),
    CurrencyInfo(code: 'AUD', name: 'Dollar Australia', symbol: 'A\$'),
    CurrencyInfo(code: 'CAD', name: 'Dollar Kanada', symbol: 'C\$'),
    CurrencyInfo(code: 'CHF', name: 'Franc Swiss', symbol: 'CHF'),
    CurrencyInfo(code: 'SGD', name: 'Dollar Singapura', symbol: 'S\$'),
    CurrencyInfo(code: 'INR', name: 'Rupee India', symbol: '₹'),
    CurrencyInfo(code: 'KRW', name: 'Won Korea Selatan', symbol: '₩'),
    CurrencyInfo(code: 'MYR', name: 'Ringgit Malaysia', symbol: 'RM'),
    CurrencyInfo(code: 'THB', name: 'Baht Thailand', symbol: '฿'),
    CurrencyInfo(code: 'PHP', name: 'Peso Filipina', symbol: '₱'),
    CurrencyInfo(code: 'VND', name: 'Dong Vietnam', symbol: '₫'),
    CurrencyInfo(code: 'BRL', name: 'Real Brasil', symbol: 'R\$'),
    CurrencyInfo(code: 'ZAR', name: 'Rand Afrika Selatan', symbol: 'R'),
    CurrencyInfo(code: 'SAR', name: 'Riyal Saudi', symbol: '﷼'),
    CurrencyInfo(code: 'AED', name: 'Dirham Uni Emirat Arab', symbol: 'د.إ'),
    CurrencyInfo(code: 'RUB', name: 'Rubel Rusia', symbol: '₽'),
    CurrencyInfo(code: 'TRY', name: 'Lira Turki', symbol: '₺'),
    CurrencyInfo(code: 'MXN', name: 'Peso Meksiko', symbol: 'Mex\$'),
    CurrencyInfo(code: 'ARS', name: 'Peso Argentina', symbol: '\$'),
    CurrencyInfo(code: 'CLP', name: 'Peso Chile', symbol: 'CLP\$'),
    CurrencyInfo(code: 'COP', name: 'Peso Kolombia', symbol: 'COL\$'),
    CurrencyInfo(code: 'NZD', name: 'Dollar Selandia Baru', symbol: 'NZ\$'),
    CurrencyInfo(code: 'PLN', name: 'Zloty Polandia', symbol: 'zł'),
    CurrencyInfo(code: 'SEK', name: 'Krona Swedia', symbol: 'kr'),
    CurrencyInfo(code: 'NOK', name: 'Krone Norwegia', symbol: 'kr'),
    CurrencyInfo(code: 'DKK', name: 'Krone Denmark', symbol: 'kr'),
    CurrencyInfo(code: 'HKD', name: 'Dollar Hong Kong', symbol: 'HK\$'),
  ];
}

