const String productionPackageName =
    "id.garda.mobile"; // Bisa diupdate ke package berita nanti
const String sandboxPackageName = "id.garda.mobile";
const String appId = "6478091723";

/// Network Config
const String baseUrlProduction = "https://newsapi.org/v2";
const String baseUrlSandbox = "https://newsapi.org/v2/";
const String baseUrl = isProduction ? baseUrlProduction : baseUrlSandbox;
const String baseApi = baseUrl;

/// is production
const bool isProduction = false;

/// Timeout Duration (Digunakan di service_locator.dart)
const int timeOutDuration = 30;

// firebase
const String firebaseDatabaseUrl =
    "https://apps-berita-default-rtdb.asia-southeast1.firebasedatabase.app/";

const String firebaseSecondaryApp = "secondary";

// flag CDN Base Url
const String flagCdnUrl = 'https://flagcdn.com/w160';

// daftar negara yg didukung oleh NewsAPI & FlagCDN
const List<Map<String, String>> supportedCOuntry = [
  {"name": "Indonesia", "code": "id"},
  {"name": "United States", "code": "us"},
  {"name": "Australia", "code": "au"},
  {"name": "Belgium", "code": "be"},
  {"name": "Brazil", "code": "br"},
  {"name": "Canada", "code": "ca"},
  {"name": "China", "code": "cn"},
  {"name": "France", "code": "fr"},
  {"name": "Germany", "code": "de"},
  {"name": "Japan", "code": "jp"},
  {"name": "Singapore", "code": "sg"},
  {"name": "United Kingdom", "code": "gb"},
];

// daftar 10 avatar pilihan (DiceBear Adventurer)
const List<String> supportedAvatars = [
  'https://api.dicebear.com/7.x/adventurer/png?seed=George',
  'https://api.dicebear.com/7.x/adventurer/png?seed=Bella',
  'https://api.dicebear.com/7.x/adventurer/png?seed=Felix',
  'https://api.dicebear.com/7.x/adventurer/png?seed=Lily',
  'https://api.dicebear.com/7.x/adventurer/png?seed=Jack',
  'https://api.dicebear.com/7.x/adventurer/png?seed=Sophie',
  'https://api.dicebear.com/7.x/adventurer/png?seed=Buster',
  'https://api.dicebear.com/7.x/adventurer/png?seed=Mia',
  'https://api.dicebear.com/7.x/adventurer/png?seed=Tigger',
  'https://api.dicebear.com/7.x/adventurer/png?seed=Daisy',
];
