class AppStrings {
  static const String appName = 'Kalorimu';
  static const String appTagline = 'Foto. AI Analisis. Sehat.';

  // Auth
  static const String login = 'Masuk';
  static const String register = 'Daftar';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String forgotPassword = 'Lupa password?';
  static const String loginWithGoogle = 'Masuk dengan Google';
  static const String noAccount = 'Belum punya akun? ';
  static const String hasAccount = 'Sudah punya akun? ';

  // Dashboard
  static const String goodMorning = 'Selamat Pagi';
  static const String goodAfternoon = 'Selamat Siang';
  static const String goodEvening = 'Selamat Malam';
  static const String todayCalories = 'Kalori Hari Ini';
  static const String targetCalories = 'Target';
  static const String remaining = 'Sisa';
  static const String emptyState = 'Belum ada catatan hari ini 🍽️';
  static const String emptyStateSubtitle =
      'Mulai dengan memfoto makananmu!\nAI akan bantu hitung kalorinya.';

  // Camera
  static const String takePhoto = 'Ambil Foto';
  static const String chooseGallery = 'Dari Galeri';
  static const String retakePhoto = 'Ulangi Foto';
  static const String analyzeWithAI = 'Analisis dengan AI';

  // AI Loading
  static const String analyzingFood = 'AI sedang menganalisis makananmu...';
  static const String aiLoading1 = 'Mendeteksi jenis makanan...';
  static const String aiLoading2 = 'Menghitung estimasi kalori...';
  static const String aiLoading3 = 'Menganalisis kandungan nutrisi...';
  static const String aiLoading4 = 'Hampir selesai...';

  // Review Form
  static const String reviewTitle = 'Review & Simpan';
  static const String foodName = 'Nama Makanan';
  static const String calories = 'Kalori (kcal)';
  static const String protein = 'Protein (g)';
  static const String carbs = 'Karbohidrat (g)';
  static const String fat = 'Lemak (g)';
  static const String description = 'Deskripsi';
  static const String mealType = 'Tipe Makan';
  static const String portionNote = 'Catatan Porsi';
  static const String saveJournal = 'Simpan Jurnal';
  static const String cancel = 'Batal';

  // Meal Types
  static const String breakfast = 'Sarapan';
  static const String lunch = 'Makan Siang';
  static const String dinner = 'Makan Malam';
  static const String snack = 'Camilan';
  static const String other = 'Lainnya';

  // Macros
  static const String proteinLabel = 'Protein';
  static const String carbsLabel = 'Karbo';
  static const String fatLabel = 'Lemak';

  // Settings
  static const String settings = 'Pengaturan';
  static const String profile = 'Profil';
  static const String dailyTarget = 'Target Kalori Harian';
  static const String notifications = 'Notifikasi';
  static const String darkMode = 'Mode Gelap';
  static const String logout = 'Keluar';
  static const String version = 'Versi';

  // Onboarding
  static const List<String> onboardingTitles = [
    'Foto Makananmu',
    'AI Analisis Instan',
    'Pantau Nutrisimu',
  ];
  static const List<String> onboardingSubtitles = [
    'Cukup ambil foto makanan\nsebelum makan. Semudah itu!',
    'AI kami mendeteksi nama makanan,\nkalori, dan nutrisi secara otomatis.',
    'Lihat ringkasan harian kalori &\nmakronutrien untuk hidup lebih sehat.',
  ];
}
