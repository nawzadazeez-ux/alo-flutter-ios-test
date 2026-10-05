import 'dart:convert';
import 'dart:math' as math;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DealerApi.instance.init();
  await AdminApi.instance.init();
  runApp(const AloApp());
}

const kBg = Color(0xFF06140F);
const kSurface = Color(0xFF0D211A);
const kSurface2 = Color(0xFF143128);
const kGreen = Color(0xFF58E39B);
const kGreen2 = Color(0xFFB7FFD4);
const kText = Color(0xFFF2FFF8);
const kMuted = Color(0xFF9DB8AB);
const kSite = 'https://alosolarenergy.com';

final ValueNotifier<String> appLang = ValueNotifier<String>('ku');

const Map<String, Map<String, String>> _tx = {
  'ku': {
    'home': 'سەرەتا',
    'products': 'بەرهەمەکان',
    'calculator': 'حیسابکەر',
    'ev': 'شەحنی EV',
    'ai': 'یاریدەدەری زیرەک',
    'more': 'زیاتر',
    'companySub': 'هەولێر • خۆر • پاتری • EV',
    'heroEyebrow': 'وزەی پاک • هەڵبژاردەی زیرەک',
    'heroTitle': 'بە وزەی خۆر، داهاتوویەکی ڕوونتر دروست بکە.',
    'heroBody': 'لە Alo Solar Energy، سیستەمی وزەی خۆری گونجاو بۆ ماڵ و کاروبار دابین دەکەین؛ لە دیزاین و هەڵبژاردنی کەرەستەوە تا دامەزراندن و پشتیوانی دوای فرۆشتن.',
    'calculateSystem': 'سیستەمەکەت حیساب بکە',
    'energyIndependence': 'سەربەخۆیی لە وزە',
    'systemOptions': 'هەڵبژاردەی سیستەم',
    'whatWeDo': 'ئێمە چی دەکەین',
    'allSolarServices': 'هەموو خزمەتگوزارییەکانی وزەی خۆر',
    'solutions': 'چارەسەرەکان',
    'solutionSub': 'سیستەمی گونجاو بۆ پێداویستییەکەت',
    'whyAlo': 'بۆچی Alo Solar Energy',
    'whySub': 'بۆ وزەی پشتپێبەستراو دروستکراوە.',
    'visitAlo': 'سەردانی Alo Solar Energy بکە',
    'address': 'هەولێر – نیو هەولێر – بەرامبەر مزگەوتی سەید جەعفەر',
    'serviceDesign': 'دیزاینی سیستەمی وزەی خۆر',
    'serviceDesignBody': 'پانێڵ، ئینڤێرتەر و پاتری بە پێی بەکارهێنانی کارەبا و پێداویستی شوێنەکە دیاری دەکەین.',
    'serviceHybrid': 'هایبرید و ئۆف-گرید',
    'serviceHybridBody': 'سیستەمی پشتگیریکراو بە پاتری بۆ بەردەوامبوونی بارە گرنگەکان و کەمکردنەوەی پشتبەستن بە تۆڕ.',
    'serviceCommercial': 'خۆری بازرگانی',
    'serviceCommercialBody': 'چارەسەری گونجاوی خۆر بۆ دوکان، ئۆفیس، کارگە، کێڵگە و کاروبارەکان.',
    'serviceHome': 'خۆری نیشتەجێبوون',
    'serviceHomeBody': 'سیستەمی زیرەکی سەربان بەپێی پێداویستی ڕۆژانەی کارەبای ماڵەکەت.',
    'serviceInstall': 'دامەزراندن',
    'serviceInstallBody': 'دامەزراندنی پیشەیی، وایەرینگ، ڕێکخستن و دەستپێکردنی سیستەم.',
    'serviceClean': 'چاککردنەوە و پاککردن',
    'serviceCleanBody': 'بە پشکنین، پاککردن و چاککردنەوەی بەردەوام کارایی پانێڵە خۆرەکانت بەرز بهێڵەوە.',
    'onGrid': 'On-Grid',
    'onGridBody': 'سیستەمێک کە بە تۆڕی کارەباوە پەیوەستە و بۆ کەمکردنەوەی بەکارهێنانی کارەبای تۆڕ لە ڕۆژدا گونجاوە.',
    'offGrid': 'Off-Grid',
    'offGridBody': 'سیستەمی خۆر و پاتری بۆ شوێنێک کە تۆڕی کارەبا نییە یان کارەباکەی جێگیر نییە.',
    'hybrid': 'Hybrid',
    'hybridBody': 'خۆر، پاتری و تۆڕی کارەبا پێکەوە کار دەکەن تا کارەبا جێگیرتر بێت و لە کاتی پچڕان پشتیوانی هەبێت.',
    'whySizing': 'قەبارەکردنی پیشەیی سیستەم',
    'whySizingBody': 'قەبارەی سیستەم بە پێی باری ڕاستەقینەی کارەباکەت دیاری دەکەین.',
    'whyQuality': 'ئامێری کوالیتی',
    'whyQualityBody': 'سیستەم لەسەر پانێڵ، ئینڤێرتەر و پاتریی براندە متمانەپێکراوەکان بنیات دەنێین.',
    'whySupport': 'پشتیوانی ناوخۆیی لە هەولێر',
    'whySupportBody': 'پشتیوانی بۆ دامەزراندن، کێشەچارەسەرکردن، پاککردن و چاککردنەوە.',
    'whyPrice': 'نرخدانانی ڕوون',
    'whyPriceBody': 'پێشنیاری سیستەم و نرخی گونجاو بە پێی پێداویستی و بودجەکەت.',
    'productSub': 'وێنە و زانیاریی ڕاستەقینەی بەرهەمەکان',
    'searchProduct': 'بەدوای مۆدێل یان بەرهەم بگەڕێ…',
    'all': 'هەمووی',
    'panel': 'پانێڵ',
    'inverter': 'ئینڤێرتەر',
    'battery': 'پاتری',
    'warranty': 'گەرەنتی',
    'datasheet': 'داتاشیتی فەرمی',
    'askWhatsapp': 'لە WhatsApp پرسیار بکە',
    'specifications': 'زانیاریی تەکنیکی',
    'calcSub': 'یاسا و نرخەکانی Alo Solar Energy',
    'dayLoad': 'باری ڕۆژ (ئەمپێر)',
    'nightLoad': 'باری شەو (ئەمپێر)',
    'phase': 'فاز',
    'singlePhase': 'یەک فاز',
    'threePhase': 'سێ فاز',
    'quality': 'کوالیتی',
    'highQuality': 'کوالیتی بەرز',
    'mediumQuality': 'کوالیتی ناوەند',
    'standardQuality': 'کوالیتی ستاندارد',
    'transport': 'گواستنەوە',
    'localErbil': 'ناو هەولێر — \$50',
    'outsideErbil': 'دەرەوەی هەولێر — \$75',
    'recommend': 'سیستەمم پێشنیار بکە',
    'enterDay': 'تکایە ئەمپێری ڕۆژ بنووسە',
    'recommendedSystem': 'سیستەمی پێشنیارکراو',
    'panels': 'پانێڵەکان',
    'protection': 'پاراستن',
    'nightBackup': 'پشتیوانی شەو',
    'estimatedPrice': 'نرخی خەمڵێنراو',
    'priceNote': 'ئەم نرخە تەنها خەمڵاندنە. دیزاین و نرخنامەی کۆتایی دوای پشکنینی شوێن و کارەبا لەلایەن Alo Solar Energy پشتڕاست دەکرێتەوە.',
    'noBattery': 'بێ پاتری',
    'hours75': '7.5 کاتژمێر',
    'evSub': 'ماڵ • بازرگانی • شەحنی خێرا',
    'evChargers': 'شەحنکەرەکانی EV',
    'findEv': 'شەحنکەری گونجاوت بدۆزەوە',
    'chargingCalculator': 'حیسابکەری شەحن',
    'chargingEstimate': 'خەمڵاندنی کاتی شەحن',
    'batteryKwh': 'پاتری kWh',
    'chargerKw': 'شەحنکەر kW',
    'currentPercent': 'ئاستی ئێستا %',
    'targetPercent': 'ئاستی ئامانج %',
    'calculateCharging': 'کاتی شەحن حیساب بکە',
    'hours': 'کاتژمێر',
    'aiSub': 'پەیوەست بە AI ـی Alo Solar Energy',
    'aiWelcome': 'سڵاو 👋 من AI Assistant ـی Alo Solar Energy ـم. دەتوانم لەسەر سیستەمی خۆر، بەرهەمەکان، حیسابکەر و EV Charge یارمەتیت بدەم.',
    'askHint': 'پرسیارەکەت بنووسە…',
    'aiOffline': 'AI ـەکە ئێستا پەیوەندی نییە. تکایە دواتر هەوڵبدەرەوە.',
    'whichSystem': 'کام سیستەم بۆ من باشە؟',
    'moreSub': 'هەموو بەشەکانی Alo لە ناو ئەپ',
    'monitoring': 'مۆنیتەرینگ',
    'monitoringSub': 'دۆخی سیستەم و داتای وزە',
    'dealerArea': 'بەشی فرۆشیار',
    'dealerSub': 'هەژمار، نرخ و داواکارییەکان',
    'installer': 'پشتڕاستکردنەوەی وەستا',
    'installerSub': 'QR و زانیاریی وەستای دامەزراندن',
    'contact': 'پەیوەندی',
    'contactSub': 'تەلەفۆن، WhatsApp، ئیمەیڵ و ناونیشان',
    'language': 'زمان',
    'languageSub': 'زمانی تەواوی ئەپ بگۆڕە',
    'kurdish': 'کوردی',
    'arabic': 'عەرەبی',
    'english': 'ئینگلیزی',
    'nativeOnly': 'ئەم بەشە لە ناو خودی ئەپ دەکرێتەوە.',
    'notLinked': 'هیچ سیستەمێکی مۆنیتەرینگ بە هەژمارەکەت نەبەستراوە.',
    'connectSystem': 'بۆ بەستنەوەی سیستەم پەیوەندیمان پێوە بکە',
    'dealerLogin': 'چوونەژوورەوەی فرۆشیار',
    'username': 'ناوی بەکارهێنەر',
    'password': 'وشەی نهێنی',
    'login': 'چوونەژوورەوە',
    'dealerApiNote': 'دیزاینی ئەم بەشە native ـە؛ پەیوەستکردنی login بە backend ـی فرۆشیار لە هەمان ئەپدا دەکرێت.',
    'registerDealer': 'دروستکردنی هەژماری فرۆشیار',
    'forgotPassword': 'وشەی نهێنیت لەبیر کردووە؟',
    'fullName': 'ناوی تەواو',
    'business': 'ناوی کۆمپانیا / دوکان',
    'city': 'شار',
    'submitApplication': 'ناردنی داواکاری',
    'pendingApproval': 'داواکارییەکەت چاوەڕێی پەسەندکردنی ئەدمینە.',
    'loginFailed': 'چوونەژوورەوە سەرکەوتوو نەبوو.',
    'dealerDashboard': 'داشبۆردی فرۆشیار',
    'catalog': 'کاتەلۆگی فرۆشیار',
    'rewards': 'Cashback',
    'announcements': 'ئاگادارکردنەوەکان',
    'profile': 'هەژمار',
    'logout': 'چوونەدەرەوە',
    'tradePrice': 'نرخی فرۆشیار',
    'retailPrice': 'نرخی ئاسایی',
    'cart': 'سەبەتە',
    'sendOrder': 'ناردنی داواکاری بە WhatsApp',
    'emptyCart': 'هیچ بەرهەمێک هەڵنەبژێردراوە.',
    'cashbackProgress': 'پێشکەوتنی Cashback',
    'memberId': 'ناسنامەی ئەندام',
    'refresh': 'نوێکردنەوە',
    'applicationSent': 'داواکارییەکەت نێردرا. دوای پەسەندکردن دەتوانیت بچیتە ژوورەوە.',
    'resetViaWhatsapp': 'بۆ نوێکردنەوەی وشەی نهێنی لە WhatsApp پەیوەندیمان پێوە بکە.',
    'verifyInstaller': 'پشتڕاستکردنەوەی وەستا',
    'installerCode': 'کۆدی QR / کۆدی وەستا / ژمارەی ALO',
    'verify': 'پشتڕاست بکەرەوە',
    'verifyNote': 'کۆدی وەستا یان لینکی QR بنووسە؛ پشتڕاستکردنەوە لە ناو خودی ئەپ ئەنجام دەدرێت.',
    'registerInstaller': 'خۆتۆمارکردنی وەستا',
    'verifyValid': 'وەستا پشتڕاستکرایەوە',
    'verifyInvalid': 'کۆدەکە دروست نییە یان وەستا چالاک نییە.',
    'installerName': 'ناوی وەستا',
    'approvedDate': 'بەرواری پەسەندکردن',
    'loggedInAlready': 'هەژمارەکەت هێشتا داخڵە.',
    'continueDashboard': 'بەردەوامبوون بۆ داشبۆرد',
    'checkingSession': 'دۆخی هەژمار پشکنین دەکرێت…',
    'companyInfo': 'زانیاریی کۆمپانیا',
    'phone': 'تەلەفۆن',
    'email': 'ئیمەیڵ',
    'location': 'ناونیشان',
    'pdfLoading': 'داتاشیت بار دەکرێت…',
    'pdfError': 'داتاشیت نەکرا بکرێتەوە. تکایە پەیوەندی بە Alo Solar Energy بکە.',
    'emailCopied': 'ئیمەیڵ کۆپی کرا.',
    'yourPowerFuture': 'Your Power • Your Future',
  },
  'ar': {
    'home': 'الرئيسية',
    'products': 'المنتجات',
    'calculator': 'الحاسبة',
    'ev': 'شحن EV',
    'ai': 'المساعد الذكي',
    'more': 'المزيد',
    'companySub': 'أربيل • طاقة شمسية • بطاريات • EV',
    'heroEyebrow': 'طاقة نظيفة • اختيار ذكي',
    'heroTitle': 'ابنِ مستقبلاً أكثر إشراقاً بالطاقة الشمسية.',
    'heroBody': 'في Alo Solar Energy نوفر أنظمة طاقة شمسية مناسبة للمنازل والأعمال، من التصميم واختيار المعدات إلى التركيب وخدمة ما بعد البيع.',
    'calculateSystem': 'احسب نظامك',
    'energyIndependence': 'استقلالية الطاقة',
    'systemOptions': 'خيارات الأنظمة',
    'whatWeDo': 'ماذا نقدم',
    'allSolarServices': 'جميع خدمات الطاقة الشمسية',
    'solutions': 'الحلول',
    'solutionSub': 'النظام المناسب لاحتياجك',
    'whyAlo': 'لماذا Alo Solar Energy',
    'whySub': 'مصمم لطاقة يمكن الاعتماد عليها.',
    'visitAlo': 'زيارة Alo Solar Energy',
    'address': 'أربيل – نيو أربيل – مقابل جامع سيد جعفر',
    'serviceDesign': 'تصميم أنظمة الطاقة الشمسية',
    'serviceDesignBody': 'نحدد الألواح والإنفرتر والبطارية حسب الاستهلاك الفعلي واحتياجات الموقع.',
    'serviceHybrid': 'Hybrid و Off-Grid',
    'serviceHybridBody': 'أنظمة مدعومة بالبطاريات لاستمرار الأحمال المهمة وتقليل الاعتماد على الشبكة.',
    'serviceCommercial': 'الطاقة الشمسية التجارية',
    'serviceCommercialBody': 'حلول مناسبة للمحلات والمكاتب والمصانع والمزارع والأعمال.',
    'serviceHome': 'الطاقة الشمسية المنزلية',
    'serviceHomeBody': 'أنظمة أسطح ذكية حسب احتياج المنزل اليومي من الكهرباء.',
    'serviceInstall': 'التركيب',
    'serviceInstallBody': 'تركيب احترافي وتمديدات وضبط وتشغيل النظام.',
    'serviceClean': 'الصيانة والتنظيف',
    'serviceCleanBody': 'حافظ على كفاءة الألواح بالفحص والتنظيف والصيانة المنتظمة.',
    'onGrid': 'On-Grid',
    'onGridBody': 'نظام متصل بالشبكة لتقليل استهلاك كهرباء الشبكة خلال النهار.',
    'offGrid': 'Off-Grid',
    'offGridBody': 'نظام شمسي مع بطارية للمواقع بدون شبكة أو ذات كهرباء غير مستقرة.',
    'hybrid': 'Hybrid',
    'hybridBody': 'تعمل الطاقة الشمسية والبطارية والشبكة معاً لتوفير طاقة أكثر استقراراً واحتياطاً عند الانقطاع.',
    'whySizing': 'تحديد احترافي لحجم النظام',
    'whySizingBody': 'نحدد حجم النظام بناءً على الحمل الكهربائي الفعلي.',
    'whyQuality': 'معدات عالية الجودة',
    'whyQualityBody': 'نبني الأنظمة باستخدام ألواح وإنفرترات وبطاريات من علامات موثوقة.',
    'whySupport': 'دعم محلي في أربيل',
    'whySupportBody': 'دعم للتركيب وحل المشاكل والتنظيف والصيانة.',
    'whyPrice': 'تسعير واضح',
    'whyPriceBody': 'اقتراح نظام وسعر مناسب حسب الاحتياج والميزانية.',
    'productSub': 'صور ومعلومات حقيقية للمنتجات',
    'searchProduct': 'ابحث عن موديل أو منتج…',
    'all': 'الكل',
    'panel': 'لوح',
    'inverter': 'إنفرتر',
    'battery': 'بطارية',
    'warranty': 'الضمان',
    'datasheet': 'البيانات الفنية الرسمية',
    'askWhatsapp': 'اسأل عبر WhatsApp',
    'specifications': 'المواصفات الفنية',
    'calcSub': 'قواعد وأسعار Alo Solar Energy',
    'dayLoad': 'حمل النهار (أمبير)',
    'nightLoad': 'حمل الليل (أمبير)',
    'phase': 'الفاز',
    'singlePhase': 'فاز واحد',
    'threePhase': 'ثلاثة فاز',
    'quality': 'الجودة',
    'highQuality': 'جودة عالية',
    'mediumQuality': 'جودة متوسطة',
    'standardQuality': 'جودة قياسية',
    'transport': 'النقل',
    'localErbil': 'داخل أربيل — \$50',
    'outsideErbil': 'خارج أربيل — \$75',
    'recommend': 'اقترح نظامي',
    'enterDay': 'أدخل أمبير النهار',
    'recommendedSystem': 'النظام المقترح',
    'panels': 'الألواح',
    'protection': 'الحماية',
    'nightBackup': 'احتياط الليل',
    'estimatedPrice': 'السعر التقديري',
    'priceNote': 'هذا السعر تقديري فقط. يتم تأكيد التصميم والعرض النهائي من Alo Solar Energy بعد مراجعة الموقع والكهرباء.',
    'noBattery': 'بدون بطارية',
    'hours75': '7.5 ساعات',
    'evSub': 'منزلي • تجاري • شحن سريع',
    'evChargers': 'شواحن EV',
    'findEv': 'اعثر على الشاحن المناسب',
    'chargingCalculator': 'حاسبة الشحن',
    'chargingEstimate': 'تقدير وقت الشحن',
    'batteryKwh': 'البطارية kWh',
    'chargerKw': 'الشاحن kW',
    'currentPercent': 'النسبة الحالية %',
    'targetPercent': 'النسبة المطلوبة %',
    'calculateCharging': 'احسب وقت الشحن',
    'hours': 'ساعات',
    'aiSub': 'متصل بذكاء Alo Solar Energy',
    'aiWelcome': 'مرحباً 👋 أنا المساعد الذكي لـ Alo Solar Energy. أستطيع مساعدتك في الأنظمة الشمسية والمنتجات والحاسبة وشحن EV.',
    'askHint': 'اكتب سؤالك…',
    'aiOffline': 'خدمة الذكاء غير متاحة الآن. حاول مرة أخرى لاحقاً.',
    'whichSystem': 'ما النظام المناسب لي؟',
    'moreSub': 'جميع أقسام Alo داخل التطبيق',
    'monitoring': 'المراقبة',
    'monitoringSub': 'حالة النظام وبيانات الطاقة',
    'dealerArea': 'منطقة التجار',
    'dealerSub': 'الحساب والأسعار والطلبات',
    'installer': 'التحقق من الفني',
    'installerSub': 'QR ومعلومات فني التركيب',
    'contact': 'اتصل بنا',
    'contactSub': 'هاتف وWhatsApp وبريد وعنوان',
    'language': 'اللغة',
    'languageSub': 'غيّر لغة التطبيق بالكامل',
    'kurdish': 'الكردية',
    'arabic': 'العربية',
    'english': 'English',
    'nativeOnly': 'هذا القسم يفتح داخل التطبيق نفسه.',
    'notLinked': 'لا يوجد نظام مراقبة مرتبط بحسابك حالياً.',
    'connectSystem': 'اتصل بنا لربط النظام',
    'dealerLogin': 'دخول التاجر',
    'username': 'اسم المستخدم',
    'password': 'كلمة المرور',
    'login': 'تسجيل الدخول',
    'dealerApiNote': 'واجهة هذا القسم Native؛ يمكن ربط تسجيل الدخول مباشرة بواجهة Backend الخاصة بالتجار داخل التطبيق.',
    'registerDealer': 'إنشاء حساب تاجر',
    'forgotPassword': 'نسيت كلمة المرور؟',
    'fullName': 'الاسم الكامل',
    'business': 'اسم الشركة / المتجر',
    'city': 'المدينة',
    'submitApplication': 'إرسال الطلب',
    'pendingApproval': 'طلبك بانتظار موافقة الإدارة.',
    'loginFailed': 'تعذر تسجيل الدخول.',
    'dealerDashboard': 'لوحة التاجر',
    'catalog': 'كتالوج التاجر',
    'rewards': 'Cashback',
    'announcements': 'الإعلانات',
    'profile': 'الحساب',
    'logout': 'تسجيل الخروج',
    'tradePrice': 'سعر التاجر',
    'retailPrice': 'السعر العادي',
    'cart': 'السلة',
    'sendOrder': 'إرسال الطلب عبر WhatsApp',
    'emptyCart': 'لم يتم اختيار أي منتج.',
    'cashbackProgress': 'تقدم Cashback',
    'memberId': 'رقم العضوية',
    'refresh': 'تحديث',
    'applicationSent': 'تم إرسال طلبك. يمكنك تسجيل الدخول بعد الموافقة.',
    'resetViaWhatsapp': 'لتغيير كلمة المرور تواصل معنا عبر WhatsApp.',
    'verifyInstaller': 'التحقق من الفني',
    'installerCode': 'رمز QR / رمز الفني',
    'verify': 'تحقق',
    'verifyNote': 'أدخل رمز الفني أو رابط QR؛ يتم التحقق داخل التطبيق نفسه.',
    'registerInstaller': 'تسجيل الفني',
    'verifyValid': 'تم التحقق من الفني',
    'verifyInvalid': 'الرمز غير صحيح أو حساب الفني غير نشط.',
    'installerName': 'اسم الفني',
    'approvedDate': 'تاريخ الاعتماد',
    'loggedInAlready': 'حسابك ما زال مسجلاً للدخول.',
    'continueDashboard': 'متابعة إلى لوحة التحكم',
    'checkingSession': 'جارٍ التحقق من الجلسة…',
    'companyInfo': 'معلومات الشركة',
    'phone': 'الهاتف',
    'email': 'البريد الإلكتروني',
    'location': 'العنوان',
    'pdfLoading': 'جارٍ تحميل ورقة البيانات…',
    'pdfError': 'تعذر فتح ورقة البيانات. يرجى التواصل مع Alo Solar Energy.',
    'emailCopied': 'تم نسخ البريد الإلكتروني.',
    'yourPowerFuture': 'Your Power • Your Future',
  },
  'en': {
    'home': 'Home',
    'products': 'Products',
    'calculator': 'Calculator',
    'ev': 'EV Charge',
    'ai': 'AI Assistant',
    'more': 'More',
    'companySub': 'Erbil • Solar • Battery • EV',
    'heroEyebrow': 'CLEAN ENERGY • SMART CHOICE',
    'heroTitle': 'Build a brighter future with solar energy.',
    'heroBody': 'Alo Solar Energy provides solar systems for homes and businesses, from system design and equipment selection to installation and after-sales support.',
    'calculateSystem': 'Calculate your system',
    'energyIndependence': 'Energy independence',
    'systemOptions': 'System options',
    'whatWeDo': 'What we do',
    'allSolarServices': 'Complete solar energy services',
    'solutions': 'Solutions',
    'solutionSub': 'The right system for your needs',
    'whyAlo': 'Why Alo Solar Energy',
    'whySub': 'Built for dependable energy.',
    'visitAlo': 'Visit Alo Solar Energy',
    'address': 'Erbil – New Erbil – Opposite Said Jaffar Mosque',
    'serviceDesign': 'Solar system design',
    'serviceDesignBody': 'We size panels, inverter and batteries according to real electrical use and site requirements.',
    'serviceHybrid': 'Hybrid & Off-Grid',
    'serviceHybridBody': 'Battery-backed systems for important loads and reduced dependence on the grid.',
    'serviceCommercial': 'Commercial solar',
    'serviceCommercialBody': 'Solar solutions for shops, offices, factories, farms and businesses.',
    'serviceHome': 'Residential solar',
    'serviceHomeBody': 'Smart rooftop systems sized for your home’s daily electricity needs.',
    'serviceInstall': 'Installation',
    'serviceInstallBody': 'Professional installation, wiring, configuration and commissioning.',
    'serviceClean': 'Maintenance & cleaning',
    'serviceCleanBody': 'Keep panel performance high with inspection, cleaning and maintenance.',
    'onGrid': 'On-Grid',
    'onGridBody': 'A grid-connected system designed to reduce daytime grid electricity use.',
    'offGrid': 'Off-Grid',
    'offGridBody': 'Solar and battery power for locations with no grid or unreliable electricity.',
    'hybrid': 'Hybrid',
    'hybridBody': 'Solar, battery and grid work together for more stable power and outage backup.',
    'whySizing': 'Professional system sizing',
    'whySizingBody': 'We size the system around your real electrical load.',
    'whyQuality': 'Quality equipment',
    'whyQualityBody': 'Systems are built around trusted panel, inverter and battery brands.',
    'whySupport': 'Local Erbil support',
    'whySupportBody': 'Support for installation, troubleshooting, cleaning and maintenance.',
    'whyPrice': 'Clear pricing',
    'whyPriceBody': 'A suitable system proposal and price based on your needs and budget.',
    'productSub': 'Real product images and technical data',
    'searchProduct': 'Search model or product…',
    'all': 'All',
    'panel': 'Panel',
    'inverter': 'Inverter',
    'battery': 'Battery',
    'warranty': 'Warranty',
    'datasheet': 'Official datasheet',
    'askWhatsapp': 'Ask on WhatsApp',
    'specifications': 'Technical specifications',
    'calcSub': 'Alo Solar Energy sizing & pricing rules',
    'dayLoad': 'Day load (Amps)',
    'nightLoad': 'Night load (Amps)',
    'phase': 'Electrical phase',
    'singlePhase': 'Single Phase',
    'threePhase': '3-Phase',
    'quality': 'Quality',
    'highQuality': 'High Quality',
    'mediumQuality': 'Medium Quality',
    'standardQuality': 'Standard Quality',
    'transport': 'Transport',
    'localErbil': 'Local Erbil — \$50',
    'outsideErbil': 'Outside Erbil — \$75',
    'recommend': 'Recommend My System',
    'enterDay': 'Enter day amps',
    'recommendedSystem': 'Recommended System',
    'panels': 'Panels',
    'protection': 'Protection',
    'nightBackup': 'Night backup',
    'estimatedPrice': 'Estimated price',
    'priceNote': 'Estimated price only. Final system design and quotation are confirmed by Alo Solar Energy after site and electrical review.',
    'noBattery': 'No Battery',
    'hours75': '7.5 hours',
    'evSub': 'Home • Business • Fast Charging',
    'evChargers': 'EV CHARGERS',
    'findEv': 'Find your EV charger',
    'chargingCalculator': 'EV CHARGING CALCULATOR',
    'chargingEstimate': 'Charging time estimate',
    'batteryKwh': 'Battery kWh',
    'chargerKw': 'Charger kW',
    'currentPercent': 'Current %',
    'targetPercent': 'Target %',
    'calculateCharging': 'Calculate charging',
    'hours': 'hours',
    'aiSub': 'Connected to Alo Solar Energy AI',
    'aiWelcome': 'Hello 👋 I am the Alo Solar Energy AI Assistant. I can help with solar systems, products, the calculator and EV charging.',
    'askHint': 'Write your question…',
    'aiOffline': 'AI is not available right now. Please try again later.',
    'whichSystem': 'Which system is right for me?',
    'moreSub': 'All Alo sections inside the app',
    'monitoring': 'Monitoring',
    'monitoringSub': 'System status and energy data',
    'dealerArea': 'Dealer Area',
    'dealerSub': 'Account, prices and orders',
    'installer': 'Installer Verification',
    'installerSub': 'QR and installer information',
    'contact': 'Contact',
    'contactSub': 'Phone, WhatsApp, email and address',
    'language': 'Language',
    'languageSub': 'Change the whole app language',
    'kurdish': 'Kurdish',
    'arabic': 'Arabic',
    'english': 'English',
    'nativeOnly': 'This section opens inside the app itself.',
    'notLinked': 'No monitoring system is linked to your account yet.',
    'connectSystem': 'Contact us to connect your system',
    'dealerLogin': 'Dealer Login',
    'username': 'Username',
    'password': 'Password',
    'login': 'Login',
    'dealerApiNote': 'This is a native screen. Dealer authentication can be connected directly to the backend inside the app.',
    'registerDealer': 'Create dealer account',
    'forgotPassword': 'Forgot password?',
    'fullName': 'Full name',
    'business': 'Company / shop',
    'city': 'City',
    'submitApplication': 'Submit application',
    'pendingApproval': 'Your application is waiting for admin approval.',
    'loginFailed': 'Login failed.',
    'dealerDashboard': 'Dealer Dashboard',
    'catalog': 'Dealer Catalog',
    'rewards': 'Cashback',
    'announcements': 'Announcements',
    'profile': 'Profile',
    'logout': 'Logout',
    'tradePrice': 'Dealer price',
    'retailPrice': 'Retail price',
    'cart': 'Cart',
    'sendOrder': 'Send order by WhatsApp',
    'emptyCart': 'No products selected.',
    'cashbackProgress': 'Cashback progress',
    'memberId': 'Member ID',
    'refresh': 'Refresh',
    'applicationSent': 'Your application was sent. You can log in after approval.',
    'resetViaWhatsapp': 'Contact us on WhatsApp to reset your password.',
    'verifyInstaller': 'Verify Installer',
    'installerCode': 'QR code / Installer code / ALO ID',
    'verify': 'Verify',
    'verifyNote': 'Enter the installer code or QR link; verification happens inside the app.',
    'registerInstaller': 'Register as installer',
    'verifyValid': 'Installer verified',
    'verifyInvalid': 'The code is invalid or the installer account is not active.',
    'installerName': 'Installer name',
    'approvedDate': 'Approved date',
    'loggedInAlready': 'Your account is still signed in.',
    'continueDashboard': 'Continue to dashboard',
    'checkingSession': 'Checking session…',
    'companyInfo': 'Company Information',
    'phone': 'Phone',
    'email': 'Email',
    'location': 'Location',
    'pdfLoading': 'Loading datasheet…',
    'pdfError': 'Could not open the datasheet. Please contact Alo Solar Energy.',
    'emailCopied': 'Email copied.',
    'yourPowerFuture': 'Your Power • Your Future',
  },
};

const Map<String, Map<String, String>> _extraTx = {
  'ku': {
    'easyMode':'Easy Mode','advancedMode':'Advanced Mode','calcLiveData':'نرخ و ڕێکخستنەکان لە داتای Alo نوێ دەکرێنەوە.','calcOfflineData':'پەیوەندی بە داتای نوێ نەبوو؛ داتای پاشەکەوتکراو بەکاردێت.','bestQuality':'باشترین','middleQuality':'ناوەند','basicQuality':'بنەڕەتی','roiSettings':'ڕێکخستنی ROI','sunHours':'کاتژمێری خۆری کاریگەر / ڕۆژ','gridTariff':'نرخی کارەبای تۆڕ (IQD/kWh)','fxRate':'نرخی 1 USD بە دینار','monthlyProduction':'بەرهەمی مانگانە','monthlySaving':'پارەی تۆڕی پاشەکەوتکراو','payback':'ماوەی گەڕانەوەی پارە','years':'ساڵ','priceBreakdown':'وردەکاری نرخ','structure':'ستراکچەر','installation':'دامەزراندن','otherElectrical':'کاری کارەبایی تر','batteryBusbar':'Battery Busbar','solarCable':'کەیبڵی Solar','acCable':'کەیبڵی AC','meters':'مەتر','quantity':'ژمارە','selectPanel':'پانێڵ هەڵبژێرە','selectInverter':'ئینڤێرتەر هەڵبژێرە','selectBattery':'پاتری هەڵبژێرە','noBatteryOption':'بێ پاتری','panelQty':'ژمارەی پانێڵ','inverterQty':'ژمارەی ئینڤێرتەر','batteryQty':'ژمارەی پاتری','solarCableM':'درێژی کەیبڵی Solar (m)','acCableM':'درێژی کەیبڵی AC (m)','calculate':'حیساب بکە','reset':'ڕیسێت','sendWhatsapp':'ناردن بۆ WhatsApp','systemTotal':'کۆی گشتی سیستەم','acBoard':'بۆردی AC','dcBoard':'بۆردی DC','equipment':'کەرەستە','services':'خزمەتگوزاری','invalidNumber':'تکایە ژمارەکان بە دروستی بنووسە.','configError':'داتای Calculator نوێ نەکرایەوە.','advancedSub':'هەڵبژاردنی وردی کەرەستە، ژمارە و کەیبڵ.','easySub':'ئەمپێری ڕۆژ و شەو بنووسە؛ سیستەم خۆکار پێشنیار دەکرێت.','batteryWarranty':'گەرەنتی پاتری','productionNote':'بەرهەم خەمڵاندنە و بە کەش و شوێن دەگۆڕێت.','noPayback':'—','loading':'چاوەڕێ بکە…','cashbackLabel':'2% Cashback','dealerOrder':'داواکاری فرۆشیار','overview':'پوختە','welcomeDealer':'بەخێربێیت','availableProducts':'بەرهەمە بەردەستەکان','selectedItems':'هەڵبژێردراوەکان','latestUpdate':'نوێترین ئاگادارکردنەوە','quickActions':'دەستگەیشتنی خێرا','searchProducts':'گەڕان لە بەرهەمەکان…','allCategories':'هەموو بەشەکان','orderSummary':'پوختەی داواکاری','clearCart':'پاککردنەوەی سەبەتە','noAnnouncements':'هیچ ئاگادارکردنەوەیەک نییە.','accountStatus':'دۆخی هەژمار','approved':'پەسەندکراو','cashbackRemaining':'ماوە بۆ Cashback','viewCatalog':'بینینی کاتەلۆگ','viewCart':'بینینی سەبەتە','dealerMember':'ئەندامی فرۆشیاری Alo','total':'کۆی گشتی'
  },
  'ar': {
    'easyMode':'الوضع السهل','advancedMode':'الوضع المتقدم','calcLiveData':'يتم تحديث الأسعار والإعدادات من بيانات Alo.','calcOfflineData':'تعذر تحديث البيانات؛ يتم استخدام النسخة الاحتياطية.','bestQuality':'الأفضل','middleQuality':'المتوسط','basicQuality':'الأساسي','roiSettings':'إعدادات ROI','sunHours':'ساعات الشمس الفعالة / يوم','gridTariff':'سعر كهرباء الشبكة (IQD/kWh)','fxRate':'قيمة 1 USD بالدينار','monthlyProduction':'الإنتاج الشهري','monthlySaving':'التوفير الشهري من الشبكة','payback':'مدة استرداد التكلفة','years':'سنة','priceBreakdown':'تفاصيل السعر','structure':'الهيكل','installation':'التركيب','otherElectrical':'أعمال كهربائية أخرى','batteryBusbar':'Battery Busbar','solarCable':'كابل Solar','acCable':'كابل AC','meters':'متر','quantity':'الكمية','selectPanel':'اختر اللوح','selectInverter':'اختر الإنفرتر','selectBattery':'اختر البطارية','noBatteryOption':'بدون بطارية','panelQty':'عدد الألواح','inverterQty':'عدد الإنفرترات','batteryQty':'عدد البطاريات','solarCableM':'طول كابل Solar (m)','acCableM':'طول كابل AC (m)','calculate':'احسب','reset':'إعادة تعيين','sendWhatsapp':'إرسال عبر WhatsApp','systemTotal':'إجمالي النظام','acBoard':'لوحة AC','dcBoard':'لوحة DC','equipment':'المعدات','services':'الخدمات','invalidNumber':'أدخل الأرقام بشكل صحيح.','configError':'تعذر تحديث بيانات الحاسبة.','advancedSub':'اختيار دقيق للمعدات والكميات والكابلات.','easySub':'أدخل أمبير النهار والليل وسيتم اقتراح النظام تلقائياً.','batteryWarranty':'ضمان البطارية','productionNote':'الإنتاج تقديري ويتغير حسب الطقس والموقع.','noPayback':'—','loading':'جاري التحميل…','cashbackLabel':'استرداد نقدي 2%','dealerOrder':'طلب التاجر','overview':'نظرة عامة','welcomeDealer':'مرحباً','availableProducts':'المنتجات المتاحة','selectedItems':'العناصر المختارة','latestUpdate':'آخر إعلان','quickActions':'وصول سريع','searchProducts':'ابحث في المنتجات…','allCategories':'كل الأقسام','orderSummary':'ملخص الطلب','clearCart':'إفراغ السلة','noAnnouncements':'لا توجد إعلانات حالياً.','accountStatus':'حالة الحساب','approved':'معتمد','cashbackRemaining':'المتبقي للـ Cashback','viewCatalog':'عرض الكتالوج','viewCart':'عرض السلة','dealerMember':'عضو تاجر Alo','total':'الإجمالي'
  },
  'en': {
    'easyMode':'Easy Mode','advancedMode':'Advanced Mode','calcLiveData':'Prices and settings are refreshed from Alo data.','calcOfflineData':'Live data could not be refreshed; the built-in backup is being used.','bestQuality':'Best','middleQuality':'Middle','basicQuality':'Basic','roiSettings':'ROI settings','sunHours':'Effective sun hours / day','gridTariff':'Grid tariff (IQD/kWh)','fxRate':'IQD per 1 USD','monthlyProduction':'Monthly production','monthlySaving':'Monthly grid saving','payback':'Estimated payback','years':'years','priceBreakdown':'Price breakdown','structure':'Structure','installation':'Installation','otherElectrical':'Other electrical work','batteryBusbar':'Battery busbar','solarCable':'Solar cable','acCable':'AC cable','meters':'meters','quantity':'Quantity','selectPanel':'Select panel','selectInverter':'Select inverter','selectBattery':'Select battery','noBatteryOption':'No battery','panelQty':'Panel quantity','inverterQty':'Inverter quantity','batteryQty':'Battery quantity','solarCableM':'Solar cable length (m)','acCableM':'AC cable length (m)','calculate':'Calculate','reset':'Reset','sendWhatsapp':'Send to WhatsApp','systemTotal':'System total','acBoard':'AC board','dcBoard':'DC board','equipment':'Equipment','services':'Services','invalidNumber':'Please enter valid numbers.','configError':'Calculator data could not be refreshed.','advancedSub':'Choose exact equipment, quantities and cable lengths.','easySub':'Enter day and night amps and the app will recommend the system.','batteryWarranty':'Battery warranty','productionNote':'Production is an estimate and varies by weather and site conditions.','noPayback':'—','loading':'Loading…','cashbackLabel':'2% Cashback','dealerOrder':'Dealer Order','overview':'Overview','welcomeDealer':'Welcome','availableProducts':'Available products','selectedItems':'Selected items','latestUpdate':'Latest update','quickActions':'Quick actions','searchProducts':'Search products…','allCategories':'All categories','orderSummary':'Order summary','clearCart':'Clear cart','noAnnouncements':'No announcements yet.','accountStatus':'Account status','approved':'Approved','cashbackRemaining':'Remaining for cashback','viewCatalog':'View catalog','viewCart':'View cart','dealerMember':'Alo dealer member','total':'Total'
  },
};

String tr(String key) => _extraTx[appLang.value]?[key] ?? _tx[appLang.value]?[key] ?? _extraTx['en']?[key] ?? _tx['en']?[key] ?? key;


const Map<String, Map<String, String>> _adminTx = {
  'ku': {
    'admin':'ئەدمین','adminSub':'بەڕێوەبردنی داواکاری وەستاکان','adminLogin':'چوونەژوورەوەی ئەدمین','adminDashboard':'کۆنترۆڵ سەنتەری ئەدمین',
    'username':'ناوی بەکارهێنەر','password':'وشەی نهێنی','login':'چوونەژوورەوە','twoFactorCode':'کۆدی 2FA (ئەگەر چالاکە)','adminLoginFailed':'چوونەژوورەوە سەرکەوتوو نەبوو.',
    'pending':'چاوەڕوان','approved':'پەسەندکراو','rejected':'ڕەتکراوە','disabled':'ناچالاک','all':'هەمووی','approve':'پەسەندکردن','reject':'ڕەتکردنەوە','disable':'ناچالاککردن','unban':'چالاککردنەوە',
    'noDealerRequests':'هیچ داواکارییەکی وەستا نییە.','registered':'تۆمارکراو','memberId':'Member ID','refresh':'نوێکردنەوە','logout':'چوونەدەرەوە',
    'approveConfirm':'دڵنیایت لە پەسەندکردنی ئەم وەستایە؟','rejectConfirm':'دڵنیایت لە ڕەتکردنەوەی ئەم داواکارییە؟','disableConfirm':'دڵنیایت لە ناچالاککردنی ئەم هەژمارە؟','unbanConfirm':'دڵنیایت لە چالاککردنەوەی ئەم هەژمارە؟','confirm':'دڵنیام','cancel':'پاشگەزبوونەوە','requestUpdated':'دۆخی داواکاری نوێکرایەوە.','searchInstaller':'گەڕان بەدوای وەستا…','purchases':'کڕینەکان','rewardTotal':'کڕینی ٢ مانگ','notificationCenter':'ناوەندی ئاگادارکردنەوە','notifications':'ئاگادارکردنەوەکان','appNotifications':'ئاگادارکردنەوەی ئەپ','dealerNotifications':'ئاگادارکردنەوەی وەستا','sendNotification':'ناردنی ئاگادارکردنەوە','notificationTitle':'ناونیشان','notificationMessage':'دەقی ئاگادارکردنەوە','audience':'وەرگر','appUsers':'بەکارهێنەرانی ئەپ','dealers':'وەستاکان','everyone':'هەمووان','noNotifications':'هیچ ئاگادارکردنەوەیەک نییە.','notificationSent':'ئاگادارکردنەوە نێردرا.','general':'گشتی','price':'نرخ','product':'بەرهەم','offer':'ئۆفەر'
  },
  'ar': {
    'admin':'الإدارة','adminSub':'إدارة طلبات الفنيين','adminLogin':'تسجيل دخول الإدارة','adminDashboard':'مركز تحكم الإدارة',
    'username':'اسم المستخدم','password':'كلمة المرور','login':'تسجيل الدخول','twoFactorCode':'رمز 2FA (إن كان مفعلاً)','adminLoginFailed':'فشل تسجيل الدخول.',
    'pending':'قيد الانتظار','approved':'معتمد','rejected':'مرفوض','disabled':'معطل','all':'الكل','approve':'موافقة','reject':'رفض','disable':'تعطيل','unban':'إعادة تفعيل',
    'noDealerRequests':'لا توجد طلبات فنيين.','registered':'تاريخ التسجيل','memberId':'رقم العضو','refresh':'تحديث','logout':'تسجيل الخروج',
    'approveConfirm':'هل تريد الموافقة على هذا الفني؟','rejectConfirm':'هل تريد رفض هذا الطلب؟','disableConfirm':'هل تريد تعطيل هذا الحساب؟','unbanConfirm':'هل تريد إعادة تفعيل هذا الحساب؟','confirm':'تأكيد','cancel':'إلغاء','requestUpdated':'تم تحديث حالة الطلب.','searchInstaller':'ابحث عن فني…','purchases':'المشتريات','rewardTotal':'مشتريات شهرين','notificationCenter':'مركز الإشعارات','notifications':'الإشعارات','appNotifications':'إشعارات التطبيق','dealerNotifications':'إشعارات الفنيين','sendNotification':'إرسال إشعار','notificationTitle':'العنوان','notificationMessage':'نص الإشعار','audience':'الجمهور','appUsers':'مستخدمو التطبيق','dealers':'الفنيون','everyone':'الجميع','noNotifications':'لا توجد إشعارات.','notificationSent':'تم إرسال الإشعار.','general':'عام','price':'سعر','product':'منتج','offer':'عرض'
  },
  'en': {
    'admin':'Admin','adminSub':'Manage installer requests','adminLogin':'Admin login','adminDashboard':'Admin Control Center',
    'username':'Username','password':'Password','login':'Login','twoFactorCode':'2FA code (if enabled)','adminLoginFailed':'Admin login failed.',
    'pending':'Pending','approved':'Approved','rejected':'Rejected','disabled':'Disabled','all':'All','approve':'Approve','reject':'Reject','disable':'Disable','unban':'Unban',
    'noDealerRequests':'No installer requests.','registered':'Registered','memberId':'Member ID','refresh':'Refresh','logout':'Logout',
    'approveConfirm':'Approve this installer?','rejectConfirm':'Reject this request?','disableConfirm':'Disable this account?','unbanConfirm':'Reactivate this account?','confirm':'Confirm','cancel':'Cancel','requestUpdated':'Request status updated.','searchInstaller':'Search installers…','purchases':'Purchases','rewardTotal':'2-month purchases','notificationCenter':'Notification Center','notifications':'Notifications','appNotifications':'App notifications','dealerNotifications':'Installer notifications','sendNotification':'Send notification','notificationTitle':'Title','notificationMessage':'Notification message','audience':'Audience','appUsers':'App users','dealers':'Installers','everyone':'Everyone','noNotifications':'No notifications yet.','notificationSent':'Notification sent.','general':'General','price':'Price','product':'Product','offer':'Offer'
  },
};
String atr(String key) => _adminTx[appLang.value]?[key] ?? _adminTx['en']?[key] ?? key;

class _DealerApiResponse {
  final int status;
  final Map<String, dynamic> data;
  const _DealerApiResponse(this.status, this.data);
  bool get ok => status >= 200 && status < 300;
}

class DealerApi {
  DealerApi._();
  static final DealerApi instance = DealerApi._();
  static const _sessionKey = 'alo_installer_session_cookie';
  String? _cookie;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_sessionKey);
    if (saved != null && saved.startsWith('alo_installer_session=') && saved.length > 30) {
      _cookie = saved;
    }
  }

  Future<void> _saveCookie(String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null || value.isEmpty) {
      await prefs.remove(_sessionKey);
    } else {
      await prefs.setString(_sessionKey, value);
    }
  }

  Map<String, String> get _headers => {
        'content-type': 'application/json',
        'accept': 'application/json',
        if (_cookie != null) 'cookie': _cookie!,
      };

  Future<_DealerApiResponse> _request(String path, {String method = 'GET', Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$kSite/api/portal$path');
    late http.Response response;
    if (method == 'POST') {
      response = await http.post(uri, headers: _headers, body: jsonEncode(body ?? {}));
    } else {
      response = await http.get(uri, headers: _headers);
    }
    final setCookie = response.headers['set-cookie'];
    if (setCookie != null && setCookie.contains('alo_installer_session=')) {
      final match = RegExp(r'alo_installer_session=([^;]+)').firstMatch(setCookie);
      if (match != null && (match.group(1)?.isNotEmpty ?? false)) {
        _cookie = 'alo_installer_session=${match.group(1)}';
        await _saveCookie(_cookie);
      }
    }
    Map<String, dynamic> data = {};
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) data = decoded;
    } catch (_) {}
    return _DealerApiResponse(response.statusCode, data);
  }

  Future<_DealerApiResponse> login(String username, String password) =>
      _request('/login', method: 'POST', body: {'username': username, 'password': password});
  Future<_DealerApiResponse> register(Map<String, dynamic> data) => _request('/register', method: 'POST', body: data);
  Future<_DealerApiResponse> me() => _request('/me');
  Future<_DealerApiResponse> products() => _request('/products');
  Future<_DealerApiResponse> rewards() => _request('/rewards');
  Future<_DealerApiResponse> announcements() => _request('/announcements');
  Future<_DealerApiResponse> verifyInstaller(String rawCode) {
    var code = rawCode.trim();
    final parsed = Uri.tryParse(code);
    if (parsed != null) {
      final q = (parsed.queryParameters['code'] ?? '').trim();
      if (q.isNotEmpty) {
        code = q;
      } else if (parsed.pathSegments.isNotEmpty) {
        final last = parsed.pathSegments.last.trim();
        if (last.isNotEmpty) code = last;
      }
    }

    const digitMap = <String, String>{
      '٠':'0','١':'1','٢':'2','٣':'3','٤':'4','٥':'5','٦':'6','٧':'7','٨':'8','٩':'9',
      '۰':'0','۱':'1','۲':'2','۳':'3','۴':'4','۵':'5','۶':'6','۷':'7','۸':'8','۹':'9',
    };
    code = code
        .split('')
        .map((ch) => digitMap[ch] ?? ch)
        .join()
        .replaceAll(RegExp(r'[\u200E\u200F\u202A-\u202E\u2066-\u2069]'), '')
        .trim();

    final hex = RegExp(r'[a-fA-F0-9]{32}').firstMatch(code);
    if (hex != null) {
      code = hex.group(0)!.toLowerCase();
    } else {
      final compact = code.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
      final member = RegExp(r'^ALO0*(\d{1,9})$').firstMatch(compact);
      final plain = RegExp(r'^(\d{1,9})$').firstMatch(compact);
      final digits = member?.group(1) ?? plain?.group(1);
      if (digits != null && digits.isNotEmpty) {
        code = 'ALO-${digits.padLeft(6, '0')}';
      }
    }

    return _request('/verify?code=${Uri.encodeQueryComponent(code)}');
  }
  Future<void> logout() async {
    try { await _request('/logout', method: 'POST'); } catch (_) {}
    _cookie = null;
    await _saveCookie(null);
  }
}


class AdminApi {
  AdminApi._();
  static final AdminApi instance = AdminApi._();
  static const _tokenKey = 'alo_admin_session_token';
  static const _baseKey = 'alo_admin_session_base';
  String? _token;
  String? _activeBase;

  bool get hasSession => _token != null && _token!.isNotEmpty;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString(_tokenKey);
    final savedBase = prefs.getString(_baseKey);
    if (savedToken != null && savedToken.length >= 40) {
      _token = savedToken;
      _activeBase = (savedBase != null && savedBase.startsWith('https://'))
          ? savedBase
          : 'https://alo-installers-site.pages.dev';
    }
  }

  Future<void> _saveSession(String? token, String? base) async {
    final prefs = await SharedPreferences.getInstance();
    if (token == null || token.isEmpty || base == null || base.isEmpty) {
      await prefs.remove(_tokenKey);
      await prefs.remove(_baseKey);
    } else {
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_baseKey, base);
    }
  }

  Map<String, String> _headersFor(Uri uri) => {
        'content-type': 'application/json',
        'accept': 'application/json',
        'origin': '${uri.scheme}://${uri.authority}',
        if (_token != null) 'authorization': 'Bearer $_token',
      };

  Future<http.Response> _sendPreservingRedirects(
    Uri initialUri, {
    required String method,
    required String payload,
  }) async {
    var uri = initialUri;
    for (var hop = 0; hop < 6; hop++) {
      final request = http.Request(method, uri)
        ..followRedirects = false
        ..maxRedirects = 0
        ..headers.addAll(_headersFor(uri));
      if (method != 'GET' && method != 'HEAD') {
        request.body = payload;
      }

      final streamed = await http.Client().send(request).timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamed);
      final code = response.statusCode;
      if (![301, 302, 303, 307, 308].contains(code)) return response;

      final location = response.headers['location'];
      if (location == null || location.trim().isEmpty) return response;
      uri = uri.resolve(location.trim());
    }
    return http.Response('{"error":"Too many redirects."}', 598,
        headers: {'content-type': 'application/json'});
  }

  Future<_DealerApiResponse> _request(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? body,
    bool allowFallback = false,
  }) async {
    const defaultBase = 'https://alo-installers-site.pages.dev';
    const fallbackBase = 'https://alosolarenergy.com';
    final bases = <String>[
      _activeBase ?? defaultBase,
      if (allowFallback && (_activeBase ?? defaultBase) != fallbackBase) fallbackBase,
    ];

    http.Response? response;
    String? responseBase;
    final payload = jsonEncode(body ?? {});

    for (final base in bases) {
      final uri = Uri.parse('$base/api/portal$path');
      try {
        response = await _sendPreservingRedirects(
          uri,
          method: method,
          payload: payload,
        );
        responseBase = base;
      } catch (_) {
        response = null;
        responseBase = null;
      }
      if (response != null &&
          response.statusCode != 404 &&
          response.statusCode != 405 &&
          response.statusCode != 598 &&
          response.statusCode != 599) {
        break;
      }
    }

    response ??= http.Response('{"error":"Cannot connect to Alo backend."}', 599,
        headers: {'content-type': 'application/json'});

    Map<String, dynamic> data = {};
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) data = decoded;
    } catch (_) {}

    final sessionToken = data['sessionToken']?.toString();
    if (response.statusCode >= 200 && response.statusCode < 300 &&
        sessionToken != null && sessionToken.length >= 40 && responseBase != null) {
      _token = sessionToken;
      _activeBase = responseBase;
      await _saveSession(_token, _activeBase);
    }

    if (response.statusCode == 401 && path != '/mobile-admin/login') {
      _token = null;
      await _saveSession(null, null);
    }

    return _DealerApiResponse(response.statusCode, data);
  }

  Future<_DealerApiResponse> login(String u, String p, {String totp = ''}) =>
      _request('/mobile-admin/login', method: 'POST', body: {
        'username': u,
        'password': p,
        'totpCode': totp,
      }, allowFallback: true);

  Future<_DealerApiResponse> me() => _request('/mobile-admin/me');
  Future<_DealerApiResponse> applications() =>
      _request('/mobile-admin/applications');
  Future<_DealerApiResponse> applicationAction(int id, String action) =>
      _request('/mobile-admin/applications', method: 'POST', body: {
        'id': id,
        'action': action,
      });

  Future<_DealerApiResponse> notifications() =>
      _request('/mobile-admin/notifications');

  Future<_DealerApiResponse> sendNotification(
    String title,
    String message,
    String kind,
    String audience,
  ) =>
      _request('/mobile-admin/notifications', method: 'POST', body: {
        'title': title,
        'message': message,
        'kind': kind,
        'audience': audience,
      });

  Future<_DealerApiResponse> publicNotifications() =>
      _request('/app/announcements', allowFallback: true);

  Future<void> logout() async {
    try {
      await _request('/mobile-admin/logout', method: 'POST');
    } catch (_) {}
    _token = null;
    _activeBase = null;
    await _saveSession(null, null);
  }
}

bool get rtl => appLang.value != 'en';

class AloApp extends StatelessWidget {
  const AloApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLang,
      builder: (_, lang, __) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Alo Solar Energy',
        locale: Locale(lang == 'en' ? 'en' : 'ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: kBg,
          colorScheme: const ColorScheme.dark(primary: kGreen, secondary: kGreen2, surface: kSurface),
          useMaterial3: true,
          fontFamilyFallback: const ['Noto Sans Arabic', 'Arial'],
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF081A13),
            foregroundColor: kText,
            surfaceTintColor: Colors.transparent,
            centerTitle: false,
            elevation: 0,
            titleTextStyle: TextStyle(color: kText, fontSize: 18, fontWeight: FontWeight.w900),
          ),
          cardTheme: CardThemeData(
            color: const Color(0xFF0B2119),
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: const BorderSide(color: Color(0xFF1B4838)),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF102D23),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            labelStyle: const TextStyle(color: kMuted, fontWeight: FontWeight.w700),
            hintStyle: TextStyle(color: kMuted.withValues(alpha: .72)),
            prefixIconColor: kGreen2,
            suffixIconColor: kGreen2,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFF245545))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: kGreen, width: 1.7)),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: kGreen,
              foregroundColor: const Color(0xFF032016),
              minimumSize: const Size(0, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              textStyle: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: kGreen2,
              minimumSize: const Size(0, 50),
              side: const BorderSide(color: Color(0xFF39745C)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: const Color(0xFF102D23),
            side: const BorderSide(color: Color(0xFF285640)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            labelStyle: const TextStyle(color: kText, fontWeight: FontWeight.w700),
          ),
          dividerTheme: const DividerThemeData(color: Color(0xFF1A4033), thickness: 1),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            indicatorColor: kGreen.withValues(alpha: .18),
            height: 70,
            iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
              color: states.contains(WidgetState.selected) ? kGreen : kMuted,
              size: states.contains(WidgetState.selected) ? 25 : 23,
            )),
            labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
              color: states.contains(WidgetState.selected) ? kGreen2 : kMuted,
              fontSize: 10.5,
              fontWeight: states.contains(WidgetState.selected) ? FontWeight.w900 : FontWeight.w700,
            )),
          ),
        ),
        builder: (context, child) => Directionality(
          textDirection: lang == 'en' ? TextDirection.ltr : TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        ),
        home: const Splash(),
      ),
    );
  }
}

class Splash extends StatefulWidget {
  const Splash({super.key});
  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..forward();
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1900), () {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Shell()));
    });
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF09221A), Color(0xFF06140F), Color(0xFF04100B)],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(child: AnimatedBuilder(animation: c, builder: (_, __) => CustomPaint(painter: GlowPainter(c.value)))),
              Positioned(
                top: -80,
                right: -40,
                child: Opacity(
                  opacity: .15,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [Color(0xFFD8B94B), Colors.transparent]),
                    ),
                  ),
                ),
              ),
              Center(
                child: FadeTransition(
                  opacity: CurvedAnimation(parent: c, curve: const Interval(.08, 1)),
                  child: ScaleTransition(
                    scale: Tween(begin: .92, end: 1.0).animate(CurvedAnimation(parent: c, curve: Curves.easeOutBack)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              color: Colors.white.withValues(alpha: .03),
                              border: Border.all(color: Colors.white.withValues(alpha: .08)),
                              boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 30, offset: Offset(0, 12))],
                            ),
                            child: Image.asset('assets/images/alo_logo.png', width: 240, fit: BoxFit.contain),
                          ),
                          const SizedBox(height: 22),
                          Text('Alo Solar Energy', textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: .3)),
                          const SizedBox(height: 8),
                          Text(tr('yourPowerFuture'), textAlign: TextAlign.center, style: const TextStyle(color: kGreen2, fontWeight: FontWeight.w800, letterSpacing: .5)),
                          const SizedBox(height: 22),
                          SizedBox(
                            width: 140,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(99),
                              child: LinearProgressIndicator(
                                minHeight: 5,
                                valueColor: const AlwaysStoppedAnimation(kGreen),
                                backgroundColor: Colors.white12,
                                value: c.value,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class GlowPainter extends CustomPainter {
  final double t;
  GlowPainter(this.t);
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..shader = RadialGradient(colors: [const Color(0xFFD8B94B).withValues(alpha: .22 * t), Colors.transparent]).createShader(
        Rect.fromCircle(center: Offset(s.width / 2, s.height * .43), radius: s.width * .7),
      );
    canvas.drawRect(Offset.zero & s, p);
  }

  @override
  bool shouldRepaint(covariant GlowPainter oldDelegate) => oldDelegate.t != t;
}

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int index = 0;
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<String>(
        valueListenable: appLang,
        builder: (_, lang, __) {
          final pages = <Widget>[
            KeyedSubtree(key: ValueKey('$lang-home'), child: const HomePage()),
            KeyedSubtree(key: ValueKey('$lang-products'), child: const ProductsPage()),
            KeyedSubtree(key: ValueKey('$lang-calculator'), child: const CalculatorPage()),
            KeyedSubtree(key: ValueKey('$lang-ev'), child: const EvPage()),
            KeyedSubtree(key: ValueKey('$lang-ai'), child: const AssistantPage()),
            KeyedSubtree(key: ValueKey('$lang-more'), child: const MorePage()),
          ];
          return Directionality(
            textDirection: lang == 'en' ? TextDirection.ltr : TextDirection.rtl,
            child: Scaffold(
              body: IndexedStack(index: index, children: pages),
              bottomNavigationBar: SafeArea(
                top: false,
                minimum: const EdgeInsets.fromLTRB(10, 0, 10, 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF081A13),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF1B4637)),
                    boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 22, offset: Offset(0, 8))],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: NavigationBar(
                    selectedIndex: index,
                    onDestinationSelected: (v) => setState(() => index = v),
                    destinations: [
                      NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home_rounded), label: tr('home')),
                      NavigationDestination(icon: const Icon(Icons.inventory_2_outlined), selectedIcon: const Icon(Icons.inventory_2_rounded), label: tr('products')),
                      NavigationDestination(icon: const Icon(Icons.calculate_outlined), selectedIcon: const Icon(Icons.calculate_rounded), label: tr('calculator')),
                      NavigationDestination(icon: const Icon(Icons.ev_station_outlined), selectedIcon: const Icon(Icons.ev_station_rounded), label: tr('ev')),
                      NavigationDestination(icon: const Icon(Icons.auto_awesome_outlined), selectedIcon: const Icon(Icons.auto_awesome_rounded), label: tr('ai')),
                      NavigationDestination(icon: const Icon(Icons.grid_view_rounded), selectedIcon: const Icon(Icons.grid_view_rounded), label: tr('more')),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
}
class PageHead extends StatelessWidget {
  final String title;
  final String? sub;
  const PageHead(this.title, {super.key, this.sub});
  @override
  Widget build(BuildContext context) => SafeArea(
        bottom: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(10, 8, 10, 6),
          padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF0D281F), Color(0xFF081A13)]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF1E4B3A)),
          ),
          child: Row(
            children: [
              Container(
                width: 66,
                height: 44,
                padding: const EdgeInsets.all(3),
                child: Image.asset('assets/images/alo_logo.png', fit: BoxFit.contain),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                    if (sub != null) Text(sub!, style: const TextStyle(color: kMuted, fontSize: 11)),
                  ],
                ),
              ),
              const LanguageMenu(compact: true),
            ],
          ),
        ),
      );
}

class LanguageMenu extends StatelessWidget {
  final bool compact;
  const LanguageMenu({super.key, this.compact = false});
  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
        tooltip: tr('language'),
        initialValue: appLang.value,
        onSelected: (v) => appLang.value = v,
        itemBuilder: (_) => [
          PopupMenuItem(value: 'ku', child: Text('کوردی${appLang.value == 'ku' ? ' ✓' : ''}')),
          PopupMenuItem(value: 'ar', child: Text('العربية${appLang.value == 'ar' ? ' ✓' : ''}')),
          PopupMenuItem(value: 'en', child: Text('English${appLang.value == 'en' ? ' ✓' : ''}')),
        ],
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 14, vertical: compact ? 8 : 11),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF15362A), Color(0xFF0D281F)]),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFF2B604B)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.language_rounded, size: 18, color: kGreen),
              if (!compact) ...[const SizedBox(width: 7), Text(tr('language'), style: const TextStyle(fontWeight: FontWeight.w800))],
            ],
          ),
        ),
      );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  List<(IconData, String, String)> get services => [
        (Icons.design_services_rounded, tr('serviceDesign'), tr('serviceDesignBody')),
        (Icons.battery_charging_full_rounded, tr('serviceHybrid'), tr('serviceHybridBody')),
        (Icons.apartment_rounded, tr('serviceCommercial'), tr('serviceCommercialBody')),
        (Icons.home_rounded, tr('serviceHome'), tr('serviceHomeBody')),
        (Icons.engineering_rounded, tr('serviceInstall'), tr('serviceInstallBody')),
        (Icons.cleaning_services_rounded, tr('serviceClean'), tr('serviceCleanBody')),
      ];
  List<(IconData, String, String)> get solutions => [
        (Icons.grid_4x4_rounded, tr('onGrid'), tr('onGridBody')),
        (Icons.power_off_rounded, tr('offGrid'), tr('offGridBody')),
        (Icons.hub_rounded, tr('hybrid'), tr('hybridBody')),
      ];
  List<(String, String)> get whyUs => [
        (tr('whySizing'), tr('whySizingBody')),
        (tr('whyQuality'), tr('whyQualityBody')),
        (tr('whySupport'), tr('whySupportBody')),
        (tr('whyPrice'), tr('whyPriceBody')),
      ];

  @override
  Widget build(BuildContext context) => CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: PageHead('Alo Solar Energy', sub: tr('companySub'))),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF173F30), Color(0xFF0B261D), Color(0xFF061710)]),
                    border: Border.all(color: const Color(0xFF34705A)),
                    boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 26, offset: Offset(0, 14))],
                  ),
                  child: Stack(
                    children: [
                      Positioned(top: -70, right: -55, child: Container(width: 190, height: 190, decoration: BoxDecoration(shape: BoxShape.circle, color: kGreen.withValues(alpha: .07)))),
                      Positioned(bottom: -65, left: -45, child: Container(width: 150, height: 150, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x14D8B94B)))),
                      Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Container(
                                width: 48,
                                height: 48,
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(color: Colors.black.withValues(alpha: .16), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
                                child: Image.asset('assets/images/alo_logo.png', fit: BoxFit.contain),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(tr('heroEyebrow'), style: const TextStyle(color: kGreen2, fontWeight: FontWeight.w900, fontSize: 12))),
                            ]),
                            const SizedBox(height: 16),
                            Text(tr('heroTitle'), style: const TextStyle(fontSize: 29, fontWeight: FontWeight.w900, height: 1.18, letterSpacing: -.4)),
                            const SizedBox(height: 12),
                            Text(tr('heroBody'), style: const TextStyle(color: kMuted, height: 1.65, fontSize: 13.5)),
                            const SizedBox(height: 20),
                            Row(children: [
                              Expanded(child: FilledButton.icon(
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalculatorPage(standalone: true))),
                                icon: const Icon(Icons.calculate_rounded),
                                label: Text(tr('calculateSystem'), overflow: TextOverflow.ellipsis),
                              )),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 52,
                                height: 50,
                                child: OutlinedButton(
                                  onPressed: () => launchUrl(Uri.parse('https://wa.me/9647764400440'), mode: LaunchMode.externalApplication),
                                  style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
                                  child: const Icon(Icons.chat_rounded),
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const _Stats(),
                const SizedBox(height: 22),
                SectionTitle(tr('whatWeDo'), tr('allSolarServices')),
                ...services.map((x) => InfoTile(icon: x.$1, title: x.$2, text: x.$3)),
                const SizedBox(height: 22),
                SectionTitle(tr('solutions'), tr('solutionSub')),
                ...solutions.map((x) => InfoTile(icon: x.$1, title: x.$2, text: x.$3)),
                const SizedBox(height: 22),
                SectionTitle(tr('whyAlo'), tr('whySub')),
                ...whyUs.map((x) => InfoTile(icon: Icons.check_circle_rounded, title: x.$1, text: x.$2)),
                const SizedBox(height: 22),
                const ContactCard(),
              ]),
            ),
          ),
        ],
      );
}

class _Stats extends StatelessWidget {
  const _Stats();
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(child: _stat('24/7', tr('energyIndependence'))),
          const SizedBox(width: 8),
          Expanded(child: _stat('3+', tr('systemOptions'))),
          const SizedBox(width: 8),
          Expanded(child: _stat('Erbil', 'Iraq')),
        ],
      );
  Widget _stat(String a, String b) => Container(
        padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF102D23), Color(0xFF0A1F18)]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF23523F)),
        ),
        child: Column(
          children: [
            Text(a, style: const TextStyle(color: kGreen2, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 5),
            Text(b, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: kMuted, fontSize: 10, height: 1.25)),
          ],
        ),
      );
}

class SectionTitle extends StatelessWidget {
  final String a, b;
  const SectionTitle(this.a, this.b, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(width: 4, height: 18, decoration: BoxDecoration(color: kGreen, borderRadius: BorderRadius.circular(99))),
              const SizedBox(width: 8),
              Expanded(child: Text(a, style: const TextStyle(color: kGreen2, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: .5))),
            ]),
            const SizedBox(height: 6),
            Text(b, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, height: 1.25)),
          ],
        ),
      );
}

class InfoTile extends StatelessWidget {
  final IconData icon;
  final String title, text;
  const InfoTile({super.key, required this.icon, required this.title, required this.text});
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF173D2F), Color(0xFF0D2B21)]),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2A654E)),
                ),
                child: Icon(icon, color: kGreen2, size: 24),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    const SizedBox(height: 5),
                    Text(text, style: const TextStyle(color: kMuted, height: 1.5)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class ContactCard extends StatelessWidget {
  const ContactCard({super.key});
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr('visitAlo'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(tr('address'), style: const TextStyle(color: kMuted)),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(avatar: const Icon(Icons.phone, size: 18), label: const Text('0750 476 0468'), onPressed: () => launchUrl(Uri.parse('tel:07504760468'))),
                  ActionChip(avatar: const Icon(Icons.chat, size: 18), label: const Text('0776 440 0440'), onPressed: () => launchUrl(Uri.parse('https://wa.me/9647764400440'), mode: LaunchMode.externalApplication)),
                ],
              ),
            ],
          ),
        ),
      );
}

class Product {
  final String type, name, model, img, pdf, warranty;
  final List<(String, String)> specs;
  const Product(this.type, this.name, this.model, this.img, this.pdf, this.warranty, this.specs);
  String get imageUrl => img.startsWith('ev-') ? '$kSite/$img' : '$kSite/assets/products/$img';
  String get pdfUrl => '$kSite/$pdf';
}

const products = <Product>[
  Product('Panel', 'LONGi Hi-MO X10 Anti-Dust Pro', 'LR8-66HVDF 640-670M', 'longi-x10.jpg', 'Anti-Dust-LR8-66HVDF-640-670M-Anti-dust-Pro.pdf.pdf', '15 years product / 30 years power', [('Power', '640-670 W'), ('Efficiency', 'Up to 24.8%'), ('Cell', 'Back Contact, 132 cells'), ('Protection', 'IP68 junction box'), ('Weight', '32.6 kg'), ('Size', '2382 × 1134 mm')]),
  Product('Panel', 'Power Solid N-Type Bifacial', 'PS620W#PVBN', 'powersolid-620.jpg', 'PS620WPVBN.pdf', '15 years (Alo product listing)', [('Power', '620 W'), ('Technology', 'N-Type Bifacial'), ('Cells', '144 half-cells'), ('Load', '2400 / 5400 Pa'), ('Weight', '33.5 kg'), ('Size', '2382 × 1134 mm')]),
  Product('Inverter', 'Deye Single-Phase Hybrid', 'SUN-3/3.6/4/4.6/5/6K-SG06LP1', 'deye-sp-3-6.jpg', 'BDatasheetSUN-3-6K-SG06LP1-EU-CM220260911en.pdf', '5 years', [('Output', '3-6 kW'), ('Battery', '40-60 V'), ('PV voltage', 'Max 500 V'), ('Efficiency', '97.6%'), ('Protection', 'IP65'), ('Interface', 'WiFi, RS485, CAN')]),
  Product('Inverter', 'Deye Single-Phase Hybrid', 'SUN-7/7.6/8/10K-SG05LP1', 'deye-sp-7-10.jpg', 'BDatasheetSUN-7-10K-SG05LP1-EU-SM220260911en.pdf', '5 years', [('Output', '7-10 kW'), ('Battery', '40-60 V'), ('PV voltage', 'Max 500 V'), ('Efficiency', '97.6%'), ('Protection', 'IP65'), ('Parallel', 'Up to 16 units')]),
  Product('Inverter', 'Deye Single-Phase Hybrid', 'SUN-7.6/8/10/12K-SG02LP1', 'deye-sp-7-12.jpg', 'BDatasheetSUN-76-12K-SG02LP1-EU-AM220260911en.pdf', '5 years', [('Output', '7.6-12 kW'), ('Battery', '40-60 V'), ('PV voltage', 'Max 500 V'), ('Efficiency', '97.6%'), ('Protection', 'IP65'), ('Weight', '35.6 kg')]),
  Product('Inverter', 'Deye Single-Phase Hybrid', 'SUN-12/14/16K-SG01LP1', 'deye-sp-12-16.jpg', 'bdatasheet_sun-12-16kk-sg01lp1-eu_20260706_en.pdf', '5 years', [('Output', '12-16 kW'), ('Battery', '40-60 V'), ('MPPT', '3 trackers'), ('Efficiency', '97.6%'), ('Protection', 'IP65'), ('Weight', '52 kg')]),
  Product('Inverter', 'Deye Three-Phase Hybrid', 'SUN-3/4/5/6/8/10/12K-SG05LP3', 'deye-3p-3-12.jpg', 'BDatasheetSUN-3-12K-SG05LP3-EU-SM220260911en.pdf', '5 years', [('Output', '3-12 kW'), ('Battery', '40-60 V'), ('PV voltage', 'Max 800 V'), ('Efficiency', '97.6%'), ('Protection', 'IP65'), ('Output', '100% unbalanced')]),
  Product('Inverter', 'Deye Three-Phase Hybrid', 'SUN-14/15/16/18/20K-SG05LP3', 'deye-3p-14-20.jpg', 'BDatasheetSUN-14-20K-SG05LP3-EU-SM220260911en.pdf', '5 years', [('Output', '14-20 kW'), ('Battery', '40-60 V'), ('PV voltage', 'Max 800 V'), ('Efficiency', '97.6%'), ('Protection', 'IP65'), ('Charge current', 'Up to 350 A')]),
  Product('Inverter', 'Medal Power Hybrid Inverter', 'MPHi-6KW#48VPVSE', 'medal-6.jpg', 'MPHi-6KW48VPVSE_1-1.pdf', '4 years', [('Output', '6 kW'), ('Battery', '40-60 V'), ('PV usable', '9 kW'), ('PV voltage', 'Max 500 V'), ('Protection', 'IP54'), ('Parallel', 'Up to 12 units')]),
  Product('Inverter', 'Bryyzee Hybrid Inverter', 'BRHi-6.2KW#48VPVT', 'bryyzee-6.jpg', 'BRHi-6.2KW48VPVT.pdf', '2 years (Alo product listing)', [('Output', '6.2 kW'), ('Battery', '48 V'), ('PV voltage', 'Max 500 V'), ('MPPT range', '60-500 V'), ('DC/AC efficiency', '98%'), ('Protection', 'IP21')]),
  Product('Battery', 'Pylontech Fidus Battery Plus', 'FB-L-16 / FB-L-16-Pro', 'pylontech-fidus.jpg', 'Pylon-tech-16kwh.pdf', '10 years (Alo product listing)', [('Energy', '16.076 kWh'), ('Voltage', '51.2 V'), ('Usable capacity', '16.076 kWh'), ('Cycle life', '8000 cycles'), ('Protection', 'IP65'), ('Current', '200 A continuous')]),
  Product('Battery', 'Hoymiles Low Voltage Battery', 'LB-16D-G3', 'hoymiles-16.jpg', 'Hoymiles-16-kw-battery-.pdf', '5 years', [('Energy', '16.08 kWh'), ('Capacity', '314 Ah'), ('Voltage', '51.2 V'), ('Cycle life', '8000 cycles'), ('Protection', 'IP65'), ('Weight', '110 kg')]),
  Product('Battery', 'EENOVANCE MANA-M Series', 'MANA 5.1 / 10.4 / 16.0 / 20.5', 'mana-m.jpg', 'EENOVANCE_MANA-M-Series_Datasheet3.pdf', '5 years', [('Energy', '5.1-20.5 kWh'), ('Chemistry', 'LiFePO4'), ('Installation', 'Floor standing'), ('Communication', 'CAN / RS485'), ('Use', 'Residential ESS'), ('Design', 'Modular range')]),
  Product('Battery', '3Watt Lithium Battery', 'WT-5121000-LT', '3watt-100ah.jpg', 'WT-5121000-LT.pdf', '5 years (Alo product listing)', [('Energy', '5.12 kWh'), ('Capacity', '100 Ah'), ('Voltage', '51.2 V'), ('Cycle life', '≥4000 cycles'), ('Current', '75 A discharge'), ('Weight', 'Approx. 48 kg')]),
  Product('EV Charger', 'Power Solid AC EV Charger', 'PSACC22KW3PHGBTB', 'ev-psacc22.webp', 'ev-psacc22.pdf', '', [('Brand', 'Power Solid'), ('Power', '22 kW'), ('Charging type', 'AC'), ('Phase', '3-Phase')]),
  Product('EV Charger', 'Power Solid DC Fast Charging Station', 'PSDCC120KW2PGBC2KR', 'ev-psdcc120.webp', 'ev-psdcc120.pdf', '', [('Brand', 'Power Solid'), ('Power', '120 kW'), ('Charging type', 'DC Fast'), ('Connector', 'GB/T')]),
  Product('EV Charger', 'Medal Power AC EV Charger', 'MPACC22KW3PHT2T', 'ev-mpacc22.webp', 'ev-mpacc22.pdf', '', [('Brand', 'Medal Power'), ('Power', '22 kW'), ('Charging type', 'AC'), ('Phase', '3-Phase')]),
  Product('EV Charger', 'Medal Power DC Fast Charger', 'MPDCC40KWGBTB', 'ev-mpdcc40.webp', 'ev-mpdcc40.pdf', '', [('Brand', 'Medal Power'), ('Power', '40 kW'), ('Charging type', 'DC Fast'), ('Connector', 'GB/T')]),
  Product('EV Charger', 'Three Watt GB/T Charger', 'WT-7KW#GBTV', 'ev-wt7gbt.webp', 'ev-wt7gbt.pdf', '', [('Brand', 'Three Watt'), ('Power', '7 kW'), ('Charging type', 'AC'), ('Connector', 'GB/T')]),
  Product('EV Charger', 'Three Watt Tesla Charger', 'WT-7KW#TESV', 'ev-wt7tesla.webp', 'ev-wt7tesla.pdf', '', [('Brand', 'Three Watt'), ('Power', '7 kW'), ('Charging type', 'AC'), ('Connector', 'Tesla')]),
];

String productType(String type) => type == 'Panel' ? tr('panel') : type == 'Inverter' ? tr('inverter') : type == 'EV Charger' ? tr('evChargers') : tr('battery');
String specLabel(String s) {
  final ar = <String, String>{'Power': 'القدرة', 'Efficiency': 'الكفاءة', 'Cell': 'الخلايا', 'Cells': 'الخلايا', 'Protection': 'الحماية', 'Weight': 'الوزن', 'Size': 'الأبعاد', 'Technology': 'التقنية', 'Load': 'التحمل', 'Output': 'الخرج', 'Battery': 'البطارية', 'PV voltage': 'جهد PV', 'Interface': 'الاتصال', 'Parallel': 'التوازي', 'MPPT': 'MPPT', 'Charge current': 'تيار الشحن', 'PV usable': 'قدرة PV', 'MPPT range': 'مدى MPPT', 'DC/AC efficiency': 'كفاءة DC/AC', 'Energy': 'الطاقة', 'Voltage': 'الجهد', 'Usable capacity': 'السعة المتاحة', 'Cycle life': 'دورات الشحن', 'Current': 'التيار', 'Capacity': 'السعة', 'Chemistry': 'الكيمياء', 'Installation': 'التركيب', 'Communication': 'الاتصال', 'Use': 'الاستخدام', 'Design': 'التصميم', 'Brand': 'العلامة التجارية', 'Charging type': 'نوع الشحن', 'Phase': 'الطور', 'Connector': 'نوع القابس'};
  final ku = <String, String>{'Power': 'توانا', 'Efficiency': 'کارایی', 'Cell': 'سێڵ', 'Cells': 'سێڵەکان', 'Protection': 'پاراستن', 'Weight': 'کێش', 'Size': 'قەبارە', 'Technology': 'تەکنەلۆجیا', 'Load': 'بەرگەگرتن', 'Output': 'دەرچوون', 'Battery': 'پاتری', 'PV voltage': 'ڤۆڵتاژی PV', 'Interface': 'پەیوەندی', 'Parallel': 'پارالێل', 'MPPT': 'MPPT', 'Charge current': 'جریانی شەحن', 'PV usable': 'توانای PV', 'MPPT range': 'مەودای MPPT', 'DC/AC efficiency': 'کارایی DC/AC', 'Energy': 'وزە', 'Voltage': 'ڤۆڵتاژ', 'Usable capacity': 'قەبارەی بەکارهێنراو', 'Cycle life': 'خولی ژیان', 'Current': 'جریان', 'Capacity': 'قەبارە', 'Chemistry': 'کیمیا', 'Installation': 'دامەزراندن', 'Communication': 'پەیوەندی', 'Use': 'بەکارهێنان', 'Design': 'دیزاین', 'Brand': 'براند', 'Charging type': 'جۆری شەحن', 'Phase': 'فاز', 'Connector': 'جۆری پلەگ'};
  return appLang.value == 'ar' ? (ar[s] ?? s) : appLang.value == 'ku' ? (ku[s] ?? s) : s;
}

class ProductsPage extends StatefulWidget {
  final bool standalone;
  const ProductsPage({super.key, this.standalone = false});
  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  String filter = 'All';
  String q = '';
  @override
  Widget build(BuildContext context) {
    final list = products.where((p) => (filter == 'All' || p.type == filter) && (q.isEmpty || '${p.name} ${p.model}'.toLowerCase().contains(q.toLowerCase()))).toList();
    final body = Column(
      children: [
        PageHead(tr('products'), sub: tr('productSub')),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: TextField(onChanged: (v) => setState(() => q = v), decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: tr('searchProduct'))),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: ['All', 'Panel', 'Inverter', 'Battery', 'EV Charger'].map((x) {
              final label = x == 'All' ? tr('all') : productType(x);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(label: Text(label), selected: filter == x, onSelected: (_) => setState(() => filter = x)),
              );
            }).toList(),
          ),
        ),
        Expanded(child: ListView.builder(padding: const EdgeInsets.fromLTRB(12, 8, 12, 22), itemCount: list.length, itemBuilder: (_, i) => ProductCard(list[i]))),
      ],
    );
    return widget.standalone ? Scaffold(body: body) : body;
  }
}

class ProductCard extends StatelessWidget {
  final Product p;
  const ProductCard(this.p, {super.key});
  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetail(p))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 10,
                child: Container(color: Colors.white, child: Image.network(p.imageUrl, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.black38, size: 48)))),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(productType(p.type).toUpperCase(), style: const TextStyle(color: kGreen, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    const SizedBox(height: 5),
                    Text(p.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(p.model, style: const TextStyle(color: kMuted)),
                    const SizedBox(height: 12),
                    Wrap(spacing: 8, runSpacing: 8, children: [if (p.warranty.isNotEmpty) Chip(label: Text('${tr('warranty')}: ${p.warranty}')), Chip(label: Text(p.specs.first.$2))]),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class ProductDetail extends StatelessWidget {
  final Product p;
  const ProductDetail(this.p, {super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(p.name)),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(height: 260, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)), padding: const EdgeInsets.all(20), child: Image.network(p.imageUrl, fit: BoxFit.contain)),
            const SizedBox(height: 18),
            Text(p.name, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
            const SizedBox(height: 5),
            Text(p.model, style: const TextStyle(color: kMuted)),
            const SizedBox(height: 8),
            if (p.warranty.isNotEmpty) ...[
              Text('${tr('warranty')}: ${p.warranty}', style: const TextStyle(color: kGreen2, fontWeight: FontWeight.w800)),
              const SizedBox(height: 18),
            ] else
              const SizedBox(height: 10),
            Text(tr('specifications'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            ...p.specs.map((s) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(16)),
                  child: Row(children: [Expanded(child: Text(specLabel(s.$1), style: const TextStyle(color: kMuted))), Text(s.$2, style: const TextStyle(fontWeight: FontWeight.w800))]),
                )),
            const SizedBox(height: 8),
            FilledButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PdfViewerPage(product: p))), icon: const Icon(Icons.picture_as_pdf_rounded), label: Text(tr('datasheet'))),
            OutlinedButton.icon(
              onPressed: () => launchUrl(Uri.parse('https://wa.me/9647764400440?text=${Uri.encodeComponent('Alo Solar Energy - ${p.name} ${p.model}')}'), mode: LaunchMode.externalApplication),
              icon: const Icon(Icons.chat),
              label: Text(tr('askWhatsapp')),
            ),
          ],
        ),
      );
}

class PdfViewerPage extends StatefulWidget {
  final Product product;
  const PdfViewerPage({super.key, required this.product});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  String? localPath;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.product.pdfUrl)).timeout(const Duration(seconds: 25));
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
        throw Exception('PDF unavailable');
      }
      final dir = await getTemporaryDirectory();
      final safeName = widget.product.pdf.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
      final file = File('${dir.path}/$safeName');
      await file.writeAsBytes(response.bodyBytes, flush: true);
      if (!mounted) return;
      setState(() => localPath = file.path);
    } catch (_) {
      if (!mounted) return;
      setState(() => error = tr('pdfError'));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('${tr('datasheet')} • ${widget.product.model}')),
        body: error != null
            ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(error!, textAlign: TextAlign.center)))
            : localPath == null
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const CircularProgressIndicator(), const SizedBox(height: 14), Text(tr('pdfLoading'))]))
                : PDFView(filePath: localPath!, enableSwipe: true, swipeHorizontal: false, autoSpacing: true, pageFling: true),
      );
}

class CalcDataItem {
  final String code, category, quality, mode, name, warranty, phase;
  final double price, watts, kw, ampsPerHour;
  final int maxPanels;
  const CalcDataItem({required this.code, required this.category, required this.quality, required this.mode, required this.name, required this.price, required this.warranty, required this.watts, required this.kw, required this.phase, required this.maxPanels, required this.ampsPerHour});
  factory CalcDataItem.fromJson(Map<String, dynamic> j) => CalcDataItem(
    code: '${j['code'] ?? ''}', category: '${j['category'] ?? ''}', quality: '${j['quality'] ?? 'common'}', mode: '${j['mode'] ?? 'both'}', name: '${j['name'] ?? ''}',
    price: double.tryParse('${j['price'] ?? 0}') ?? 0, warranty: '${j['warranty'] ?? ''}', watts: double.tryParse('${j['watts'] ?? 0}') ?? 0, kw: double.tryParse('${j['kw'] ?? 0}') ?? 0,
    phase: '${j['phase'] ?? 'single'}', maxPanels: int.tryParse('${j['max_panels'] ?? j['maxPanels'] ?? 0}') ?? 0, ampsPerHour: double.tryParse('${j['amps_per_hour'] ?? j['ampsPerHour'] ?? 0}') ?? 0,
  );
}

class CalcConfig {
  final List<CalcDataItem> items;
  final Map<String, double> services;
  final bool live;
  const CalcConfig(this.items, this.services, {this.live = false});
}

CalcConfig fallbackCalcConfig() => CalcConfig([
  const CalcDataItem(code:'longi-x10-650',category:'panel',quality:'high',mode:'both',name:'LONGi Hi-MO X10 650W',price:108,warranty:'15 Years Warranty',watts:650,kw:0,phase:'single',maxPanels:0,ampsPerHour:0),
  const CalcDataItem(code:'power-solid-620-medium',category:'panel',quality:'medium',mode:'both',name:'Power Solid 620W',price:105,warranty:'15 Years Warranty',watts:620,kw:0,phase:'single',maxPanels:0,ampsPerHour:0),
  const CalcDataItem(code:'power-solid-620-standard',category:'panel',quality:'standard',mode:'both',name:'Power Solid 620W',price:105,warranty:'15 Years Warranty',watts:620,kw:0,phase:'single',maxPanels:0,ampsPerHour:0),
  const CalcDataItem(code:'pylontech-314',category:'battery',quality:'high',mode:'both',name:'PylonTech 314Ah 51.2V',price:1750,warranty:'10 Years Warranty',watts:0,kw:0,phase:'single',maxPanels:0,ampsPerHour:60),
  const CalcDataItem(code:'hoymiles-314',category:'battery',quality:'medium',mode:'both',name:'Hoymiles 314Ah 51.2V',price:1550,warranty:'5 Years Warranty',watts:0,kw:0,phase:'single',maxPanels:0,ampsPerHour:60),
  const CalcDataItem(code:'mana-314',category:'battery',quality:'standard',mode:'both',name:'Mana 314Ah 51.2V',price:1485,warranty:'5 Years Warranty',watts:0,kw:0,phase:'single',maxPanels:0,ampsPerHour:60),
  const CalcDataItem(code:'3watt-100',category:'battery',quality:'common',mode:'both',name:'3Watt 100Ah 51.2V',price:650,warranty:'5 Years Warranty',watts:0,kw:0,phase:'single',maxPanels:0,ampsPerHour:18),
  const CalcDataItem(code:'deye-6-single',category:'inverter',quality:'high',mode:'both',name:'Deye 6kW Hybrid',price:800,warranty:'5 Years Warranty',watts:0,kw:6,phase:'single',maxPanels:14,ampsPerHour:0),
  const CalcDataItem(code:'deye-8-single',category:'inverter',quality:'high',mode:'both',name:'Deye 8kW Hybrid',price:1185,warranty:'5 Years Warranty',watts:0,kw:8,phase:'single',maxPanels:21,ampsPerHour:0),
  const CalcDataItem(code:'deye-12-single',category:'inverter',quality:'high',mode:'both',name:'Deye 12kW Hybrid Single Phase',price:1700,warranty:'5 Years Warranty',watts:0,kw:12,phase:'single',maxPanels:28,ampsPerHour:0),
  const CalcDataItem(code:'deye-14-single',category:'inverter',quality:'high',mode:'both',name:'Deye 14kW Hybrid Single Phase',price:1750,warranty:'5 Years Warranty',watts:0,kw:14,phase:'single',maxPanels:32,ampsPerHour:0),
  const CalcDataItem(code:'deye-16-single',category:'inverter',quality:'high',mode:'both',name:'Deye 16kW Hybrid Single Phase',price:1850,warranty:'5 Years Warranty',watts:0,kw:16,phase:'single',maxPanels:36,ampsPerHour:0),
  const CalcDataItem(code:'medald-6-single',category:'inverter',quality:'medium',mode:'both',name:'Medald Power 6kW Hybrid',price:400,warranty:'4 Years Warranty',watts:0,kw:6,phase:'single',maxPanels:8,ampsPerHour:0),
  const CalcDataItem(code:'viva-11-medium',category:'inverter',quality:'medium',mode:'both',name:'Viva Hybrid Inverter 11kW',price:775,warranty:'2 Years Warranty',watts:0,kw:11,phase:'single',maxPanels:18,ampsPerHour:0),
  const CalcDataItem(code:'bryyzee-6-single',category:'inverter',quality:'standard',mode:'both',name:'Bryyzee Hybrid Inverter 6.2kW',price:335,warranty:'2 Years Warranty',watts:0,kw:6.2,phase:'single',maxPanels:8,ampsPerHour:0),
  const CalcDataItem(code:'viva-11-standard',category:'inverter',quality:'standard',mode:'both',name:'Viva Hybrid Inverter 11kW',price:775,warranty:'2 Years Warranty',watts:0,kw:11,phase:'single',maxPanels:18,ampsPerHour:0),
  const CalcDataItem(code:'deye-12-3ph',category:'inverter',quality:'common',mode:'both',name:'Deye 12kW Hybrid 3-Phase',price:1700,warranty:'5 Years Warranty',watts:0,kw:12,phase:'3ph',maxPanels:28,ampsPerHour:0),
  const CalcDataItem(code:'deye-16-3ph',category:'inverter',quality:'common',mode:'both',name:'Deye 16kW Hybrid 3-Phase',price:1900,warranty:'5 Years Warranty',watts:0,kw:16,phase:'3ph',maxPanels:36,ampsPerHour:0),
  const CalcDataItem(code:'deye-20-3ph',category:'inverter',quality:'common',mode:'both',name:'Deye 20kW Hybrid 3-Phase',price:2500,warranty:'5 Years Warranty',watts:0,kw:20,phase:'3ph',maxPanels:50,ampsPerHour:0),
], const {
  'structurePerPanel':45,'installationPerPanel':15,'solarCablePerMeter':1.25,'acCablePerMeter':5,'dcProtectionSingle':75,'dcProtection3ph':100,'acProtectionSingle':75,'acProtection3ph':100,'transportErbil':50,'transportOutside':75,'otherElectricalUpTo16':100,'otherElectricalAbove16':150,'batteryBusbarMinimum':3,'batteryBusbarPrice':150,
});

class CalculatorPage extends StatefulWidget {
  final bool standalone;
  const CalculatorPage({super.key, this.standalone = false});
  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final day = TextEditingController(), night = TextEditingController();
  final sunHours = TextEditingController(text:'5.5'), tariff = TextEditingController(text:'185'), fx = TextEditingController(text:'1320');
  final panelQty = TextEditingController(text:'10'), inverterQty = TextEditingController(text:'1'), batteryQty = TextEditingController(text:'1'), solarCableM = TextEditingController(text:'0'), acCableM = TextEditingController(text:'0');
  String phase='single', quality='high', transport='erbil', mode='easy';
  String? advPanel, advInverter; String advBattery='none';
  CalcConfig config=fallbackCalcConfig(); bool loading=true; String? configMessage; Map<String,dynamic>? result;

  @override void initState(){super.initState();_loadConfig();}
  @override void dispose(){for(final c in [day,night,sunHours,tariff,fx,panelQty,inverterQty,batteryQty,solarCableM,acCableM]){c.dispose();}super.dispose();}

  Future<void> _loadConfig() async {
    try{
      final r=await http.get(Uri.parse('$kSite/api/portal/calculator/config')).timeout(const Duration(seconds:12));
      if(r.statusCode==200){final d=jsonDecode(r.body);if(d is Map<String,dynamic>){final raw=(d['items'] as List? ?? const []);final items=raw.whereType<Map>().map((x)=>CalcDataItem.fromJson(Map<String,dynamic>.from(x))).toList();final sm=Map<String,dynamic>.from(d['settings'] as Map? ?? const {});final services=<String,double>{};for(final e in sm.entries){services[e.key]=double.tryParse('${e.value}')??0;}if(items.isNotEmpty){config=CalcConfig(items,services,live:true);}}}
    }catch(_){configMessage=tr('configError');}
    _ensureAdvancedDefaults();if(mounted)setState(()=>loading=false);
  }
  void _ensureAdvancedDefaults(){final ps=_items('panel');final ins=_items('inverter',phaseFilter:phase);if(advPanel==null||!ps.any((x)=>x.code==advPanel))advPanel=ps.isEmpty?null:ps.first.code;if(advInverter==null||!ins.any((x)=>x.code==advInverter))advInverter=ins.isEmpty?null:ins.first.code;}
  List<CalcDataItem> _items(String cat,{String? qualityFilter,String? phaseFilter})=>config.items.where((x)=>x.category==cat&&(qualityFilter==null||x.quality==qualityFilter||x.quality=='common')&&(phaseFilter==null||x.phase==phaseFilter)).toList()..sort((a,b)=>(a.maxPanels==0?999:a.maxPanels).compareTo(b.maxPanels==0?999:b.maxPanels));
  double _svc(String k,double fallback)=>config.services[k]??fallback;
  CalcDataItem? _byCode(String? code){if(code==null)return null;for(final x in config.items){if(x.code==code)return x;}return null;}

  void _easyCalc(){
    final d=double.tryParse(day.text)??0,n=double.tryParse(night.text)??0,sh=double.tryParse(sunHours.text)??5.5,gt=double.tryParse(tariff.text)??185,rate=double.tryParse(fx.text)??1320;
    if(d<=0||n<0){setState(()=>result={'error':true});return;}
    final panels=math.max(1,(d/2).ceil());
    final panelsList=_items('panel',qualityFilter:quality).where((x)=>x.quality==quality).toList();final panel=panelsList.isNotEmpty?panelsList.first:_items('panel').first;
    final b100List=config.items.where((x)=>x.category=='battery'&&x.ampsPerHour>0&&x.ampsPerHour<=20).toList();final b100=b100List.isNotEmpty?b100List.first:null;
    final b314List=config.items.where((x)=>x.category=='battery'&&x.quality==quality&&x.ampsPerHour>=50).toList();final b314=b314List.isNotEmpty?b314List.first:null;
    int q100=0,q314=0;if(n>0&&n<=3)q100=1;else if(n>3&&n<=6)q100=2;else if(n>6)q314=math.max(1,((n*7.5)/60).ceil());
    var invs=phase=='3ph'?config.items.where((x)=>x.category=='inverter'&&x.phase=='3ph').toList():config.items.where((x)=>x.category=='inverter'&&x.phase=='single'&&x.quality==quality).toList();
    if(invs.isEmpty)invs=config.items.where((x)=>x.category=='inverter'&&x.phase==phase).toList();invs.sort((a,b)=>a.maxPanels.compareTo(b.maxPanels));
    CalcDataItem inv=invs.last;for(final x in invs){if(x.maxPanels>0&&panels<=x.maxPanels){inv=x;break;}}
    final invCount=math.max(1,(panels/math.max(1,inv.maxPanels)).ceil());final boards=invCount;
    final dc=phase=='3ph'?_svc('dcProtection3ph',100):_svc('dcProtectionSingle',75),ac=phase=='3ph'?_svc('acProtection3ph',100):_svc('acProtectionSingle',75);
    final structure=panels*_svc('structurePerPanel',45),install=panels*_svc('installationPerPanel',15),other=panels<=16?_svc('otherElectricalUpTo16',100):_svc('otherElectricalAbove16',150),trans=transport=='erbil'?_svc('transportErbil',50):_svc('transportOutside',75),bus=(q100+q314)>=(_svc('batteryBusbarMinimum',3).round())?_svc('batteryBusbarPrice',150):0.0;
    final batteryCost=q100*(b100?.price??0)+q314*(b314?.price??0),equipment=panels*panel.price+invCount*inv.price+batteryCost,services=boards*(dc+ac)+structure+install+other+trans+bus,total=equipment+services;
    final monthlyKwh=panels*panel.watts/1000*math.max(0,sh)*30*.80,monthlyIqd=monthlyKwh*math.max(0,gt),payback=monthlyIqd>0&&rate>0?(total*rate)/(monthlyIqd*12):0.0;
    setState(()=>result={'mode':'easy','panels':panels,'panel':panel.name,'panelWarranty':panel.warranty,'q100':q100,'q314':q314,'b100':b100?.name??'','b314':b314?.name??'','batteryWarranty':q314>0?b314?.warranty:q100>0?b100?.warranty:'','inverterCount':invCount,'inverter':inv.name,'inverterWarranty':inv.warranty,'boards':boards,'dc':dc,'ac':ac,'structure':structure,'installation':install,'other':other,'transport':trans,'bus':bus,'equipment':equipment,'services':services,'price':total,'monthlyKwh':monthlyKwh,'monthlyIqd':monthlyIqd,'payback':payback});
  }

  void _advancedCalc(){
    final p=_byCode(advPanel),inv=_byCode(advInverter),bat=advBattery=='none'?null:_byCode(advBattery);final pq=int.tryParse(panelQty.text)??0,iq=int.tryParse(inverterQty.text)??0,bq=int.tryParse(batteryQty.text)??0,sc=double.tryParse(solarCableM.text)??-1,acc=double.tryParse(acCableM.text)??-1;
    if(p==null||inv==null||pq<=0||iq<=0||bq<0||sc<0||acc<0){setState(()=>result={'error':true});return;}
    final dc=phase=='3ph'?_svc('dcProtection3ph',100):_svc('dcProtectionSingle',75),ac=phase=='3ph'?_svc('acProtection3ph',100):_svc('acProtectionSingle',75),structure=pq*_svc('structurePerPanel',45),install=pq*_svc('installationPerPanel',15),other=pq<=16?_svc('otherElectricalUpTo16',100):_svc('otherElectricalAbove16',150),trans=transport=='erbil'?_svc('transportErbil',50):_svc('transportOutside',75),bus=bq>=_svc('batteryBusbarMinimum',3).round()?_svc('batteryBusbarPrice',150):0.0,solarCable=sc*_svc('solarCablePerMeter',1.25),acCable=acc*_svc('acCablePerMeter',5),equipment=pq*p.price+iq*inv.price+bq*(bat?.price??0),services=iq*(dc+ac)+structure+install+other+trans+bus+solarCable+acCable,total=equipment+services;
    setState(()=>result={'mode':'advanced','panels':pq,'panel':p.name,'panelWarranty':p.warranty,'inverterCount':iq,'inverter':inv.name,'inverterWarranty':inv.warranty,'batteryQty':bq,'battery':bat?.name??tr('noBatteryOption'),'batteryWarranty':bat?.warranty??'','boards':iq,'dc':dc,'ac':ac,'structure':structure,'installation':install,'other':other,'transport':trans,'bus':bus,'solarCable':solarCable,'acCable':acCable,'equipment':equipment,'services':services,'price':total});
  }

  void _reset(){day.clear();night.clear();panelQty.text='10';inverterQty.text='1';batteryQty.text='1';solarCableM.text='0';acCableM.text='0';sunHours.text='5.5';tariff.text='185';fx.text='1320';phase='single';quality='high';transport='erbil';mode='easy';result=null;_ensureAdvancedDefaults();setState((){});}
  Future<void> _sendWhatsapp() async {
    if (result == null || result!['error'] == true) return;
    final r = result!;
    String batteryLine = tr('noBattery');
    if (r['mode'] == 'advanced') {
      batteryLine = '${r['batteryQty']} × ${r['battery']}';
    } else if ((r['q314'] ?? 0) > 0) {
      batteryLine = '${r['q314']} × ${r['b314']}';
    } else if ((r['q100'] ?? 0) > 0) {
      batteryLine = '${r['q100']} × ${r['b100']}';
    }
    final msg = StringBuffer()
      ..writeln('Alo Solar Energy - ${tr('recommendedSystem')}')
      ..writeln('${tr('panels')}: ${r['panels']} × ${r['panel']}')
      ..writeln('${tr('inverter')}: ${r['inverterCount']} × ${r['inverter']}')
      ..writeln('${tr('battery')}: $batteryLine')
      ..writeln('${tr('estimatedPrice')}: \$${(r['price'] as double).toStringAsFixed(0)}');
    await launchUrl(
      Uri.parse('https://wa.me/9647764400440?text=${Uri.encodeComponent(msg.toString())}'),
      mode: LaunchMode.externalApplication,
    );
  }

  @override Widget build(BuildContext context){
    final content=Column(children:[PageHead(tr('calculator'),sub:tr('calcSub')),Expanded(child:ListView(padding:const EdgeInsets.fromLTRB(14,4,14,30),children:[
      SegmentedButton<String>(segments:[ButtonSegment(value:'easy',icon:const Icon(Icons.auto_awesome),label:Text(tr('easyMode'))),ButtonSegment(value:'advanced',icon:const Icon(Icons.tune),label:Text(tr('advancedMode')))],selected:{mode},onSelectionChanged:(s)=>setState(()=>mode=s.first)),
      const SizedBox(height:10),Container(padding:const EdgeInsets.all(11),decoration:BoxDecoration(color:(config.live?kGreen:Colors.orange).withValues(alpha:.08),borderRadius:BorderRadius.circular(14),border:Border.all(color:(config.live?kGreen:Colors.orange).withValues(alpha:.3))),child:Row(children:[Icon(config.live?Icons.cloud_done_outlined:Icons.cloud_off_outlined,color:config.live?kGreen:Colors.orange,size:18),const SizedBox(width:8),Expanded(child:Text(config.live?tr('calcLiveData'):tr('calcOfflineData'),style:const TextStyle(color:kMuted,fontSize:12)))])),
      if(configMessage!=null)...[const SizedBox(height:6),Text(configMessage!,style:const TextStyle(color:Colors.orange,fontSize:11))],const SizedBox(height:12),
      if(loading) Center(child:Padding(padding:const EdgeInsets.all(30),child:Column(children:[const CircularProgressIndicator(),const SizedBox(height:10),Text(tr('loading'))]))) else if(mode=='easy') _easyForm() else _advancedForm(),
      if(result!=null)...[const SizedBox(height:12),CalcResultCard(result!)],const SizedBox(height:12),Row(children:[Expanded(child:OutlinedButton.icon(onPressed:_reset,icon:const Icon(Icons.refresh),label:Text(tr('reset')))),const SizedBox(width:8),Expanded(child:FilledButton.icon(onPressed:result==null?null:_sendWhatsapp,icon:const Icon(Icons.chat_outlined),label:Text(tr('sendWhatsapp'))))])
    ]))]);return widget.standalone?Scaffold(body:content):content;
  }

  Widget _easyForm()=>Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[Text(tr('easySub'),style:const TextStyle(color:kMuted)),const SizedBox(height:14),Row(children:[Expanded(child:TextField(controller:day,keyboardType:TextInputType.number,decoration:InputDecoration(labelText:tr('dayLoad')))),const SizedBox(width:8),Expanded(child:TextField(controller:night,keyboardType:TextInputType.number,decoration:InputDecoration(labelText:tr('nightLoad'))))]),const SizedBox(height:10),_phaseField(),const SizedBox(height:10),DropdownButtonFormField<String>(value:quality,items:[DropdownMenuItem(value:'high',child:Text(tr('bestQuality'))),DropdownMenuItem(value:'medium',child:Text(tr('middleQuality'))),DropdownMenuItem(value:'standard',child:Text(tr('basicQuality')))],onChanged:(v)=>setState(()=>quality=v!),decoration:InputDecoration(labelText:tr('quality'))),const SizedBox(height:10),_transportField(),const SizedBox(height:8),ExpansionTile(tilePadding:EdgeInsets.zero,title:Text(tr('roiSettings'),style:const TextStyle(fontWeight:FontWeight.w800)),children:[Row(children:[Expanded(child:TextField(controller:sunHours,keyboardType:TextInputType.number,decoration:InputDecoration(labelText:tr('sunHours')))),const SizedBox(width:8),Expanded(child:TextField(controller:tariff,keyboardType:TextInputType.number,decoration:InputDecoration(labelText:tr('gridTariff'))))]),const SizedBox(height:8),TextField(controller:fx,keyboardType:TextInputType.number,decoration:InputDecoration(labelText:tr('fxRate'))),const SizedBox(height:8)]),const SizedBox(height:10),FilledButton.icon(onPressed:_easyCalc,icon:const Icon(Icons.auto_awesome),label:Text(tr('recommend')))])));
  Widget _advancedForm(){final panels=_items('panel'),invs=_items('inverter',phaseFilter:phase),bats=_items('battery');return Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[Text(tr('advancedSub'),style:const TextStyle(color:kMuted)),const SizedBox(height:12),_phaseField(onChanged:(v){setState(()=>phase=v);_ensureAdvancedDefaults();}),const SizedBox(height:10),DropdownButtonFormField<String>(value:advPanel,items:panels.map((x)=>DropdownMenuItem(value:x.code,child:Text('${x.name} — \$${x.price.toStringAsFixed(0)}'))).toList(),onChanged:(v)=>setState(()=>advPanel=v),decoration:InputDecoration(labelText:tr('selectPanel'))),const SizedBox(height:8),TextField(controller:panelQty,keyboardType:TextInputType.number,decoration:InputDecoration(labelText:tr('panelQty'))),const SizedBox(height:10),DropdownButtonFormField<String>(value:advInverter,items:invs.map((x)=>DropdownMenuItem(value:x.code,child:Text('${x.name} — \$${x.price.toStringAsFixed(0)}'))).toList(),onChanged:(v)=>setState(()=>advInverter=v),decoration:InputDecoration(labelText:tr('selectInverter'))),const SizedBox(height:8),TextField(controller:inverterQty,keyboardType:TextInputType.number,decoration:InputDecoration(labelText:tr('inverterQty'))),const SizedBox(height:10),DropdownButtonFormField<String>(value:advBattery,items:[DropdownMenuItem(value:'none',child:Text(tr('noBatteryOption'))),...bats.map((x)=>DropdownMenuItem(value:x.code,child:Text('${x.name} — \$${x.price.toStringAsFixed(0)}')))],onChanged:(v)=>setState(()=>advBattery=v!),decoration:InputDecoration(labelText:tr('selectBattery'))),const SizedBox(height:8),TextField(controller:batteryQty,keyboardType:TextInputType.number,decoration:InputDecoration(labelText:tr('batteryQty'))),const SizedBox(height:10),Row(children:[Expanded(child:TextField(controller:solarCableM,keyboardType:TextInputType.number,decoration:InputDecoration(labelText:tr('solarCableM')))),const SizedBox(width:8),Expanded(child:TextField(controller:acCableM,keyboardType:TextInputType.number,decoration:InputDecoration(labelText:tr('acCableM'))))]),const SizedBox(height:10),_transportField(),const SizedBox(height:14),FilledButton.icon(onPressed:_advancedCalc,icon:const Icon(Icons.calculate_outlined),label:Text(tr('calculate')))])));}
  Widget _phaseField({void Function(String)? onChanged})=>DropdownButtonFormField<String>(value:phase,items:[DropdownMenuItem(value:'single',child:Text(tr('singlePhase'))),DropdownMenuItem(value:'3ph',child:Text(tr('threePhase')))],onChanged:(v){if(v==null)return;if(onChanged!=null)onChanged(v);else setState(()=>phase=v);},decoration:InputDecoration(labelText:tr('phase')));
  Widget _transportField()=>DropdownButtonFormField<String>(value:transport,items:[DropdownMenuItem(value:'erbil',child:Text(tr('localErbil'))),DropdownMenuItem(value:'outside',child:Text(tr('outsideErbil')))],onChanged:(v)=>setState(()=>transport=v!),decoration:InputDecoration(labelText:tr('transport')));
}

class CalcResultCard extends StatelessWidget{
  final Map<String,dynamic> r;const CalcResultCard(this.r,{super.key});
  @override Widget build(BuildContext context){if(r['error']==true)return Card(child:Padding(padding:const EdgeInsets.all(16),child:Text(tr('invalidNumber'),style:const TextStyle(color:Colors.orange))));final adv=r['mode']=='advanced';final battery=adv?'${r['batteryQty']} × ${r['battery']}':r['q314']>0?'${r['q314']} × ${r['b314']}':r['q100']>0?'${r['q100']} × ${r['b100']}':tr('noBattery');return Card(child:Padding(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(tr('recommendedSystem'),style:const TextStyle(color:kGreen,fontWeight:FontWeight.w900)),const SizedBox(height:10),_row(tr('panels'),'${r['panels']} × ${r['panel']}'),_row(tr('inverter'),'${r['inverterCount']} × ${r['inverter']}'),_row(tr('battery'),battery),_row(tr('protection'),'${r['boards']} × ${tr('acBoard')} + ${r['boards']} × ${tr('dcBoard')}'),const Divider(height:24),Text(tr('priceBreakdown'),style:const TextStyle(fontWeight:FontWeight.w900)),_money(tr('equipment'),r['equipment']),_money(tr('structure'),r['structure']),_money(tr('installation'),r['installation']),_money(tr('otherElectrical'),r['other']),_money(tr('transport'),r['transport']),if((r['bus'] as double)>0)_money(tr('batteryBusbar'),r['bus']),if(adv&&((r['solarCable'] as double)>0))_money(tr('solarCable'),r['solarCable']),if(adv&&((r['acCable'] as double)>0))_money(tr('acCable'),r['acCable']),_money(tr('acBoard'),(r['boards'] as int)*(r['ac'] as double)),_money(tr('dcBoard'),(r['boards'] as int)*(r['dc'] as double)),const Divider(height:24),_row(tr('systemTotal'),'\$${(r['price'] as double).toStringAsFixed(0)}',big:true),const SizedBox(height:8),_row(tr('warranty'),'${r['panelWarranty']} • ${r['inverterWarranty']}'),if('${r['batteryWarranty']??''}'.isNotEmpty)_row(tr('batteryWarranty'),'${r['batteryWarranty']}'),if(!adv)...[const Divider(height:24),_row(tr('monthlyProduction'),'${(r['monthlyKwh'] as double).toStringAsFixed(0)} kWh'),_row(tr('monthlySaving'),'${(r['monthlyIqd'] as double).toStringAsFixed(0)} IQD'),_row(tr('payback'),(r['payback'] as double)>0?'${(r['payback'] as double).toStringAsFixed(1)} ${tr('years')}':tr('noPayback')),const SizedBox(height:6),Text(tr('productionNote'),style:const TextStyle(color:kMuted,fontSize:11))]])));
  }
  Widget _money(String a,dynamic v)=>_row(a,'\$${(v as double).toStringAsFixed(0)}');
  Widget _row(String a,String b,{bool big=false})=>Padding(padding:const EdgeInsets.symmetric(vertical:4),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Expanded(child:Text(a,style:const TextStyle(color:kMuted))),const SizedBox(width:10),Flexible(child:Text(b,textAlign:TextAlign.end,style:TextStyle(fontWeight:FontWeight.w900,fontSize:big?22:14,color:big?kGreen2:kText)))]));
}
class EvProduct {
  final String brand, title, power, model, image, type;
  const EvProduct(this.brand, this.title, this.power, this.model, this.image, this.type);
}

const evs = [
  EvProduct('Power Solid', 'AC EV Charger', '22 kW', 'PSACC22KW3PHGBTB', 'https://powersolid.vn/wp-content/uploads/2026/06/PSACC22KW3PHGBTB-300x300.jpg', 'AC'),
  EvProduct('Power Solid', 'DC Fast Charging Station', '120 kW', 'PSDCC120KW2PGBC2KR', 'https://powersolid.vn/wp-content/uploads/2024/07/80-100-120-140-600x600.jpeg', 'DC'),
  EvProduct('Medal Power', 'AC EV Charger', '22 kW', 'MPACC22KW3PHT2T', 'https://medal-power.com/media/k2/items/cache/2d535442c2c0b0669d8f5a051ed00bcc_L.jpg', 'AC'),
  EvProduct('Medal Power', 'DC Fast Charger', '40 kW', 'MPDCC40KWGBTB', 'https://medal-power.com/media/k2/items/cache/8376aace7af18ea8cafa499d7e69a6ec_L.jpg', 'DC'),
  EvProduct('Three Watt', 'GB/T Charger', '7 kW', 'WT-7KW#GBTV', '', 'AC · GB/T'),
  EvProduct('Three Watt', 'Tesla Charger', '7 kW', 'WT-7KW#TESV', '', 'AC · Tesla'),
];

String evName(EvProduct e) {
  if (appLang.value == 'en') return e.title;
  if (appLang.value == 'ar') {
    if (e.title.contains('DC Fast')) return 'شاحن DC سريع';
    if (e.title.contains('AC EV')) return 'شاحن EV AC';
    if (e.title.contains('GB/T')) return 'شاحن GB/T';
    if (e.title.contains('Tesla')) return 'شاحن Tesla';
  }
  if (appLang.value == 'ku') {
    if (e.title.contains('DC Fast')) return 'شەحنکەری خێرای DC';
    if (e.title.contains('AC EV')) return 'شەحنکەری EV ـی AC';
    if (e.title.contains('GB/T')) return 'شەحنکەری GB/T';
    if (e.title.contains('Tesla')) return 'شەحنکەری Tesla';
  }
  return e.title;
}

class EvPage extends StatefulWidget {
  const EvPage({super.key});
  @override
  State<EvPage> createState() => _EvPageState();
}

class _EvPageState extends State<EvPage> {
  final cap = TextEditingController(text: '60');
  final power = TextEditingController(text: '7');
  final from = TextEditingController(text: '20');
  final to = TextEditingController(text: '80');
  double? hours;
  void calc() {
    final c = double.tryParse(cap.text) ?? 0;
    final p = double.tryParse(power.text) ?? 0;
    final a = double.tryParse(from.text) ?? 0;
    final b = double.tryParse(to.text) ?? 0;
    if (c > 0 && p > 0 && b > a) setState(() => hours = c * ((b - a) / 100) / p / .9);
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          PageHead('ALO EV CHARGE', sub: tr('evSub')),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
              children: [
                SectionTitle(tr('evChargers'), tr('findEv')),
                ...evs.map((e) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 86,
                              height: 86,
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                              child: e.image.isEmpty ? const Icon(Icons.ev_station_rounded, color: Colors.black54, size: 42) : Image.network(e.image, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.ev_station_rounded, color: Colors.black54, size: 42)),
                            ),
                            const SizedBox(width: 13),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e.brand, style: const TextStyle(color: kGreen, fontWeight: FontWeight.w800)),
                                  Text(evName(e), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                                  Text('${e.power} • ${e.type}', style: const TextStyle(color: kMuted)),
                                  Text(e.model, style: const TextStyle(color: kMuted, fontSize: 11)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                const SizedBox(height: 18),
                SectionTitle(tr('chargingCalculator'), tr('chargingEstimate')),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(children: [Expanded(child: TextField(controller: cap, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: tr('batteryKwh')))), const SizedBox(width: 8), Expanded(child: TextField(controller: power, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: tr('chargerKw'))))]),
                        const SizedBox(height: 8),
                        Row(children: [Expanded(child: TextField(controller: from, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: tr('currentPercent')))), const SizedBox(width: 8), Expanded(child: TextField(controller: to, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: tr('targetPercent'))))]),
                        const SizedBox(height: 12),
                        FilledButton(onPressed: calc, child: Text(tr('calculateCharging'))),
                        if (hours != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text('${hours!.toStringAsFixed(1)} ${tr('hours')}', style: const TextStyle(color: kGreen2, fontSize: 24, fontWeight: FontWeight.w900))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});
  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class Chat {
  final bool user;
  final String text;
  const Chat(this.user, this.text);
}

class _AssistantPageState extends State<AssistantPage> {
  final input = TextEditingController();
  final scroll = ScrollController();
  final msgs = <Chat>[];
  bool loading = false;

  Future<void> send([String? preset]) async {
    final q = (preset ?? input.text).trim();
    if (q.isEmpty || loading) return;
    setState(() {
      msgs.add(Chat(true, q));
      input.clear();
      loading = true;
    });
    try {
      final res = await http
          .post(
            Uri.parse('$kSite/api/ai/chat'),
            headers: {'Content-Type': 'application/json', 'Origin': kSite},
            body: jsonEncode({
              'message': q,
              'language': appLang.value,
              'mode': 'general',
              'history': msgs.skip(math.max(0, msgs.length - 12)).map((m) => {'role': m.user ? 'user' : 'assistant', 'content': m.text}).toList(),
            }),
          )
          .timeout(const Duration(seconds: 35));
      final body = jsonDecode(res.body);
      final ans = res.statusCode == 200 ? (body['answer']?.toString() ?? '') : tr('aiOffline');
      if (mounted) setState(() => msgs.add(Chat(false, ans.isEmpty ? tr('aiOffline') : ans)));
    } catch (_) {
      if (mounted) setState(() => msgs.add(Chat(false, tr('aiOffline'))));
    } finally {
      if (mounted) setState(() => loading = false);
      Future.delayed(const Duration(milliseconds: 100), () {
        if (scroll.hasClients) scroll.animateTo(scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      });
    }
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          PageHead(tr('ai'), sub: tr('aiSub')),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [_chip(tr('whichSystem')), _chip('Deye 8kW'), _chip('314Ah Battery'), _chip('EV Charger')],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scroll,
              padding: const EdgeInsets.all(14),
              itemCount: msgs.length + 1 + (loading ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == 0) return _bubble(false, tr('aiWelcome'));
                final j = i - 1;
                if (j == msgs.length) return const Align(alignment: Alignment.centerLeft, child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()));
                return _bubble(msgs[j].user, msgs[j].text);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(12, 8, 12, 12 + MediaQuery.of(context).viewInsets.bottom),
            child: Row(
              children: [
                Expanded(child: TextField(controller: input, maxLines: 4, minLines: 1, onSubmitted: (_) => send(), decoration: InputDecoration(hintText: tr('askHint')))),
                const SizedBox(width: 8),
                SizedBox(width: 52, height: 52, child: FilledButton(onPressed: loading ? null : send, style: FilledButton.styleFrom(padding: EdgeInsets.zero), child: const Icon(Icons.arrow_upward_rounded))),
              ],
            ),
          ),
        ],
      );

  Widget _bubble(bool user, String text) => Align(
        alignment: user ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(color: user ? kGreen : kSurface, borderRadius: BorderRadius.circular(18), border: user ? null : Border.all(color: const Color(0xFF1D463A))),
          child: Text(text, style: TextStyle(color: user ? kBg : kText, height: 1.45, fontWeight: user ? FontWeight.w800 : FontWeight.w500)),
        ),
      );
  Widget _chip(String s) => Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: ActionChip(label: Text(s), onPressed: () => send(s)));
}

class MorePage extends StatelessWidget {
  const MorePage({super.key});
  @override
  Widget build(BuildContext context) => Column(
        children: [
          PageHead(tr('more'), sub: tr('moreSub')),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(14),
              children: [
                _nativeLink(context, Icons.monitor_heart_outlined, tr('monitoring'), tr('monitoringSub'), const MonitoringPage()),
                _nativeLink(context, Icons.groups_2_outlined, tr('dealerArea'), tr('dealerSub'), const DealerPage()),
                _nativeLink(context, Icons.badge_outlined, tr('installer'), tr('installerSub'), const InstallerPage()),
                _nativeLink(context, Icons.notifications_active_outlined, atr('notificationCenter'), atr('appNotifications'), const NotificationCenterPage()),
                _nativeLink(context, Icons.admin_panel_settings_outlined, atr('admin'), atr('adminSub'), const AdminPage()),
                _nativeLink(context, Icons.contact_phone_outlined, tr('contact'), tr('contactSub'), const ContactPage()),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.language_rounded, color: kGreen),
                    title: Text(tr('language'), style: const TextStyle(fontWeight: FontWeight.w900)),
                    subtitle: Text(tr('languageSub')),
                    trailing: const LanguageMenu(compact: true),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Image.asset('assets/images/alo_logo.png', width: 120),
                        const SizedBox(width: 14),
                        Expanded(child: Text(tr('nativeOnly'), style: const TextStyle(color: kMuted, height: 1.5))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
  Widget _nativeLink(BuildContext c, IconData i, String a, String b, Widget page) => Card(
        child: ListTile(
          leading: Icon(i, color: kGreen),
          title: Text(a, style: const TextStyle(fontWeight: FontWeight.w900)),
          subtitle: Text(b),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => page)),
        ),
      );
}

class MonitoringPage extends StatelessWidget {
  const MonitoringPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(tr('monitoring'))),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(child: Image.asset('assets/images/alo_logo.png', width: 190)),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    const Icon(Icons.monitor_heart_outlined, size: 60, color: kGreen),
                    const SizedBox(height: 14),
                    Text(tr('notLinked'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 10),
                    Text(tr('nativeOnly'), textAlign: TextAlign.center, style: const TextStyle(color: kMuted)),
                    const SizedBox(height: 18),
                    FilledButton.icon(onPressed: () => launchUrl(Uri.parse('https://wa.me/9647764400440'), mode: LaunchMode.externalApplication), icon: const Icon(Icons.chat), label: Text(tr('connectSystem'))),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}

class DealerPage extends StatefulWidget {
  const DealerPage({super.key});
  @override
  State<DealerPage> createState() => _DealerPageState();
}

class _DealerPageState extends State<DealerPage> {
  final user = TextEditingController();
  final pass = TextEditingController();
  bool busy = false;
  bool obscure = true;
  bool checkingSession = true;
  bool authenticated = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    try {
      final r = await DealerApi.instance.me();
      if (mounted) setState(() => authenticated = r.ok);
    } catch (_) {}
    if (mounted) setState(() => checkingSession = false);
  }

  @override
  void dispose() { user.dispose(); pass.dispose(); super.dispose(); }

  Future<void> _login() async {
    if (user.text.trim().isEmpty || pass.text.isEmpty) return;
    setState(() { busy = true; error = null; });
    try {
      final r = await DealerApi.instance.login(user.text.trim(), pass.text);
      if (!mounted) return;
      if (r.ok) {
        await Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const DealerDashboardPage()));
      } else {
        final status = r.data['status']?.toString();
        setState(() => error = status == 'pending' ? tr('pendingApproval') : (r.data['error']?.toString() ?? tr('loginFailed')));
      }
    } catch (_) {
      if (mounted) setState(() => error = tr('loginFailed'));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(tr('dealerArea'))),
    body: SafeArea(child: ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
      children: [
        Center(child: Image.asset('assets/images/alo_logo.png', width: 180)),
        const SizedBox(height: 18),
        if (checkingSession) ...[
          const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 12),
          Text(tr('checkingSession'), textAlign: TextAlign.center, style: const TextStyle(color: kMuted)),
        ] else if (authenticated) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(children: [
                const Icon(Icons.verified_user_rounded, color: kGreen, size: 46),
                const SizedBox(height: 10),
                Text(tr('loggedInAlready'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 14),
                SizedBox(width: double.infinity, height: 50, child: FilledButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DealerDashboardPage())), child: Text(tr('continueDashboard')))),
              ]),
            ),
          ),
          const SizedBox(height: 16),
        ] else ...[
        Text(tr('dealerLogin'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text(tr('dealerSub'), textAlign: TextAlign.center, style: const TextStyle(color: kMuted)),
        const SizedBox(height: 24),
        TextField(controller: user, textInputAction: TextInputAction.next, decoration: InputDecoration(labelText: tr('username'), prefixIcon: const Icon(Icons.person_outline))),
        const SizedBox(height: 12),
        TextField(controller: pass, obscureText: obscure, onSubmitted: (_) => _login(), decoration: InputDecoration(labelText: tr('password'), prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(onPressed: () => setState(() => obscure = !obscure), icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined)))),
        if (error != null) ...[const SizedBox(height: 12), Text(error!, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700))],
        const SizedBox(height: 18),
        SizedBox(height: 52, child: FilledButton(onPressed: busy ? null : _login, child: busy ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)) : Text(tr('login')))),
        const SizedBox(height: 10),
        OutlinedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DealerRegisterPage())), icon: const Icon(Icons.person_add_alt_1), label: Text(tr('registerDealer'))),
        TextButton(onPressed: () => launchUrl(Uri.parse('https://wa.me/9647764400440?text=${Uri.encodeComponent(tr('resetViaWhatsapp'))}'), mode: LaunchMode.externalApplication), child: Text(tr('forgotPassword'))),
        ],
      ],
    )),
  );
}

class DealerRegisterPage extends StatefulWidget {
  final bool installer;
  const DealerRegisterPage({super.key, this.installer = false});
  @override
  State<DealerRegisterPage> createState() => _DealerRegisterPageState();
}

class _DealerRegisterPageState extends State<DealerRegisterPage> {
  final fullName = TextEditingController(), phone = TextEditingController(), business = TextEditingController(), city = TextEditingController(), username = TextEditingController(), password = TextEditingController();
  bool busy = false, obscure = true;
  String? message; bool success = false;
  @override void dispose(){for(final c in [fullName,phone,business,city,username,password]) c.dispose();super.dispose();}
  Future<void> _submit() async {
    setState(() { busy=true; message=null; success=false; });
    try {
      final r=await DealerApi.instance.register({'fullName':fullName.text.trim(),'phone':phone.text.trim(),'business':business.text.trim(),'city':city.text.trim(),'username':username.text.trim(),'password':password.text});
      if(!mounted)return;
      setState(() { success=r.ok; message=r.ok?tr('applicationSent'):(r.data['error']?.toString()??tr('loginFailed')); });
    } catch(_){if(mounted)setState(()=>message=tr('loginFailed'));}
    finally{if(mounted)setState(()=>busy=false);}
  }
  @override Widget build(BuildContext context)=>Scaffold(
    appBar: AppBar(title: Text(tr(widget.installer ? 'registerInstaller' : 'registerDealer'))),
    body: ListView(padding: const EdgeInsets.all(18),children:[
      Center(child:Image.asset('assets/images/alo_logo.png',width:150)),const SizedBox(height:18),
      for(final x in <(TextEditingController,String,IconData,TextInputType)>[(fullName,tr('fullName'),Icons.badge_outlined,TextInputType.name),(phone,tr('phone'),Icons.phone_outlined,TextInputType.phone),(business,tr('business'),Icons.storefront_outlined,TextInputType.text),(city,tr('city'),Icons.location_city_outlined,TextInputType.text),(username,tr('username'),Icons.person_outline,TextInputType.text)]) ...[
        TextField(controller:x.$1,keyboardType:x.$4,decoration:InputDecoration(labelText:x.$2,prefixIcon:Icon(x.$3))),const SizedBox(height:12)],
      TextField(controller:password,obscureText:obscure,decoration:InputDecoration(labelText:tr('password'),prefixIcon:const Icon(Icons.lock_outline),suffixIcon:IconButton(onPressed:()=>setState(()=>obscure=!obscure),icon:Icon(obscure?Icons.visibility_outlined:Icons.visibility_off_outlined)))),
      if(message!=null)...[const SizedBox(height:12),Text(message!,style:TextStyle(color:success?kGreen:Colors.redAccent,fontWeight:FontWeight.w700))],
      const SizedBox(height:18),SizedBox(height:52,child:FilledButton(onPressed:busy?null:_submit,child:busy?const CircularProgressIndicator():Text(tr('submitApplication')))),
    ]));
}

class DealerDashboardPage extends StatefulWidget {
  const DealerDashboardPage({super.key});
  @override State<DealerDashboardPage> createState() => _DealerDashboardPageState();
}

class _DealerDashboardPageState extends State<DealerDashboardPage> {
  bool loading = true;
  String? error;
  int section = 0;
  String category = 'all';
  final search = TextEditingController();
  Map<String, dynamic> me = {}, rewards = {};
  List<dynamic> products = [], announcements = [];
  final Map<int, int> cart = {};

  @override
  void initState() { super.initState(); _load(); }

  @override
  void dispose() { search.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final rs = await Future.wait([
        DealerApi.instance.me(),
        DealerApi.instance.products(),
        DealerApi.instance.rewards(),
        DealerApi.instance.announcements(),
      ]);
      if (!mounted) return;
      if (!rs[0].ok) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const DealerPage()));
        return;
      }
      setState(() {
        me = rs[0].data;
        products = (rs[1].data['products'] as List?) ?? [];
        rewards = rs[2].data;
        announcements = (rs[3].data['announcements'] as List?) ?? [];
        error = null;
      });
    } catch (_) {
      if (mounted) setState(() => error = tr('loginFailed'));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Map<String, dynamic> _product(int id) {
    for (final raw in products) {
      final p = Map<String, dynamic>.from(raw as Map);
      if ((p['id'] as num?)?.toInt() == id) return p;
    }
    return <String, dynamic>{};
  }

  int get cartCount => cart.values.fold(0, (a, b) => a + b);
  double get cartTotal => cart.entries.fold(0.0, (sum, e) {
    final p = _product(e.key);
    final price = double.tryParse('${p['trade_price'] ?? 0}') ?? 0;
    return sum + price * e.value;
  });

  List<Map<String, dynamic>> get filteredProducts {
    final q = search.text.trim().toLowerCase();
    return products.map((e) => Map<String, dynamic>.from(e as Map)).where((p) {
      final type = '${p['type'] ?? ''}'.toLowerCase();
      final text = '${p['name'] ?? ''} ${p['spec'] ?? ''} $type'.toLowerCase();
      return (category == 'all' || type == category) && (q.isEmpty || text.contains(q));
    }).toList();
  }

  List<String> get categories {
    final set = <String>{};
    for (final raw in products) {
      final t = '${(raw as Map)['type'] ?? ''}'.toLowerCase();
      if (t.isNotEmpty) set.add(t);
    }
    final list = set.toList()..sort();
    return list;
  }

  Future<void> _sendOrder() async {
    final items = cart.entries.where((e) => e.value > 0).toList();
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('emptyCart'))));
      return;
    }
    final lines = <String>[
      'Alo Solar Energy - ${tr('dealerOrder')}',
      '${me['name'] ?? ''} (${me['memberId'] ?? ''})',
    ];
    for (final e in items) {
      final p = _product(e.key);
      final price = double.tryParse('${p['trade_price'] ?? 0}') ?? 0;
      lines.add('${p['name']} × ${e.value} = \$${(price * e.value).toStringAsFixed(2)}');
    }
    lines.add('${tr('total')}: \$${cartTotal.toStringAsFixed(2)}');
    await launchUrl(
      Uri.parse('https://wa.me/9647764400440?text=${Uri.encodeComponent(lines.join('\n'))}'),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _logout() async {
    await DealerApi.instance.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const DealerPage()),
      (r) => r.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(tr('dealerDashboard')),
      actions: [
        IconButton(tooltip: tr('refresh'), onPressed: _load, icon: const Icon(Icons.refresh_rounded)),
      ],
    ),
    body: loading
        ? const Center(child: CircularProgressIndicator())
        : error != null
            ? _errorView()
            : IndexedStack(index: section, children: [_overview(), _catalog(), _cartPage(), _account()]),
    bottomNavigationBar: NavigationBar(
      selectedIndex: section,
      onDestinationSelected: (i) => setState(() => section = i),
      destinations: [
        NavigationDestination(icon: const Icon(Icons.space_dashboard_outlined), selectedIcon: const Icon(Icons.space_dashboard_rounded), label: tr('overview')),
        NavigationDestination(icon: const Icon(Icons.grid_view_outlined), selectedIcon: const Icon(Icons.grid_view_rounded), label: tr('catalog')),
        NavigationDestination(
          icon: Badge(isLabelVisible: cartCount > 0, label: Text('$cartCount'), child: const Icon(Icons.shopping_bag_outlined)),
          selectedIcon: Badge(isLabelVisible: cartCount > 0, label: Text('$cartCount'), child: const Icon(Icons.shopping_bag_rounded)),
          label: tr('cart'),
        ),
        NavigationDestination(icon: const Icon(Icons.person_outline_rounded), selectedIcon: const Icon(Icons.person_rounded), label: tr('profile')),
      ],
    ),
  );

  Widget _errorView() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.cloud_off_rounded, size: 58, color: kMuted),
        const SizedBox(height: 14),
        Text(error!, textAlign: TextAlign.center),
        const SizedBox(height: 14),
        FilledButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: Text(tr('refresh'))),
      ]),
    ),
  );

  Widget _overview() {
    final total = double.tryParse('${rewards['total'] ?? 0}') ?? 0;
    final target = double.tryParse('${rewards['target'] ?? 10000}') ?? 10000;
    final remaining = (target - total).clamp(0, target).toDouble();
    final progress = target <= 0 ? 0.0 : (total / target).clamp(0, 1).toDouble();
    final latest = announcements.isEmpty ? null : Map<String, dynamic>.from(announcements.first as Map);
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [kGreen.withOpacity(.22), kGreen.withOpacity(.06)]),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: kGreen.withOpacity(.28)),
            ),
            child: Row(children: [
              Container(
                width: 58, height: 58,
                decoration: BoxDecoration(color: Colors.black.withOpacity(.22), borderRadius: BorderRadius.circular(18)),
                padding: const EdgeInsets.all(7),
                child: Image.asset('assets/images/alo_logo.png', fit: BoxFit.contain),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${tr('welcomeDealer')}, ${me['name'] ?? ''}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text('${tr('dealerMember')} • ${me['memberId'] ?? ''}', style: const TextStyle(color: kMuted, fontWeight: FontWeight.w600)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: kGreen.withOpacity(.15), borderRadius: BorderRadius.circular(99)),
                child: Text(tr('approved'), style: const TextStyle(color: kGreen, fontWeight: FontWeight.w800)),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _metric(Icons.inventory_2_outlined, '${products.length}', tr('availableProducts'))),
            const SizedBox(width: 10),
            Expanded(child: _metric(Icons.shopping_bag_outlined, '$cartCount', tr('selectedItems'))),
          ]),
          const SizedBox(height: 10),
          _cashbackCard(progress, total, target, remaining),
          const SizedBox(height: 18),
          Text(tr('quickActions'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _quick(Icons.grid_view_rounded, tr('viewCatalog'), () => setState(() => section = 1))),
            const SizedBox(width: 10),
            Expanded(child: _quick(Icons.shopping_cart_checkout_rounded, tr('viewCart'), () => setState(() => section = 2))),
          ]),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: Text(tr('latestUpdate'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900))),
            if (announcements.length > 1) Text('${announcements.length}', style: const TextStyle(color: kMuted)),
          ]),
          const SizedBox(height: 10),
          if (latest == null)
            _emptyMessage(Icons.campaign_outlined, tr('noAnnouncements'))
          else
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0x1A52E19A), child: Icon(Icons.campaign_rounded, color: kGreen)),
                title: Text('${latest['title'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Padding(padding: const EdgeInsets.only(top: 6), child: Text('${latest['message'] ?? ''}', maxLines: 4, overflow: TextOverflow.ellipsis)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _metric(IconData icon, String value, String label) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: Theme.of(context).dividerColor.withOpacity(.18))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: kGreen),
      const SizedBox(height: 10),
      Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
      const SizedBox(height: 2),
      Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: kMuted, fontSize: 12)),
    ]),
  );

  Widget _quick(IconData icon, String label, VoidCallback action) => SizedBox(
    height: 56,
    child: OutlinedButton.icon(onPressed: action, icon: Icon(icon), label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis)),
  );

  Widget _cashbackCard(double progress, double total, double target, double remaining) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.savings_outlined, color: kGreen),
          const SizedBox(width: 8),
          Expanded(child: Text(tr('cashbackProgress'), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900))),
          Text('${(progress * 100).toStringAsFixed(0)}%', style: const TextStyle(color: kGreen, fontWeight: FontWeight.w900)),
        ]),
        const SizedBox(height: 14),
        LinearProgressIndicator(value: progress, minHeight: 9, borderRadius: BorderRadius.circular(99)),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('\$${total.toStringAsFixed(0)} / \$${target.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900)),
          Text('${tr('cashbackRemaining')}: \$${remaining.toStringAsFixed(0)}', style: const TextStyle(color: kMuted, fontSize: 12)),
        ]),
      ]),
    ),
  );

  Widget _catalog() => Column(children: [
    Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: TextField(
        controller: search,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: tr('searchProducts'),
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: search.text.isEmpty ? null : IconButton(onPressed: () { search.clear(); setState(() {}); }, icon: const Icon(Icons.close_rounded)),
        ),
      ),
    ),
    SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _chip('all', tr('allCategories')),
          ...categories.map((c) => _chip(c, c.toUpperCase())),
        ],
      ),
    ),
    Expanded(
      child: filteredProducts.isEmpty
          ? _emptyMessage(Icons.search_off_rounded, tr('emptyCart'))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
              itemCount: filteredProducts.length,
              itemBuilder: (context, i) => _productCard(filteredProducts[i]),
            ),
    ),
  ]);

  Widget _chip(String value, String label) => Padding(
    padding: const EdgeInsetsDirectional.only(end: 8),
    child: ChoiceChip(label: Text(label), selected: category == value, onSelected: (_) => setState(() => category = value)),
  );

  Widget _productCard(Map<String, dynamic> p) {
    final id = (p['id'] as num).toInt();
    final q = cart[id] ?? 0;
    final price = double.tryParse('${p['trade_price'] ?? 0}') ?? 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${p['name'] ?? ''}', style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w900)),
              if ('${p['spec'] ?? ''}'.isNotEmpty) ...[
                const SizedBox(height: 5),
                Text('${p['spec']}', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: kMuted, height: 1.35)),
              ],
            ])),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(color: kGreen.withOpacity(.12), borderRadius: BorderRadius.circular(30)),
              child: Text('${p['type'] ?? ''}'.toUpperCase(), style: const TextStyle(color: kGreen, fontWeight: FontWeight.w800, fontSize: 11)),
            ),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr('tradePrice'), style: const TextStyle(color: kMuted, fontSize: 12)),
              Text('\$${price.toStringAsFixed(2)}', style: const TextStyle(color: kGreen, fontSize: 19, fontWeight: FontWeight.w900)),
            ])),
            Container(
              decoration: BoxDecoration(border: Border.all(color: Theme.of(context).dividerColor.withOpacity(.22)), borderRadius: BorderRadius.circular(14)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(onPressed: q > 0 ? () => setState(() { if (q == 1) cart.remove(id); else cart[id] = q - 1; }) : null, icon: const Icon(Icons.remove_rounded)),
                SizedBox(width: 26, child: Text('$q', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900))),
                IconButton(onPressed: () => setState(() => cart[id] = q + 1), icon: const Icon(Icons.add_rounded, color: kGreen)),
              ]),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _cartPage() {
    final items = cart.entries.where((e) => e.value > 0).toList();
    if (items.isEmpty) return _emptyMessage(Icons.shopping_bag_outlined, tr('emptyCart'));
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
      children: [
        Row(children: [
          Expanded(child: Text(tr('orderSummary'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
          TextButton.icon(onPressed: () => setState(cart.clear), icon: const Icon(Icons.delete_outline), label: Text(tr('clearCart'))),
        ]),
        const SizedBox(height: 6),
        ...items.map((e) {
          final p = _product(e.key);
          final price = double.tryParse('${p['trade_price'] ?? 0}') ?? 0;
          return Card(
            margin: const EdgeInsets.only(bottom: 9),
            child: ListTile(
              title: Text('${p['name'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text('${e.value} × \$${price.toStringAsFixed(2)}'),
              trailing: Text('\$${(price * e.value).toStringAsFixed(2)}', style: const TextStyle(color: kGreen, fontWeight: FontWeight.w900)),
            ),
          );
        }),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: kGreen.withOpacity(.10), borderRadius: BorderRadius.circular(20), border: Border.all(color: kGreen.withOpacity(.22))),
          child: Row(children: [
            Expanded(child: Text(tr('total'), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
            Text('\$${cartTotal.toStringAsFixed(2)}', style: const TextStyle(color: kGreen, fontSize: 24, fontWeight: FontWeight.w900)),
          ]),
        ),
        const SizedBox(height: 14),
        SizedBox(height: 54, child: FilledButton.icon(onPressed: _sendOrder, icon: const Icon(Icons.send_rounded), label: Text(tr('sendOrder')))),
      ],
    );
  }

  Widget _account() {
    final cash = double.tryParse('${rewards['cashback'] ?? 0}') ?? 0;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
      children: [
        Center(child: Image.asset('assets/images/alo_logo.png', width: 128)),
        const SizedBox(height: 18),
        Card(child: Column(children: [
          ListTile(leading: const Icon(Icons.badge_outlined, color: kGreen), title: Text('${me['name'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Text('${me['username'] ?? ''}')),
          const Divider(height: 1),
          ListTile(leading: const Icon(Icons.confirmation_number_outlined, color: kGreen), title: Text(tr('memberId')), subtitle: Text('${me['memberId'] ?? ''}')),
          const Divider(height: 1),
          ListTile(leading: const Icon(Icons.verified_user_outlined, color: kGreen), title: Text(tr('accountStatus')), subtitle: Text(tr('approved'))),
          const Divider(height: 1),
          ListTile(leading: const Icon(Icons.savings_outlined, color: kGreen), title: Text(tr('cashbackLabel')), subtitle: Text('\$${cash.toStringAsFixed(2)}')),
        ])),
        const SizedBox(height: 18),
        Text(tr('announcements'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        if (announcements.isEmpty) _emptyMessage(Icons.campaign_outlined, tr('noAnnouncements')) else ...announcements.take(5).map((raw) {
          final a = Map<String, dynamic>.from(raw as Map);
          return Card(child: ListTile(leading: const Icon(Icons.campaign_outlined, color: kGreen), title: Text('${a['title'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Text('${a['message'] ?? ''}')));
        }),
        const SizedBox(height: 18),
        OutlinedButton.icon(onPressed: _logout, icon: const Icon(Icons.logout_rounded), label: Text(tr('logout'))),
      ],
    );
  }

  Widget _emptyMessage(IconData icon, String text) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 52, color: kMuted),
        const SizedBox(height: 12),
        Text(text, textAlign: TextAlign.center, style: const TextStyle(color: kMuted)),
      ]),
    ),
  );
}

class InstallerPage extends StatefulWidget {
  const InstallerPage({super.key});
  @override
  State<InstallerPage> createState() => _InstallerPageState();
}

class _InstallerPageState extends State<InstallerPage> {
  final code = TextEditingController();
  bool busy = false;
  Map<String, dynamic>? result;
  String? error;

  @override
  void dispose() {
    code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final value = code.text.trim();
    if (value.isEmpty) return;
    setState(() { busy = true; error = null; result = null; });
    try {
      final r = await DealerApi.instance.verifyInstaller(value);
      if (!mounted) return;
      final installer = r.data['installer'];
      if (r.ok && r.data['valid'] == true && installer is Map) {
        setState(() => result = Map<String, dynamic>.from(installer));
      } else {
        setState(() => error = r.data['error']?.toString() ?? tr('verifyInvalid'));
      }
    } catch (_) {
      if (mounted) setState(() => error = tr('verifyInvalid'));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('installer'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Icon(Icons.verified_user_outlined, size: 72, color: kGreen),
          const SizedBox(height: 14),
          Text(tr('verifyInstaller'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(tr('verifyNote'), textAlign: TextAlign.center, style: const TextStyle(color: kMuted, height: 1.5)),
          const SizedBox(height: 20),
          TextField(
            controller: code,
            onSubmitted: (_) => _verify(),
            decoration: InputDecoration(labelText: tr('installerCode'), prefixIcon: const Icon(Icons.qr_code_scanner)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: FilledButton(
              onPressed: busy ? null : _verify,
              child: busy ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)) : Text(tr('verify')),
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 16),
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.cancel_outlined, color: Colors.redAccent),
              const SizedBox(width: 10),
              Expanded(child: Text(error!, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700))),
            ]))),
          ],
          if (result != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [const Icon(Icons.verified_rounded, color: kGreen, size: 30), const SizedBox(width: 10), Expanded(child: Text(tr('verifyValid'), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)))]),
                  const SizedBox(height: 16),
                  _verifyRow(tr('memberId'), '${result!['memberId'] ?? ''}'),
                  _verifyRow(tr('installerName'), '${result!['fullName'] ?? ''}'),
                  if ('${result!['business'] ?? ''}'.isNotEmpty) _verifyRow(tr('business'), '${result!['business']}'),
                  if ('${result!['city'] ?? ''}'.isNotEmpty) _verifyRow(tr('city'), '${result!['city']}'),
                  if ('${result!['approvedAt'] ?? ''}'.isNotEmpty) _verifyRow(tr('approvedDate'), '${result!['approvedAt']}'),
                ]),
              ),
            ),
          ],
          const SizedBox(height: 22),
          const Divider(),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DealerRegisterPage(installer: true))),
            icon: const Icon(Icons.person_add_alt_1),
            label: Text(tr('registerInstaller')),
          ),
        ],
      ),
    );
  }

  Widget _verifyRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(color: kMuted, fontWeight: FontWeight.w700))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w800))),
        ]),
      );
}



class NotificationCenterPage extends StatefulWidget {
  const NotificationCenterPage({super.key});
  @override State<NotificationCenterPage> createState()=>_NotificationCenterPageState();
}
class _NotificationCenterPageState extends State<NotificationCenterPage>{
  bool loading=true; String? error; List<dynamic> items=[];
  @override void initState(){super.initState();_load();}
  Future<void> _load() async{
    setState(()=>loading=true);
    try{
      final r=await AdminApi.instance.publicNotifications();
      if(!mounted)return;
      setState((){items=(r.data['announcements'] as List?)??[];error=r.ok?null:(r.data['error']?.toString()??'HTTP ${r.status}');});
    }catch(e){if(mounted)setState(()=>error=e.toString());}
    finally{if(mounted)setState(()=>loading=false);}
  }
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:Text(atr('notificationCenter')),actions:[IconButton(onPressed:_load,icon:const Icon(Icons.refresh))]),
    body:loading?const Center(child:CircularProgressIndicator()):items.isEmpty
      ?Center(child:Padding(padding:const EdgeInsets.all(24),child:Column(mainAxisSize:MainAxisSize.min,children:[const Icon(Icons.notifications_none_rounded,size:56,color:kMuted),const SizedBox(height:12),Text(error??atr('noNotifications'),textAlign:TextAlign.center,style:const TextStyle(color:kMuted))])))
      :RefreshIndicator(onRefresh:_load,child:ListView.builder(padding:const EdgeInsets.all(14),itemCount:items.length,itemBuilder:(c,i){
        final a=Map<String,dynamic>.from(items[i] as Map);
        return Card(child:ListTile(leading:const CircleAvatar(backgroundColor:kSurface2,child:Icon(Icons.notifications_active_outlined,color:kGreen)),title:Text('${a['title']??''}',style:const TextStyle(fontWeight:FontWeight.w900)),subtitle:Padding(padding:const EdgeInsets.only(top:6),child:Text('${a['message']??''}')),trailing:Text('${a['kind']??''}',style:const TextStyle(color:kMuted,fontSize:11))));
      })),
  );
}

class AdminNotificationsPage extends StatefulWidget {
  const AdminNotificationsPage({super.key});
  @override State<AdminNotificationsPage> createState()=>_AdminNotificationsPageState();
}
class _AdminNotificationsPageState extends State<AdminNotificationsPage>{
  final title=TextEditingController(), message=TextEditingController();
  bool loading=true,sending=false; String audience='users',kind='general'; String? error;
  List<dynamic> appNotes=[],dealerNotes=[];
  @override void initState(){super.initState();_load();}
  @override void dispose(){title.dispose();message.dispose();super.dispose();}
  Future<void> _load() async{
    setState(()=>loading=true);
    try{final r=await AdminApi.instance.notifications();if(!mounted)return;setState((){appNotes=(r.data['appAnnouncements'] as List?)??[];dealerNotes=(r.data['dealerAnnouncements'] as List?)??[];error=r.ok?null:(r.data['error']?.toString()??'HTTP ${r.status}');});}
    catch(e){if(mounted)setState(()=>error=e.toString());}
    finally{if(mounted)setState(()=>loading=false);}
  }
  Future<void> _send() async{
    if(title.text.trim().isEmpty||message.text.trim().isEmpty)return;
    setState(()=>sending=true);
    try{final r=await AdminApi.instance.sendNotification(title.text.trim(),message.text.trim(),kind,audience);if(!mounted)return;if(r.ok){title.clear();message.clear();ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(atr('notificationSent'))));await _load();}else setState(()=>error=r.data['error']?.toString()??'HTTP ${r.status}');}
    finally{if(mounted)setState(()=>sending=false);}
  }
  @override Widget build(BuildContext context){
    final history=audience=='dealers'?dealerNotes:appNotes;
    return Scaffold(appBar:AppBar(title:Text(atr('notifications')),actions:[IconButton(onPressed:_load,icon:const Icon(Icons.refresh))]),body:loading?const Center(child:CircularProgressIndicator()):ListView(padding:const EdgeInsets.all(14),children:[
      if(error!=null)Card(child:ListTile(leading:const Icon(Icons.error_outline,color:Colors.redAccent),title:Text(error!))),
      Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(children:[
        DropdownButtonFormField<String>(value:audience,decoration:InputDecoration(labelText:atr('audience')),items:[DropdownMenuItem(value:'users',child:Text(atr('appUsers'))),DropdownMenuItem(value:'dealers',child:Text(atr('dealers'))),DropdownMenuItem(value:'all',child:Text(atr('everyone')))],onChanged:(v)=>setState(()=>audience=v??'users')),
        const SizedBox(height:10),
        DropdownButtonFormField<String>(value:kind,decoration:InputDecoration(labelText:atr('notifications')),items:['general','price','product','offer'].map((k)=>DropdownMenuItem(value:k,child:Text(atr(k)))).toList(),onChanged:(v)=>setState(()=>kind=v??'general')),
        const SizedBox(height:10),TextField(controller:title,decoration:InputDecoration(labelText:atr('notificationTitle'))),
        const SizedBox(height:10),TextField(controller:message,maxLines:4,decoration:InputDecoration(labelText:atr('notificationMessage'))),
        const SizedBox(height:12),SizedBox(width:double.infinity,height:48,child:FilledButton.icon(onPressed:sending?null:_send,icon:const Icon(Icons.send_rounded),label:Text(atr('sendNotification')))),
      ]))),
      const SizedBox(height:14),
      Row(children:[Expanded(child:Text(audience=='dealers'?atr('dealerNotifications'):atr('appNotifications'),style:const TextStyle(fontSize:18,fontWeight:FontWeight.w900))),Text('${history.length}',style:const TextStyle(color:kMuted))]),
      const SizedBox(height:8),
      if(history.isEmpty)Padding(padding:const EdgeInsets.symmetric(vertical:28),child:Center(child:Text(atr('noNotifications'),style:const TextStyle(color:kMuted))))else ...history.take(30).map((raw){final a=Map<String,dynamic>.from(raw as Map);return Card(child:ListTile(leading:const Icon(Icons.notifications_outlined,color:kGreen),title:Text('${a['title']??''}',style:const TextStyle(fontWeight:FontWeight.w900)),subtitle:Text('${a['message']??''}'),trailing:Text('${a['kind']??''}',style:const TextStyle(color:kMuted,fontSize:11))));}),
    ]));
  }
}

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  @override State<AdminPage> createState()=>_AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final user=TextEditingController();
  final pass=TextEditingController();
  final totp=TextEditingController();
  bool checking=true,busy=false,obscure=true;
  String? error;

  @override void initState(){super.initState();_check();}
  @override void dispose(){user.dispose();pass.dispose();totp.dispose();super.dispose();}

  Future<void> _check() async {
    try{
      final r=await AdminApi.instance.me();
      if(r.ok&&mounted){
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(_)=>const AdminDashboardPage()));
        return;
      }
    }catch(_){}
    if(mounted)setState(()=>checking=false);
  }

  Future<void> _login() async {
    if(user.text.trim().isEmpty||pass.text.isEmpty)return;
    setState((){busy=true;error=null;});
    try{
      final r=await AdminApi.instance.login(user.text.trim(),pass.text,totp:totp.text.trim());
      if(!mounted)return;
      if(r.ok){
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(_)=>const AdminDashboardPage()));
      }else{
        setState(()=>error=r.data['error']?.toString()??'HTTP ${r.status}');
      }
    }catch(e){if(mounted)setState(()=>error=e.toString());}
    finally{if(mounted)setState(()=>busy=false);}
  }

  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:Text(atr('adminLogin'))),
    body:SafeArea(child:checking?const Center(child:CircularProgressIndicator()):ListView(
      padding:const EdgeInsets.all(18),children:[
        Center(child:Image.asset('assets/images/alo_logo.png',width:170)),
        const SizedBox(height:22),
        TextField(controller:user,textInputAction:TextInputAction.next,decoration:InputDecoration(labelText:atr('username'),prefixIcon:const Icon(Icons.person_outline))),
        const SizedBox(height:12),
        TextField(controller:pass,obscureText:obscure,textInputAction:TextInputAction.next,decoration:InputDecoration(labelText:atr('password'),prefixIcon:const Icon(Icons.lock_outline),suffixIcon:IconButton(onPressed:()=>setState(()=>obscure=!obscure),icon:Icon(obscure?Icons.visibility_outlined:Icons.visibility_off_outlined)))),
        const SizedBox(height:12),
        TextField(controller:totp,keyboardType:TextInputType.number,onSubmitted:(_)=>_login(),decoration:InputDecoration(labelText:atr('twoFactorCode'),prefixIcon:const Icon(Icons.shield_outlined))),
        if(error!=null)...[const SizedBox(height:12),Text(error!,style:const TextStyle(color:Colors.redAccent,fontWeight:FontWeight.w700))],
        const SizedBox(height:18),
        SizedBox(height:52,child:FilledButton(onPressed:busy?null:_login,child:busy?const SizedBox(width:22,height:22,child:CircularProgressIndicator(strokeWidth:2)):Text(atr('login')))),
      ],
    )),
  );
}

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});
  @override State<AdminDashboardPage> createState()=>_AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool loading=true;
  String filter='pending';
  String? error;
  List<dynamic> applications=[];
  final Set<int> busyIds={};
  final search=TextEditingController();

  @override void dispose(){search.dispose();super.dispose();}

  @override void initState(){super.initState();_load();}

  Future<void> _load() async {
    setState((){loading=true;error=null;});
    try{
      final r=await AdminApi.instance.applications();
      if(!mounted)return;
      if(r.ok){
        setState(()=>applications=(r.data['applications'] as List?)??[]);
      }else{
        setState(()=>error=r.data['error']?.toString()??'HTTP ${r.status}');
      }
    }catch(e){if(mounted)setState(()=>error=e.toString());}
    finally{if(mounted)setState(()=>loading=false);}
  }

  Future<void> _action(Map<String,dynamic> a,String action) async {
    final id=int.tryParse('${a['id']}')??0;
    if(id==0||busyIds.contains(id))return;
    final key=switch(action){'approve'=>'approveConfirm','reject'=>'rejectConfirm','disable'=>'disableConfirm','unban'=>'unbanConfirm',_=>'approveConfirm'};
    final ok=await showDialog<bool>(context:context,builder:(dctx)=>AlertDialog(
      title:Text('${a['full_name']??a['username']??''}'),
      content:Text(atr(key)),
      actions:[
        TextButton(onPressed:()=>Navigator.pop(dctx,false),child:Text(atr('cancel'))),
        FilledButton(onPressed:()=>Navigator.pop(dctx,true),child:Text(atr('confirm'))),
      ],
    ));
    if(ok!=true||!mounted)return;
    setState(()=>busyIds.add(id));
    try{
      final r=await AdminApi.instance.applicationAction(id,action);
      if(!mounted)return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(r.ok?atr('requestUpdated'):(r.data['error']?.toString()??'HTTP ${r.status}'))));
      if(r.ok)await _load();
    }finally{if(mounted)setState(()=>busyIds.remove(id));}
  }

  Future<void> _logout() async {
    await AdminApi.instance.logout();
    if(!mounted)return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(_)=>const AdminPage()));
  }

  @override Widget build(BuildContext context){
    final counts=<String,int>{
      'all':applications.length,
      'pending':applications.where((x)=>'${(x as Map)['status']}'=='pending').length,
      'approved':applications.where((x)=>'${(x as Map)['status']}'=='approved').length,
      'rejected':applications.where((x)=>'${(x as Map)['status']}'=='rejected').length,
      'disabled':applications.where((x)=>'${(x as Map)['status']}'=='disabled').length,
    };
    final q=search.text.trim().toLowerCase();
    final shown=applications.where((raw){
      final a=raw as Map;
      final matchesFilter=filter=='all'||'${a['status']}'==filter;
      if(!matchesFilter)return false;
      if(q.isEmpty)return true;
      final hay='${a['full_name']??''} ${a['username']??''} ${a['phone']??''} ${a['business']??''} ${a['city']??''}'.toLowerCase();
      return hay.contains(q);
    }).toList();
    return Scaffold(
      appBar:AppBar(title:Text(atr('adminDashboard')),actions:[IconButton(tooltip:atr('notifications'),onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const AdminNotificationsPage())),icon:const Icon(Icons.notifications_active_outlined)),IconButton(tooltip:atr('refresh'),onPressed:_load,icon:const Icon(Icons.refresh)),IconButton(tooltip:atr('logout'),onPressed:_logout,icon:const Icon(Icons.logout))]),
      body:loading?const Center(child:CircularProgressIndicator()):RefreshIndicator(
        onRefresh:_load,
        child:ListView(padding:const EdgeInsets.all(12),children:[
          SingleChildScrollView(scrollDirection:Axis.horizontal,child:Row(children:['pending','approved','rejected','disabled','all'].map((f)=>Padding(
            padding:const EdgeInsetsDirectional.only(end:8),child:FilterChip(selected:filter==f,label:Text('${atr(f)} (${counts[f]??0})'),onSelected:(_)=>setState(()=>filter=f)),
          )).toList())),
          const SizedBox(height:10),
          TextField(controller:search,onChanged:(_)=>setState((){}),decoration:InputDecoration(prefixIcon:const Icon(Icons.search),hintText:atr('searchInstaller'),suffixIcon:search.text.isEmpty?null:IconButton(onPressed:(){search.clear();setState((){});},icon:const Icon(Icons.close)))),
          const SizedBox(height:10),
          if(error!=null)Card(child:ListTile(leading:const Icon(Icons.error_outline,color:Colors.redAccent),title:Text(error!),trailing:IconButton(onPressed:_load,icon:const Icon(Icons.refresh)))),
          if(shown.isEmpty&&error==null)Padding(padding:const EdgeInsets.symmetric(vertical:50),child:Column(children:[const Icon(Icons.inbox_outlined,size:50,color:kMuted),const SizedBox(height:12),Text(atr('noDealerRequests'),style:const TextStyle(color:kMuted))])),
          ...shown.map((raw){
            final a=Map<String,dynamic>.from(raw as Map);
            final status='${a['status']??''}';
            final id=int.tryParse('${a['id']}')??0;
            final busy=busyIds.contains(id);
            final member=id>0?'ALO-${id.toString().padLeft(6,'0')}':'—';
            return Card(child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Row(children:[CircleAvatar(backgroundColor:kSurface2,child:Text(('${a['full_name']??''}'.trim().isNotEmpty?'${a['full_name']}'.trim()[0]:'?').toUpperCase(),style:const TextStyle(color:kGreen,fontWeight:FontWeight.w900))),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('${a['full_name']??''}',style:const TextStyle(fontSize:17,fontWeight:FontWeight.w900)),Text('@${a['username']??''}',style:const TextStyle(color:kMuted))])),_adminStatus(status)]),
              const SizedBox(height:12),
              _adminInfo(Icons.phone_outlined,'${a['phone']??'—'}'),
              if('${a['business']??''}'.trim().isNotEmpty)_adminInfo(Icons.storefront_outlined,'${a['business']}'),
              if('${a['city']??''}'.trim().isNotEmpty)_adminInfo(Icons.location_city_outlined,'${a['city']}'),
              _adminInfo(Icons.badge_outlined,'${atr('memberId')}: $member'),
              _adminInfo(Icons.shopping_bag_outlined,'${atr('purchases')}: ${a['purchase_count']??0}'),
              _adminInfo(Icons.savings_outlined,'${atr('rewardTotal')}: \$${double.tryParse('${a['reward_total']??0}')?.toStringAsFixed(2)??'0.00'}'),
              if('${a['created_at']??''}'.trim().isNotEmpty)_adminInfo(Icons.calendar_today_outlined,'${atr('registered')}: ${a['created_at']}'),
              if('${a['approved_at']??''}'.trim().isNotEmpty)_adminInfo(Icons.verified_outlined,'${atr('approvedDate')}: ${a['approved_at']}'),
              const SizedBox(height:12),
              if(busy)const LinearProgressIndicator(minHeight:2)else Wrap(spacing:8,runSpacing:8,children:[
                if(status=='pending')FilledButton.icon(onPressed:()=>_action(a,'approve'),icon:const Icon(Icons.check),label:Text(atr('approve'))),
                if(status=='pending')OutlinedButton.icon(onPressed:()=>_action(a,'reject'),icon:const Icon(Icons.close),label:Text(atr('reject'))),
                if(status=='approved')OutlinedButton.icon(onPressed:()=>_action(a,'disable'),icon:const Icon(Icons.block),label:Text(atr('disable'))),
                if(status=='disabled')FilledButton.icon(onPressed:()=>_action(a,'unban'),icon:const Icon(Icons.lock_open),label:Text(atr('unban'))),
              ]),
            ])));
          }),
        ]),
      ),
    );
  }

  Widget _adminInfo(IconData icon,String text)=>Padding(padding:const EdgeInsets.only(bottom:6),child:Row(children:[Icon(icon,size:17,color:kMuted),const SizedBox(width:8),Expanded(child:Text(text,style:const TextStyle(color:kMuted)))]));
  Widget _adminStatus(String status)=>Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:5),decoration:BoxDecoration(color:status=='approved'?kGreen.withOpacity(.15):kSurface2,borderRadius:BorderRadius.circular(20)),child:Text(atr(status),style:TextStyle(color:status=='approved'?kGreen:kMuted,fontWeight:FontWeight.w800,fontSize:12)));
}

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(tr('contact'))),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(child: Image.asset('assets/images/alo_logo.png', width: 220)),
            const SizedBox(height: 20),
            _contact(Icons.phone, tr('phone'), '0776 440 0440 – 0750 476 0468', () => launchUrl(Uri.parse('tel:07504760468'))),
            _contact(Icons.email_outlined, tr('email'), 'alosolarenergy2025@gmail.com', () async { await Clipboard.setData(const ClipboardData(text: 'alosolarenergy2025@gmail.com')); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('emailCopied')))); }),
            _contact(Icons.location_on_outlined, tr('location'), tr('address'), () => launchUrl(Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('Alo Solar Energy Erbil New Erbil Opposite Said Jafar Mosque')}'), mode: LaunchMode.externalApplication)),
            const SizedBox(height: 12),
            FilledButton.icon(onPressed: () => launchUrl(Uri.parse('https://wa.me/9647764400440'), mode: LaunchMode.externalApplication), icon: const Icon(Icons.chat), label: const Text('WhatsApp')),
          ],
        ),
      );
  Widget _contact(IconData icon, String title, String value, VoidCallback? onTap) => Card(
        child: ListTile(leading: Icon(icon, color: kGreen), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Text(value), onTap: onTap),
      );
}
