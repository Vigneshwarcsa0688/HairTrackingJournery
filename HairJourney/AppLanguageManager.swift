import SwiftUI

// MARK: - Supported App Languages
enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    case hindi = "hi"
    case tamil = "ta"
    case telugu = "te"
    case arabic = "ar"
    case italian = "it"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Español (Spanish)"
        case .french: return "Français (French)"
        case .german: return "Deutsch (German)"
        case .hindi: return "हिन्दी (Hindi)"
        case .tamil: return "தமிழ் (Tamil)"
        case .telugu: return "తెలుగు (Telugu)"
        case .arabic: return "العربية (Arabic)"
        case .italian: return "Italiano (Italian)"
        }
    }
    
    var nativeName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Español"
        case .french: return "Français"
        case .german: return "Deutsch"
        case .hindi: return "हिन्दी"
        case .tamil: return "தமிழ்"
        case .telugu: return "తెలుగు"
        case .arabic: return "العربية"
        case .italian: return "Italiano"
        }
    }
    
    var flag: String {
        switch self {
        case .english: return "🇬🇧"
        case .spanish: return "🇪🇸"
        case .french: return "🇫🇷"
        case .german: return "🇩🇪"
        case .hindi: return "🇮🇳"
        case .tamil: return "🇮🇳"
        case .telugu: return "🇮🇳"
        case .arabic: return "🇸🇦"
        case .italian: return "🇮🇹"
        }
    }
    
    var shortCode: String {
        switch self {
        case .english: return "EN"
        case .spanish: return "ES"
        case .french: return "FR"
        case .german: return "DE"
        case .hindi: return "HI"
        case .tamil: return "TA"
        case .telugu: return "TE"
        case .arabic: return "AR"
        case .italian: return "IT"
        }
    }
}

// MARK: - Centralized App Language Manager
final class AppLanguageManager: ObservableObject {
    static let shared = AppLanguageManager()
    
    @Published var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "app_selected_language")
        }
    }
    
    private init() {
        if let saved = UserDefaults.standard.string(forKey: "app_selected_language"),
           let lang = AppLanguage(rawValue: saved) {
            self.currentLanguage = lang
        } else {
            self.currentLanguage = .english
        }
    }
    
    func setLanguage(_ language: AppLanguage) {
        withAnimation(.easeInOut(duration: 0.25)) {
            self.currentLanguage = language
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    func text(_ key: String) -> String {
        let translations = AppLanguageManager.dictionary[currentLanguage] ?? AppLanguageManager.dictionary[.english]!
        return translations[key] ?? AppLanguageManager.dictionary[.english]?[key] ?? key
    }
    
    // MARK: - Multi-Language Comprehensive Dictionary
    private static let dictionary: [AppLanguage: [String: String]] = [
        .english: [
            "app_title": "Hair Journey Tracker",
            "welcome_title": "Welcome",
            "choose_language": "Choose Your Language",
            "choose_language_desc": "Select your preferred language to customize your entire hair wellness experience.",
            "continue_button": "Continue",
            "home": "Home",
            "profile": "Profile",
            "save_changes": "Save Changes",
            "logout": "Log Out",
            "delete_account": "Delete Account",
            "good_morning": "Good Morning",
            "good_afternoon": "Good Afternoon",
            "good_evening": "Good Evening",
            "verified_member": "Verified Member",
            "app_language": "App Language",
            "change": "Change",
            "specialization_and_languages": "Specialization & Languages",
            "language_preferences": "Language Preferences",
            "preferences": "Preferences",
            "clinical_specialization": "Clinical Specialization",
            "languages_spoken": "Languages Spoken",
            "preferred_consultation_lang": "Preferred Consultation Language",
            "select_language": "Select Language",
            "switch_language_subtitle": "Select your preferred app language for all screens",
            "expert_workspace": "EXPERT WORKSPACE",
            "member_portfolios": "Member Portfolios",
            "member_portfolios_desc": "Comprehensive hair history, multi-angle photos & routine adherence",
            "appointment_requests": "Appointment Requests",
            "appointment_requests_desc": "Review member booking requests & confirm 1-on-1 sessions",
            "consultation_slots": "My Consultation Slots",
            "consultation_slots_desc": "Manage open times and live consultation bookings",
            "quiz_reports_feed": "Quiz Reports Feed",
            "quiz_reports_feed_desc": "View 13-question scaling assessments",
            "hair_photo_reviews": "Hair Photo Reviews",
            "hair_photo_reviews_desc": "Examine member scalp photos & provide guidance",
            "consultations_section": "Consultations & Schedule",
            "progress_data_section": "Progress Reviews & Data",
            "book_consultation": "Book Consultation",
            "request_consultation": "Request Consultation",
            "select_slot_subtitle": "Select a certified specialist and preferred consultation slot",
            "no_open_slots": "No Open Slots Right Now",
            "no_open_slots_desc": "Hair specialists haven't published new availability yet. Please check back later.",
            "weekly_momentum": "Weekly Momentum",
            "goal": "GOAL",
            "streak": "Streak",
            "logged_target": "of 7 days logged at full target",
            "open_serum_calendar": "Open Serum Routine Calendar",
            "daily_treatment_section": "Daily Routine & Care",
            "compliance": "Compliance",
            "serum_calendar": "Serum Calendar",
            "serum_calendar_desc": "Log doses, set alarms & track compliance",
            "my_routines": "My Routines",
            "my_routines_desc": "Active products & recommended regimens",
            "visual_progress_section": "Visual Progress & Photos",
            "tracking": "Tracking",
            "hair_progress_tracker": "Hair Progress Tracker",
            "before_and_after": "BEFORE & AFTER",
            "growth_comparison": "Side-by-side growth comparison",
            "upload_photos": "Upload Photos",
            "upload_photos_desc": "Log Frontal, Lateral & Vertex angles",
            "my_hair_photos": "My Hair Photos",
            "my_hair_photos_desc": "View albums & expert review remarks",
            "assessments_and_experts": "Assessments & Experts",
            "specialist_care": "Specialist Care",
            "hair_growth_quiz": "Hair Growth Quiz",
            "hair_growth_quiz_desc": "Assess scalp conditions, family genetics & hair fall patterns",
            "quiz_reports": "Quiz Reports",
            "quiz_reports_desc": "Review your past assessments & scores",
            "my_consultations": "My Consultations",
            "my_consultations_desc": "Check approved, pending & past bookings",
        
            "select_portal": "SELECT YOUR PORTAL",
            "member_user": "Member / User",
            "member_portal_desc": "Track hair transformation, log serum doses & consult hair experts",
            "member_badge": "MEMBER",
            "expert_specialist": "Hair Specialist / Expert",
            "expert_portal_desc": "Review member portfolios, assess hair progress & manage consultations",
            "expert_badge": "EXPERT",
            "tagline": "Personalized Hair Care & Progress Tracking",
            "photo_journey": "Photo Journey",
            "expert_care": "Expert Care",
            "daily_habits": "Daily Habits",
            "privacy_policy": "Privacy Policy",
            "terms_of_service": "Terms of Service",
            "about": "About",
            "welcome_back": "Welcome Back",
            "expert_portal": "Expert Portal",
            "user_login_subtitle": "Sign in to continue your hair care journey",
            "doctor_login_subtitle": "Sign in to manage member consults & reviews",
            "email_address": "Email Address",
            "password": "Password",
            "forgot_password": "Forgot Password?",
            "log_in": "Log In",
            "dont_have_account": "Don't have an account?",
            "register": "Register",
            "enter_email_password": "Please enter both email and password",
            "create_account": "Create Account",
            "registering_as": "Registering as",
            "full_name": "Full Name",
            "phone_placeholder": "Phone (Optional)",
            "location_placeholder": "Location / City (Optional)",
            "date_of_birth": "Date of Birth",
            "password_req_placeholder": "Password (8+ chars, upper, lower, special)",
            "confirm_password": "Confirm Password",
            "already_have_account": "Already have an account?",
            "reset_password": "Reset Password",
            "reset_password_desc": "Verify your registered email and choose a new secure password.",
            "step1_verify_email": "Step 1: Verify Email",
            "verify_email_btn": "Verify Email",
            "step2_new_password": "Step 2: Set New Password",
            "new_password_placeholder": "Enter New Password",
            "update_password_btn": "Update Password",
        ],
        .telugu: [
            "app_title": "హెయిర్ జర్నీ ట్రాకర్",
            "welcome_title": "స్వాగతం",
            "choose_language": "మీ భాషను ఎంచుకోండి",
            "choose_language_desc": "వ్యక్తిగతీకరించిన హెయిర్ కేర్ అనుభవం కోసం మీ ప్రాధాన్య భాషను ఎంచుకోండి.",
            "continue_button": "కొనసాగించండి",
            "home": "హోమ్",
            "profile": "ప్రొఫైల్",
            "save_changes": "మార్పులను సేవ్ చేయండి",
            "logout": "లాగ్ అవుట్",
            "delete_account": "ఖాతాను తొలగించండి",
            "good_morning": "శుభోదయం",
            "good_afternoon": "శుభ మధ్యాహ్నం",
            "good_evening": "శుభ సాయంత్రం",
            "verified_member": "ధృవీకరించబడిన సభ్యుడు",
            "app_language": "యాప్ భాష",
            "change": "మార్చండి",
            "specialization_and_languages": "స్పెషలైజేషన్ & భాషలు",
            "language_preferences": "భాష ప్రాధాన్యతలు",
            "preferences": "ప్రాధాన్యతలు",
            "clinical_specialization": "క్లినికల్ స్పెషలైజేషన్",
            "languages_spoken": "మాట్లాడే భాషలు",
            "preferred_consultation_lang": "ప్రాధాన్య సంప్రదింపు భాష",
            "select_language": "భాషను ఎంచుకోండి",
            "switch_language_subtitle": "యాప్‌లోని అన్ని స్క్రీన్‌ల కోసం మీ ప్రాధాన్య భాషను ఎంచుకోండి",
            "expert_workspace": "నిపుణుల కార్యస్థలం",
            "member_portfolios": "సభ్యుల పోర్ట్‌ఫోలియోలు",
            "member_portfolios_desc": "సమగ్ర జుట్టు చరిత్ర, బహుళ కోణాల ఫోటోలు & సంరక్షణ",
            "appointment_requests": "అపాయింట్‌మెంట్ అభ్యర్థనలు",
            "appointment_requests_desc": "సభ్యుల బుకింగ్ అభ్యర్థనలను సమీక్షించండి & ధృవీకరించండి",
            "consultation_slots": "నా సంప్రదింపు స్లాట్లు",
            "consultation_slots_desc": "అందుబాటులో ఉన్న సమయాలు & లైవ్ సంప్రదింపులను నిర్వహించండి",
            "quiz_reports_feed": "క్విజ్ నివేదికల ఫీడ్",
            "quiz_reports_feed_desc": "13-ప్రశ్నల మూల్యాంకనాలను వీక్షించండి",
            "hair_photo_reviews": "జుట్టు ఫోటో సమీక్షలు",
            "hair_photo_reviews_desc": "సభ్యుల స్కాల్ప్ ఫోటోలను పరిశీలించి మార్గదర్శకత్వం అందించండి",
            "consultations_section": "సంప్రదింపులు & షెడ్యూల్",
            "progress_data_section": "పురోగతి సమీక్షలు & డేటా",
            "book_consultation": "సంప్రదింపును బుక్ చేయండి",
            "request_consultation": "సంప్రదింపును అభ్యర్థించండి",
            "select_slot_subtitle": "ధృవీకరించబడిన నిపుణుడిని మరియు అనుకూల సమయాన్ని ఎంచుకోండి",
            "no_open_slots": "ప్రస్తుతం ఏ స్లాట్లు అందుబాటులో లేవు",
            "no_open_slots_desc": "హెయిర్ నిపుణులు ఇంకా కొత్త సమయాలను ప్రకటించలేదు. దయచేసి కాసేపటి తర్వాత తనిఖీ చేయండి.",
            "weekly_momentum": "వారపు పురోగతి",
            "goal": "లక్ష్యం",
            "streak": "స్ట్రీక్",
            "logged_target": "రోజులు లక్ష్యాన్ని పూర్తి చేశారు",
            "open_serum_calendar": "సీరమ్ దినచర్య క్యాలెండర్‌ని తెరవండి",
            "daily_treatment_section": "రోజువారీ సంరక్షణ & అలవాట్లు",
            "compliance": "లక్ష్యం",
            "serum_calendar": "సీరమ్ క్యాలెండర్",
            "serum_calendar_desc": "డోస్‌లను నమోదు చేయండి మరియు సమయాన్ని ట్రాక్ చేయండి",
            "my_routines": "నా సంరక్షణ పద్ధతులు",
            "my_routines_desc": "క్రియాశీల ఉత్పత్తులు & సూచించిన నియమాలు",
            "visual_progress_section": "దృశ్య పురోగతి & ఫోటోలు",
            "tracking": "ట్రాకింగ్",
            "hair_progress_tracker": "జుట్టు పెరుగుదల ట్రాకర్",
            "before_and_after": "ముందు & తర్వాత",
            "growth_comparison": "పెరుగుదల పోలిక",
            "upload_photos": "ఫోటోలను అప్‌లోడ్ చేయండి",
            "upload_photos_desc": "ముందు, పక్క మరియు పైభాగం కోణాలను నమోదు చేయండి",
            "my_hair_photos": "నా జుట్టు ఫోటోలు",
            "my_hair_photos_desc": "ఆల్బమ్‌లు & నిపుణుల సమీక్ష వ్యాఖ్యలను చూడండి",
            "assessments_and_experts": "మూల్యాంకనాలు & నిపుణులు",
            "specialist_care": "ప్రత్యేక సంరక్షణ",
            "hair_growth_quiz": "జుట్టు పెరుగుదల క్విజ్",
            "hair_growth_quiz_desc": "స్కాల్ప్ పరిస్థితులు, జన్యువులు & రాలడాన్ని అంచనా వేయండి",
            "quiz_reports": "క్విజ్ నివేదికలు",
            "quiz_reports_desc": "గత పరీక్షలు & స్కోర్‌లను సమీక్షించండి",
            "my_consultations": "నా సంప్రదింపులు",
            "my_consultations_desc": "ధృవీకరించబడిన & పెండింగ్ బుకింగ్‌లను చూడండి",
        
            "select_portal": "మీ పోర్టల్‌ను ఎంచుకోండి",
            "member_user": "సభ్యుడు / వినియోగదారు",
            "member_portal_desc": "జుట్టు మార్పును ట్రాక్ చేయండి, సీరమ్ మోతాదులను నమోదు చేయండి & నిపుణులను సంప్రదించండి",
            "member_badge": "సభ్యుడు",
            "expert_specialist": "హెయిర్ స్పెషలిస్ట్ / నిపుణుడు",
            "expert_portal_desc": "సభ్యుల పోర్ట్‌ఫోలియోలను సమీక్షించండి & సంప్రదింపులను నిర్వహించండి",
            "expert_badge": "నిపుణుడు",
            "tagline": "వ్యక్తిగతీకరించిన హెయిర్ కేర్ & ప్రోగ్రెస్ ట్రాకింగ్",
            "photo_journey": "ఫోటో ప్రయాణం",
            "expert_care": "నిపుణుల సంరక్షణ",
            "daily_habits": "రోజువారీ అలవాట్లు",
            "privacy_policy": "గోప్యతా విధానం",
            "terms_of_service": "సేవా నిబంధనలు",
            "about": "గురించి",
            "welcome_back": "తిరిగి స్వాగతం",
            "expert_portal": "నిపుణుల పోర్టల్",
            "user_login_subtitle": "మీ హెయిర్ కేర్ ప్రయాణాన్ని కొనసాగించడానికి లాగిన్ చేయండి",
            "doctor_login_subtitle": "సభ్యుల సంప్రదింపులను నిర్వహించడానికి లాగిన్ చేయండి",
            "email_address": "ఇమెయిల్ చిరునామా",
            "password": "పాస్‌వర్డ్",
            "forgot_password": "పాస్‌వర్డ్ మర్చిపోయారా?",
            "log_in": "లాగిన్",
            "dont_have_account": "ఖాతా లేదా?",
            "register": "నమోదు చేయండి",
            "enter_email_password": "దయచేసి ఇమెయిల్ మరియు పాస్‌వర్డ్ రెండింటినీ నమోదు చేయండి",
            "create_account": "ఖాతాను సృష్టించండి",
            "registering_as": "నమోదు రకం:",
            "full_name": "పూర్తి పేరు",
            "phone_placeholder": "ఫోన్ నంబర్ (ఐచ్ఛికం)",
            "location_placeholder": "నగరం / స్థానం (ఐచ్ఛికం)",
            "date_of_birth": "పుట్టిన తేదీ",
            "password_req_placeholder": "పాస్‌వర్డ్ (8+ అక్షరాలు, సంఖ్యలు, గుర్తులు)",
            "confirm_password": "పాస్‌వర్డ్‌ను నిర్ధారించండి",
            "already_have_account": "ఇప్పటికే ఖాతా ఉందా?",
            "reset_password": "పాస్‌వర్డ్ రీసెట్",
            "reset_password_desc": "మీ నమోదిత ఇమెయిల్‌ను ధృవీకరించండి మరియు కొత్త పాస్‌వర్డ్‌ను ఎంచుకోండి.",
            "step1_verify_email": "దశ 1: ఇమెయిల్ ధృవీకరించండి",
            "verify_email_btn": "ఇమెయిల్ ధృవీకరించండి",
            "step2_new_password": "దశ 2: కొత్త పాస్‌వర్డ్ సెట్ చేయండి",
            "new_password_placeholder": "కొత్త పాస్‌వర్డ్ నమోదు చేయండి",
            "update_password_btn": "పాస్‌వర్డ్‌ను నవీకరించండి",
        ],
        .tamil: [
            "app_title": "ஹேர் ஜர்னி டிராக்கர்",
            "welcome_title": "வணக்கம்",
            "choose_language": "உங்கள் மொழியைத் தேர்ந்தெடுக்கவும்",
            "choose_language_desc": "உங்கள் தனிப்பயனாக்கப்பட்ட தலைமுடி பராமரிப்பு அனுபவத்திற்கு மொழியைத் தேர்ந்தெடுக்கவும்.",
            "continue_button": "தொடரவும்",
            "home": "முகப்பு",
            "profile": "சுயவிவரம்",
            "save_changes": "மாற்றங்களைச் சேமிக்கவும்",
            "logout": "வெளியேறு",
            "delete_account": "கணக்கை நீக்கு",
            "good_morning": "காலை வணக்கம்",
            "good_afternoon": "மதிய வணக்கம்",
            "good_evening": "மாலை வணக்கம்",
            "verified_member": "சரிபார்க்கப்பட்ட உறுப்பினர்",
            "app_language": "பயன்பாட்டு மொழி",
            "change": "மாற்று",
            "specialization_and_languages": "சிறப்புத் துறை & மொழிகள்",
            "language_preferences": "மொழி விருப்பங்கள்",
            "preferences": "விருப்பங்கள்",
            "clinical_specialization": "மருத்துவ சிறப்புத் துறை",
            "languages_spoken": "பேசப்படும் மொழிகள்",
            "preferred_consultation_lang": "விருப்ப ஆலோசனை மொழி",
            "select_language": "மொழியைத் தேர்ந்தெடுக்கவும்",
            "switch_language_subtitle": "பயன்பாட்டிற்கான உங்கள் விருப்ப மொழியைத் தேர்ந்தெடுக்கவும்",
            "expert_workspace": "நிபுணர் பணியிடம்",
            "member_portfolios": "உறுப்பினர் போர்ட்ஃபோலியோ",
            "member_portfolios_desc": "முடி வரலாறு, பல கோண புகைப்படங்கள் மற்றும் பராமரிப்பு",
            "appointment_requests": "ஆலோசனை கோரிக்கைகள்",
            "appointment_requests_desc": "உறுப்பினர் சந்திப்புகளை ஆய்வு செய்து உறுதிப்படுத்தவும்",
            "consultation_slots": "எனது ஆலோசனை நேரங்கள்",
            "consultation_slots_desc": "கிடைக்கும் நேரங்கள் மற்றும் சந்திப்புகளை நிர்வகிக்கவும்",
            "quiz_reports_feed": "வினாடி வினா அறிக்கைகள்",
            "quiz_reports_feed_desc": "13-கேள்வி மதிப்பீடுகளைப் பார்க்கவும்",
            "hair_photo_reviews": "முடி புகைப்பட ஆய்வுகள்",
            "hair_photo_reviews_desc": "ஸ்கால்ப் புகைப்படங்களை ஆய்வு செய்து வழிகாட்டவும்",
            "consultations_section": "ஆலோசனைகள் & அட்டவணை",
            "progress_data_section": "முன்னேற்ற ஆய்வுகள் & தகவல்கள்",
            "book_consultation": "ஆலோசனை பதிவு செய்",
            "request_consultation": "ஆலோசனை கோரிக்கை செய்க",
            "select_slot_subtitle": "சான்றளிக்கப்பட்ட நிபுணர் மற்றும் விருப்பமான நேரத்தைத் தேர்ந்தெடுக்கவும்",
            "no_open_slots": "தற்போது எந்த நேரமும் கிடைக்கவில்லை",
            "no_open_slots_desc": "நிபுணர்கள் இன்னும் புதிய நேரங்களை வெளியிடவில்லை. சிறிது நேரம் கழித்து பார்க்கவும்.",
            "weekly_momentum": "வாராந்திர முன்னேற்றம்",
            "goal": "இலக்கு",
            "streak": "தொடர்ச்சி",
            "logged_target": "நாட்கள் இலக்கு எட்டப்பட்டது",
            "open_serum_calendar": "சீரம் பயன்பாட்டு காலெண்டரைத் திறக்கவும்",
            "daily_treatment_section": "தினசரி சிகிச்சை & பழக்கவழக்கங்கள்",
            "compliance": "இலக்கு",
            "serum_calendar": "சீரம் காலெண்டர்",
            "serum_calendar_desc": "டோஸ்களைப் பதிவுசெய்து நேரத்தைக் கண்காணிக்கவும்",
            "my_routines": "எனது வழக்கங்கள்",
            "my_routines_desc": "பயன்படுத்தப்படும் பொருட்கள் & பரிந்துரைக்கப்பட்ட முறைகள்",
            "visual_progress_section": "புகைப்பட முன்னேற்றம்",
            "tracking": "கண்காணிப்பு",
            "hair_progress_tracker": "முடி வளர்ச்சி கண்காணிப்பு",
            "before_and_after": "முன் & பின்",
            "growth_comparison": "வளர்ச்சி ஒப்பீடு",
            "upload_photos": "புகைப்படங்களை பதிவேற்றவும்",
            "upload_photos_desc": "முன், பக்க மற்றும் மேல் கோணங்களைப் பதிவுசெய்க",
            "my_hair_photos": "எனது முடி புகைப்படங்கள்",
            "my_hair_photos_desc": "ஆல்பங்கள் & நிபுணர் கருத்துக்களைப் பார்க்கவும்",
            "assessments_and_experts": "மதிப்பீடுகள் & நிபுணர்கள்",
            "specialist_care": "சிறப்பு பராமரிப்பு",
            "hair_growth_quiz": "முடி வளர்ச்சி வினாடி வினா",
            "hair_growth_quiz_desc": "ஸ்கால்ப் நிலை, பரம்பரை & உதிர்வை மதிப்பிடவும்",
            "quiz_reports": "வினாடி வினா அறிக்கைகள்",
            "quiz_reports_desc": "கடந்த மதிப்பீடுகள் மற்றும் மதிப்பெண்களை மதிப்பாய்வு செய்யவும்",
            "my_consultations": "எனது ஆலோசனைகள்",
            "my_consultations_desc": "உறுதிப்படுத்தப்பட்ட & நிலுவையில் உள்ள பதிவுகளைப் பார்க்கவும்",
        
            "select_portal": "உங்கள் போர்ட்டலைத் தேர்ந்தெடுக்கவும்",
            "member_user": "உறுப்பினர் / பயனர்",
            "member_portal_desc": "முடி வளர்ச்சியை கண்காணிக்கவும், சீரம் பதிவிடவும் & நிபுணர்களை அணுகவும்",
            "member_badge": "உறுப்பினர்",
            "expert_specialist": "முடி நிபுணர்",
            "expert_portal_desc": "உறுப்பினர் பதிவுகளை ஆய்வு செய்யவும் & ஆலோசனைகளை நிர்வகிக்கவும்",
            "expert_badge": "நிபுணர்",
            "tagline": "தனிப்பயனாக்கப்பட்ட தலைமுடி பராமரிப்பு & முன்னேற்றம்",
            "photo_journey": "புகைப்பட பயணம்",
            "expert_care": "நிபுணர் பராமரிப்பு",
            "daily_habits": "தினசரி பழக்கங்கள்",
            "privacy_policy": "தனியுரிமைக் கொள்கை",
            "terms_of_service": "சேவை விதிமுறைகள்",
            "about": "பற்றி",
            "welcome_back": "மீண்டும் வருக",
            "expert_portal": "நிபுணர் போர்ட்டல்",
            "user_login_subtitle": "உங்கள் பராமரிப்பைத் தொடர உள்நுழைக",
            "doctor_login_subtitle": "ஆலோசனைகளை நிர்வகிக்க உள்நுழைக",
            "email_address": "மின்னஞ்சல் முகவரி",
            "password": "கடவுச்சொல்",
            "forgot_password": "கடவுச்சொல் மறந்துவிட்டதா?",
            "log_in": "உள்நுழை",
            "dont_have_account": "கணக்கு இல்லையா?",
            "register": "பதிவு செய்க",
            "enter_email_password": "மின்னஞ்சல் மற்றும் கடவுச்சொல்லை உள்ளிடவும்",
            "create_account": "கணக்கை உருவாக்கவும்",
            "registering_as": "பதிவு செய்கிறீர்கள்:",
            "full_name": "முழு பெயர்",
            "phone_placeholder": "தொலைபேசி எண் (விருப்பத்தேர்வு)",
            "location_placeholder": "ஊர் / நகரம் (விருப்பத்தேர்வு)",
            "date_of_birth": "பிறந்த தேதி",
            "password_req_placeholder": "கடவுச்சொல் (8+ எழுத்துக்கள், எண்கள்)",
            "confirm_password": "கடவுச்சொல்லை உறுதிப்படுத்தவும்",
            "already_have_account": "ஏற்கனவே கணக்கு உள்ளதா?",
            "reset_password": "கடவுச்சொல் மீட்டமை",
            "reset_password_desc": "உங்கள் மின்னஞ்சலை சரிபார்த்து புதிய கடவுச்சொல்லை அமைக்கவும்.",
            "step1_verify_email": "படி 1: மின்னஞ்சலை சரிபார்க்கவும்",
            "verify_email_btn": "மின்னஞ்சலை சரிபார்க்கவும்",
            "step2_new_password": "படி 2: புதிய கடவுச்சொல் அமைக்கவும்",
            "new_password_placeholder": "புதிய கடவுச்சொல்லை உள்ளிடவும்",
            "update_password_btn": "கடவுச்சொல்லைப் புதுப்பிக்கவும்",
        ],
        .hindi: [
            "app_title": "हेयर जर्नी ट्रैकर",
            "welcome_title": "स्वागत है",
            "choose_language": "अपनी भाषा चुनें",
            "choose_language_desc": "अपने व्यक्तिगत बालों की देखभाल के अनुभव के लिए अपनी पसंदीदा भाषा चुनें।",
            "continue_button": "जारी रखें",
            "home": "होम",
            "profile": "प्रोफ़ाइल",
            "save_changes": "परिवर्तन सहेजें",
            "logout": "लॉग आउट",
            "delete_account": "खाता हटाएं",
            "good_morning": "शुभ प्रभात",
            "good_afternoon": "शुभ दोपहर",
            "good_evening": "शुभ संध्या",
            "verified_member": "सत्यापित सदस्य",
            "app_language": "ऐप की भाषा",
            "change": "बदलें",
            "specialization_and_languages": "विशेषज्ञता और भाषाएं",
            "language_preferences": "भाषा प्राथमिकताएं",
            "preferences": "प्राथमिकताएं",
            "clinical_specialization": "चिकित्सीय विशेषज्ञता",
            "languages_spoken": "बोली जाने वाली भाषाएं",
            "preferred_consultation_lang": "पसंदीदा परामर्श भाषा",
            "select_language": "भाषा चुनें",
            "switch_language_subtitle": "सभी स्क्रीनों के लिए अपनी पसंदीदा भाषा चुनें",
            "expert_workspace": "विशेषज्ञ कार्यक्षेत्र",
            "member_portfolios": "सदस्य पोर्टफोलियो",
            "member_portfolios_desc": "व्यापक बाल इतिहास, बहु-कोण तस्वीरें और दिनचर्या अनुपालन",
            "appointment_requests": "परामर्श अनुरोध",
            "appointment_requests_desc": "सदस्य बुकिंग अनुरोधों की समीक्षा करें और 1-ऑन-1 सत्रों की पुष्टि करें",
            "consultation_slots": "मेरे परामर्श स्लॉट",
            "consultation_slots_desc": "उपलब्ध समय और लाइव परामर्श बुकिंग प्रबंधित करें",
            "quiz_reports_feed": "प्रश्नोत्तरी रिपोर्ट फ़ीड",
            "quiz_reports_feed_desc": "13-प्रश्नों के स्वास्थ्य मूल्यांकन देखें",
            "hair_photo_reviews": "बाल फोटो समीक्षा",
            "hair_photo_reviews_desc": "सदस्य स्कैल्प फ़ोटो की जांच करें और विशेषज्ञ मार्गदर्शन दें",
            "consultations_section": "परामर्श और समय-सारणी",
            "progress_data_section": "प्रगति समीक्षा और डेटा",
            "book_consultation": "परामर्श बुक करें",
            "request_consultation": "परामर्श का अनुरोध करें",
            "select_slot_subtitle": "प्रमाणित विशेषज्ञ और पसंदीदा परामर्श स्लॉट चुनें",
            "no_open_slots": "फिलहाल कोई स्लॉट उपलब्ध नहीं है",
            "no_open_slots_desc": "विशेषज्ञों ने अभी तक नई उपलब्धता प्रकाशित नहीं की है। कृपया बाद में जांचें।",
            "weekly_momentum": "साप्ताहिक प्रगति",
            "goal": "लक्ष्य",
            "streak": "लगातार दिन",
            "logged_target": "दिनों में पूरा लक्ष्य दर्ज किया गया",
            "open_serum_calendar": "सीरम रूटीन कैलेंडर खोलें",
            "daily_treatment_section": "दैनिक उपचार और आदतें",
            "compliance": "अनुपालन",
            "serum_calendar": "सीरम कैलेंडर",
            "serum_calendar_desc": "खुराक लॉग करें और समय ट्रैक करें",
            "my_routines": "मेरी दिनचर्या",
            "my_routines_desc": "सक्रिय उत्पाद और अनुशंसित नियम",
            "visual_progress_section": "दृश्य प्रगति और तस्वीरें",
            "tracking": "ट्रैकिंग",
            "hair_progress_tracker": "बाल प्रगति ट्रैकर",
            "before_and_after": "पहले और बाद",
            "growth_comparison": "विकास तुलना",
            "upload_photos": "तस्वीरें अपलोड करें",
            "upload_photos_desc": "सामने, बगल और शीर्ष कोणों को लॉग करें",
            "my_hair_photos": "मेरे बालों की तस्वीरें",
            "my_hair_photos_desc": "एल्बम और विशेषज्ञ समीक्षा देखें",
            "assessments_and_experts": "मूल्यांकन और विशेषज्ञ",
            "specialist_care": "विशेषज्ञ देखभाल",
            "hair_growth_quiz": "बाल विकास प्रश्नोत्तरी",
            "hair_growth_quiz_desc": "स्कैल्प की स्थिति, आनुवंशिकी और बाल गिरने का आकलन करें",
            "quiz_reports": "प्रश्नोत्तरी रिपोर्ट",
            "quiz_reports_desc": "अपने पिछले मूल्यांकनों की समीक्षा करें",
            "my_consultations": "मेरे परामर्श",
            "my_consultations_desc": "स्वीकृत और लंबित बुकिंग देखें",
        
            "select_portal": "अपना पोर्टल चुनें",
            "member_user": "सदस्य / उपयोगकर्ता",
            "member_portal_desc": "बालों के बदलाव को ट्रैक करें, सीरम खुराक लॉग करें और विशेषज्ञों से परामर्श लें",
            "member_badge": "सदस्य",
            "expert_specialist": "हेयर स्पेशलिस्ट / विशेषज्ञ",
            "expert_portal_desc": "सदस्य पोर्टफोलियो की समीक्षा करें और परामर्श प्रबंधित करें",
            "expert_badge": "विशेषज्ञ",
            "tagline": "व्यक्तिगत बालों की देखभाल और प्रगति ट्रैकिंग",
            "photo_journey": "फोटो यात्रा",
            "expert_care": "विशेषज्ञ देखभाल",
            "daily_habits": "दैनिक आदतें",
            "privacy_policy": "गोपनीयता नीति",
            "terms_of_service": "सेवा की शर्तें",
            "about": "के बारे में",
            "welcome_back": "वापसी पर स्वागत है",
            "expert_portal": "विशेषज्ञ पोर्टल",
            "user_login_subtitle": "अपनी बालों की देखभाल जारी रखने के लिए साइन इन करें",
            "doctor_login_subtitle": "परामर्श प्रबंधित करने के लिए साइन इन करें",
            "email_address": "ईमेल पता",
            "password": "पासवर्ड",
            "forgot_password": "पासवर्ड भूल गए?",
            "log_in": "लॉग इन",
            "dont_have_account": "खाता नहीं है?",
            "register": "पंजीकरण करें",
            "enter_email_password": "कृपया ईमेल और पासवर्ड दोनों दर्ज करें",
            "create_account": "खाता बनाएं",
            "registering_as": "पंजीकरण प्रकार:",
            "full_name": "पूरा नाम",
            "phone_placeholder": "फ़ोन नंबर (वैकल्पिक)",
            "location_placeholder": "शहर / स्थान (वैकल्पिक)",
            "date_of_birth": "जन्म तिथि",
            "password_req_placeholder": "पासवर्ड (8+ वर्ण, संख्याएँ)",
            "confirm_password": "पासवर्ड की पुष्टि करें",
            "already_have_account": "पहले से खाता है?",
            "reset_password": "पासवर्ड रीसेट करें",
            "reset_password_desc": "अपना पंजीकृत ईमेल सत्यापित करें और एक नया सुरक्षित पासवर्ड चुनें।",
            "step1_verify_email": "चरण 1: ईमेल सत्यापित करें",
            "verify_email_btn": "ईमेल सत्यापित करें",
            "step2_new_password": "चरण 2: नया पासवर्ड सेट करें",
            "new_password_placeholder": "नया पासवर्ड दर्ज करें",
            "update_password_btn": "पासवर्ड अपडेट करें",
        ],
        .spanish: [
            "app_title": "Seguimiento Capilar",
            "welcome_title": "Bienvenido",
            "choose_language": "Elija su Idioma",
            "choose_language_desc": "Seleccione su idioma preferido para personalizar su experiencia de salud capilar.",
            "continue_button": "Continuar",
            "home": "Inicio",
            "profile": "Perfil",
            "save_changes": "Guardar Cambios",
            "logout": "Cerrar Sesión",
            "delete_account": "Eliminar Cuenta",
            "good_morning": "Buenos Días",
            "good_afternoon": "Buenas Tardes",
            "good_evening": "Buenas Noches",
            "verified_member": "Miembro Verificado",
            "app_language": "Idioma de la App",
            "change": "Cambiar",
            "specialization_and_languages": "Especialización e Idiomas",
            "language_preferences": "Preferencias de Idioma",
            "preferences": "Preferencias",
            "clinical_specialization": "Especialización Clínica",
            "languages_spoken": "Idiomas Hablados",
            "preferred_consultation_lang": "Idioma de Consulta Preferido",
            "select_language": "Seleccionar Idioma",
            "switch_language_subtitle": "Seleccione su idioma preferido para todas las pantallas",
            "expert_workspace": "ESPACIO DE EXPERTOS",
            "member_portfolios": "Portafolios de Miembros",
            "member_portfolios_desc": "Historial capilar, fotos multiángulo y adherencia a la rutina",
            "appointment_requests": "Solicitudes de Citas",
            "appointment_requests_desc": "Revisar solicitudes de miembros y confirmar sesiones 1 a 1",
            "consultation_slots": "Mis Horarios de Consulta",
            "consultation_slots_desc": "Gestionar horarios disponibles y citas en vivo",
            "quiz_reports_feed": "Informes de Cuestionarios",
            "quiz_reports_feed_desc": "Ver evaluaciones de escala de 13 preguntas",
            "hair_photo_reviews": "Revisiones de Fotos Capilares",
            "hair_photo_reviews_desc": "Examinar fotos de cuero cabelludo y brindar orientación",
            "consultations_section": "Consultas y Horarios",
            "progress_data_section": "Revisiones y Datos",
            "book_consultation": "Reservar Consulta",
            "request_consultation": "Solicitar Consulta",
            "select_slot_subtitle": "Seleccione un especialista certificado y el horario deseado",
            "no_open_slots": "No Hay Horarios Disponibles",
            "no_open_slots_desc": "Los especialistas no han publicado nuevos horarios aún. Por favor consulte más tarde.",
            "weekly_momentum": "Impulso Semanal",
            "goal": "OBJETIVO",
            "streak": "Racha",
            "logged_target": "de 7 días completados",
            "open_serum_calendar": "Abrir Calendario de Suero",
            "daily_treatment_section": "Tratamiento Diario y Hábitos",
            "compliance": "Cumplimiento",
            "serum_calendar": "Calendario de Suero",
            "serum_calendar_desc": "Registrar dosis y monitorear constancia",
            "my_routines": "Mis Rutinas",
            "my_routines_desc": "Productos activos y regímenes recomendados",
            "visual_progress_section": "Progreso Visual y Fotos",
            "tracking": "Seguimiento",
            "hair_progress_tracker": "Seguimiento de Progreso Capilar",
            "before_and_after": "ANTES Y DESPUÉS",
            "growth_comparison": "Comparación de crecimiento",
            "upload_photos": "Subir Fotos",
            "upload_photos_desc": "Registrar ángulos frontal, lateral y coronilla",
            "my_hair_photos": "Mis Fotos Capilares",
            "my_hair_photos_desc": "Ver álbumes y observaciones de expertos",
            "assessments_and_experts": "Evaluaciones y Especialistas",
            "specialist_care": "Atención Experta",
            "hair_growth_quiz": "Cuestionario Capilar",
            "hair_growth_quiz_desc": "Evaluar salud del cuero cabelludo y genética",
            "quiz_reports": "Informes de Cuestionario",
            "quiz_reports_desc": "Revisar diagnósticos pasados",
            "my_consultations": "Mis Consultas",
            "my_consultations_desc": "Ver citas aprobadas y pendientes",
        
            "select_portal": "SELECCIONE SU PORTAL",
            "member_user": "Miembro / Usuario",
            "member_portal_desc": "Siga la transformación capilar, registre suero y consulte expertos",
            "member_badge": "MIEMBRO",
            "expert_specialist": "Especialista Capilar / Experto",
            "expert_portal_desc": "Revise portafolios de miembros y gestione consultas",
            "expert_badge": "EXPERTO",
            "tagline": "Cuidado Capilar Personalizado y Seguimiento",
            "photo_journey": "Viaje Fotográfico",
            "expert_care": "Atención Experta",
            "daily_habits": "Hábitos Diarios",
            "privacy_policy": "Política de Privacidad",
            "terms_of_service": "Términos del Servicio",
            "about": "Acerca de",
            "welcome_back": "Bienvenido de Nuevo",
            "expert_portal": "Portal de Expertos",
            "user_login_subtitle": "Inicie sesión para continuar su cuidado capilar",
            "doctor_login_subtitle": "Inicie sesión para gestionar consultas",
            "email_address": "Correo Electrónico",
            "password": "Contraseña",
            "forgot_password": "¿Olvidó su contraseña?",
            "log_in": "Iniciar Sesión",
            "dont_have_account": "¿No tiene una cuenta?",
            "register": "Registrarse",
            "enter_email_password": "Por favor ingrese correo y contraseña",
            "create_account": "Crear Cuenta",
            "registering_as": "Registrándose como:",
            "full_name": "Nombre Completo",
            "phone_placeholder": "Teléfono (Opcional)",
            "location_placeholder": "Ciudad / Ubicación (Opcional)",
            "date_of_birth": "Fecha de Nacimiento",
            "password_req_placeholder": "Contraseña (8+ caracteres)",
            "confirm_password": "Confirmar Contraseña",
            "already_have_account": "¿Ya tiene una cuenta?",
            "reset_password": "Restablecer Contraseña",
            "reset_password_desc": "Verifique su correo registrado y elija una nueva contraseña.",
            "step1_verify_email": "Paso 1: Verificar Correo",
            "verify_email_btn": "Verificar Correo",
            "step2_new_password": "Paso 2: Nueva Contraseña",
            "new_password_placeholder": "Ingrese Nueva Contraseña",
            "update_password_btn": "Actualizar Contraseña",
        ],
        .french: [
            "app_title": "Suivi Capillaire",
            "welcome_title": "Bienvenue",
            "choose_language": "Choisissez Votre Langue",
            "choose_language_desc": "Sélectionnez votre langue pour personnaliser votre expérience capillaire.",
            "continue_button": "Continuer",
            "home": "Accueil",
            "profile": "Profil",
            "save_changes": "Enregistrer",
            "logout": "Déconnexion",
            "delete_account": "Supprimer le Compte",
            "good_morning": "Bonjour",
            "good_afternoon": "Bon après-midi",
            "good_evening": "Bonsoir",
            "verified_member": "Membre Vérifié",
            "app_language": "Langue de l'Application",
            "change": "Modifier",
            "specialization_and_languages": "Spécialisation & Langues",
            "language_preferences": "Préférences Linguistiques",
            "preferences": "Préférences",
            "clinical_specialization": "Spécialisation Clinique",
            "languages_spoken": "Langues Parlées",
            "preferred_consultation_lang": "Langue de Consultation Préférée",
            "select_language": "Choisir la Langue",
            "switch_language_subtitle": "Choisissez votre langue préférée pour l'application",
            "expert_workspace": "ESPACE EXPERT",
            "member_portfolios": "Portefeuilles Membres",
            "member_portfolios_desc": "Historique capillaire, photos sous plusieurs angles et routine",
            "appointment_requests": "Demandes de Rendez-vous",
            "appointment_requests_desc": "Examiner les demandes des membres et confirmer les séances",
            "consultation_slots": "Mes Créneaux de Consultation",
            "consultation_slots_desc": "Gérer les disponibilités et les consultations en direct",
            "quiz_reports_feed": "Rapports des Évaluations",
            "quiz_reports_feed_desc": "Consulter les évaluations en 13 questions",
            "hair_photo_reviews": "Examens des Photos Capillaires",
            "hair_photo_reviews_desc": "Examiner le cuir chevelu et donner des conseils",
            "consultations_section": "Consultations & Planning",
            "progress_data_section": "Examens & Données",
            "book_consultation": "Réserver une Consultation",
            "request_consultation": "Demander une Consultation",
            "select_slot_subtitle": "Choisissez un spécialiste certifié et votre créneau souhaité",
            "no_open_slots": "Aucun Créneau Disponible",
            "no_open_slots_desc": "Les spécialistes n'ont pas encore publié de nouvelles disponibilités.",
            "weekly_momentum": "Dynamique Hebdomadaire",
            "goal": "OBJECTIF",
            "streak": "Série",
            "logged_target": "sur 7 jours respectés",
            "open_serum_calendar": "Ouvrir le Calendrier de Sérum",
            "daily_treatment_section": "Traitement Quotidien & Habitudes",
            "compliance": "Assiduité",
            "serum_calendar": "Calendrier de Sérum",
            "serum_calendar_desc": "Noter les doses et suivre la conformité",
            "my_routines": "Mes Routines",
            "my_routines_desc": "Produits actifs & régimes prescrits",
            "visual_progress_section": "Progression Visuelle & Photos",
            "tracking": "Suivi",
            "hair_progress_tracker": "Suivi du Progrès Capillaire",
            "before_and_after": "AVANT & APRÈS",
            "growth_comparison": "Comparaison de repousse",
            "upload_photos": "Télécharger Photos",
            "upload_photos_desc": "Photos angles frontal, latéral et sommet",
            "my_hair_photos": "Mes Photos Capillaires",
            "my_hair_photos_desc": "Voir les albums & retours experts",
            "assessments_and_experts": "Évaluations & Spécialistes",
            "specialist_care": "Soins Experts",
            "hair_growth_quiz": "Quiz Santé Capillaire",
            "hair_growth_quiz_desc": "Évaluer le cuir chevelu et les facteurs de chute",
            "quiz_reports": "Rapports d'Évaluation",
            "quiz_reports_desc": "Consulter vos résultats passés",
            "my_consultations": "Mes Consultations",
            "my_consultations_desc": "Voir les rendez-vous confirmés et en attente",
        
            "select_portal": "SÉLECTIONNEZ VOTRE PORTAIL",
            "member_user": "Membre / Utilisateur",
            "member_portal_desc": "Suivez la repousse, enregistrez le sérum et consultez des experts",
            "member_badge": "MEMBRE",
            "expert_specialist": "Spécialiste Capillaire / Expert",
            "expert_portal_desc": "Examinez les dossiers membres et gérez les rendez-vous",
            "expert_badge": "EXPERT",
            "tagline": "Soins Capillaires Personnalisés & Suivi",
            "photo_journey": "Parcours Photos",
            "expert_care": "Soins Experts",
            "daily_habits": "Habitudes Quotidiennes",
            "privacy_policy": "Politique de Confidentialité",
            "terms_of_service": "Conditions d'Utilisation",
            "about": "À Propos",
            "welcome_back": "Bon Retour",
            "expert_portal": "Portail Expert",
            "user_login_subtitle": "Connectez-vous pour continuer votre parcours",
            "doctor_login_subtitle": "Connectez-vous pour gérer les consultations",
            "email_address": "Adresse E-mail",
            "password": "Mot de Passe",
            "forgot_password": "Mot de passe oublié ?",
            "log_in": "Se Connecter",
            "dont_have_account": "Pas encore de compte ?",
            "register": "S'inscrire",
            "enter_email_password": "Veuillez entrer votre e-mail et mot de passe",
            "create_account": "Créer un Compte",
            "registering_as": "Inscription en tant que :",
            "full_name": "Nom Complet",
            "phone_placeholder": "Téléphone (Optionnel)",
            "location_placeholder": "Ville / Lieu (Optionnel)",
            "date_of_birth": "Date de Naissance",
            "password_req_placeholder": "Mot de passe (8+ caractères)",
            "confirm_password": "Confirmer le Mot de Passe",
            "already_have_account": "Déjà un compte ?",
            "reset_password": "Réinitialiser le Mot de Passe",
            "reset_password_desc": "Vérifiez votre e-mail et choisissez un nouveau mot de passe.",
            "step1_verify_email": "Étape 1 : Vérifier l'e-mail",
            "verify_email_btn": "Vérifier l'E-mail",
            "step2_new_password": "Étape 2 : Nouveau Mot de Passe",
            "new_password_placeholder": "Entrez le Nouveau Mot de Passe",
            "update_password_btn": "Mettre à Jour le Mot de Passe",
        ],
        .german: [
            "app_title": "Haar-Tracking App",
            "welcome_title": "Willkommen",
            "choose_language": "Wählen Sie Ihre Sprache",
            "choose_language_desc": "Wählen Sie Ihre bevorzugte Sprache für Ihre persönliche Haarpflege.",
            "continue_button": "Fortfahren",
            "home": "Startseite",
            "profile": "Profil",
            "save_changes": "Änderungen Speichern",
            "logout": "Abmelden",
            "delete_account": "Konto Löschen",
            "good_morning": "Guten Morgen",
            "good_afternoon": "Guten Tag",
            "good_evening": "Guten Abend",
            "verified_member": "Verifiziertes Mitglied",
            "app_language": "App-Sprache",
            "change": "Ändern",
            "specialization_and_languages": "Spezialisierung & Sprachen",
            "language_preferences": "Spracheinstellungen",
            "preferences": "Einstellungen",
            "clinical_specialization": "Klinische Spezialisierung",
            "languages_spoken": "Gesprochene Sprachen",
            "preferred_consultation_lang": "Bevorzugte Beratungssprache",
            "select_language": "Sprache Auswählen",
            "switch_language_subtitle": "Wählen Sie Ihre bevorzugte App-Sprache",
            "expert_workspace": "EXPERTENBEREICH",
            "member_portfolios": "Mitglieder-Portfolios",
            "member_portfolios_desc": "Umfassende Haargeschichte, Multi-Winkel-Fotos & Routine",
            "appointment_requests": "Terminanfragen",
            "appointment_requests_desc": "Buchungen prüfen und persönliche Beratungen bestätigen",
            "consultation_slots": "Meine Beratungszeiten",
            "consultation_slots_desc": "Verfügbarkeiten und Live-Termine verwalten",
            "quiz_reports_feed": "Fragebogen-Feed",
            "quiz_reports_feed_desc": "13-Punkte-Skalierungsbewertungen ansehen",
            "hair_photo_reviews": "Haarfoto-Bewertungen",
            "hair_photo_reviews_desc": "Kopfhautfotos prüfen und Empfehlungen geben",
            "consultations_section": "Beratungen & Termine",
            "progress_data_section": "Fortschritt & Daten",
            "book_consultation": "Beratung Buchen",
            "request_consultation": "Beratung Anfragen",
            "select_slot_subtitle": "Wählen Sie einen zertifizierten Experten und Ihren Wunschtermin",
            "no_open_slots": "Zurzeit Keine Freien Termine",
            "no_open_slots_desc": "Haarexperten haben noch keine neuen Zeiten veröffentlicht. Bitte später erneut prüfen.",
            "weekly_momentum": "Wöchentlicher Fortschritt",
            "goal": "ZIEL",
            "streak": "Serie",
            "logged_target": "von 7 Tagen mit vollem Ziel erreicht",
            "open_serum_calendar": "Serum-Routine-Kalender Öffnen",
            "daily_treatment_section": "Tägliche Behandlung & Gewohnheiten",
            "compliance": "Einhaltung",
            "serum_calendar": "Serum-Kalender",
            "serum_calendar_desc": "Dosen erfassen & Routine einhalten",
            "my_routines": "Meine Routinen",
            "my_routines_desc": "Aktive Pflegeprodukte & Empfehlungen",
            "visual_progress_section": "Visueller Fortschritt & Fotos",
            "tracking": "Fortschritt",
            "hair_progress_tracker": "Haarfortschritts-Tracker",
            "before_and_after": "VORHER & NACHHER",
            "growth_comparison": "Direkter Wachstumsvergleich",
            "upload_photos": "Fotos Hochladen",
            "upload_photos_desc": "Front-, Seiten- und Scheitelansicht erfassen",
            "my_hair_photos": "Meine Haarfotos",
            "my_hair_photos_desc": "Alben und Feedback der Experten einsehen",
            "assessments_and_experts": "Analysen & Experten",
            "specialist_care": "Fachberatung",
            "hair_growth_quiz": "Haarwachstums-Quiz",
            "hair_growth_quiz_desc": "Kopfhautzustand und Haarverlust bewerten",
            "quiz_reports": "Quiz-Berichte",
            "quiz_reports_desc": "Frühere Auswertungen & Scores prüfen",
            "my_consultations": "Meine Termine",
            "my_consultations_desc": "Bestätigte und ausstehende Termine einsehen",
        
            "select_portal": "WÄHLEN SIE IHR PORTAL",
            "member_user": "Mitglied / Benutzer",
            "member_portal_desc": "Haarfortschritt verfolgen, Serum dosieren & Experten konsultieren",
            "member_badge": "MITGLIED",
            "expert_specialist": "Haarexperte / Facharzt",
            "expert_portal_desc": "Mitgliederakten prüfen und Termine verwalten",
            "expert_badge": "EXPERTE",
            "tagline": "Personalisierte Haarpflege & Fortschritt",
            "photo_journey": "Fotoreise",
            "expert_care": "Expertenpflege",
            "daily_habits": "Tägliche Routine",
            "privacy_policy": "Datenschutzerklärung",
            "terms_of_service": "Nutzungsbedingungen",
            "about": "Über uns",
            "welcome_back": "Willkommen Zurück",
            "expert_portal": "Expertenportal",
            "user_login_subtitle": "Melden Sie sich an, um fortzufahren",
            "doctor_login_subtitle": "Melden Sie sich an, um Termine zu verwalten",
            "email_address": "E-Mail-Adresse",
            "password": "Passwort",
            "forgot_password": "Passwort vergessen?",
            "log_in": "Anmelden",
            "dont_have_account": "Noch kein Konto?",
            "register": "Registrieren",
            "enter_email_password": "Bitte E-Mail und Passwort eingeben",
            "create_account": "Konto Erstellen",
            "registering_as": "Registrieren als:",
            "full_name": "Vollständiger Name",
            "phone_placeholder": "Telefon (Optional)",
            "location_placeholder": "Stadt / Ort (Optional)",
            "date_of_birth": "Geburtsdatum",
            "password_req_placeholder": "Passwort (8+ Zeichen)",
            "confirm_password": "Passwort Bestätigen",
            "already_have_account": "Bereits ein Konto?",
            "reset_password": "Passwort Zurücksetzen",
            "reset_password_desc": "E-Mail bestätigen und neues Passwort wählen.",
            "step1_verify_email": "Schritt 1: E-Mail Bestätigen",
            "verify_email_btn": "E-Mail Prüfen",
            "step2_new_password": "Schritt 2: Neues Passwort",
            "new_password_placeholder": "Neues Passwort Eingeben",
            "update_password_btn": "Passwort Speichern",
        ],
        .arabic: [
            "app_title": "متتبع رحلة الشعر",
            "welcome_title": "مرحباً بك",
            "choose_language": "اختر لغتك المفضلة",
            "choose_language_desc": "حدد لغتك لتخصيص تجربتك الكاملة لصحة الشعر.",
            "continue_button": "متابعة",
            "home": "الرئيسية",
            "profile": "الملف الشخصي",
            "save_changes": "حفظ التغييرات",
            "logout": "تسجيل الخروج",
            "delete_account": "حذف الحساب",
            "good_morning": "صباح الخير",
            "good_afternoon": "مساء الخير",
            "good_evening": "مساء الخير",
            "verified_member": "عضو موثق",
            "app_language": "لغة التطبيق",
            "change": "تغيير",
            "specialization_and_languages": "التخصص واللغات",
            "language_preferences": "تفضيلات اللغة",
            "preferences": "التفضيلات",
            "clinical_specialization": "التخصص السريري",
            "languages_spoken": "اللغات المحكية",
            "preferred_consultation_lang": "لغة الاستشارة المفضلة",
            "select_language": "اختر اللغة",
            "switch_language_subtitle": "اختر لغتك المفضلة للتطبيق",
            "expert_workspace": "مساحة الخبراء",
            "member_portfolios": "ملفات الأعضاء",
            "member_portfolios_desc": "تاريخ الشعر الكامل والصور متعددة الزوايا والروتين",
            "appointment_requests": "طلبات الاستشارة",
            "appointment_requests_desc": "مراجعة طلبات الحجز وتأكيد الجلسات الفردية",
            "consultation_slots": "أوقات استشاراتي",
            "consultation_slots_desc": "إدارة الأوقات المتاحة وحجوزات الاستشارات",
            "quiz_reports_feed": "تقارير الاستبيان",
            "quiz_reports_feed_desc": "عرض تقييمات الصحة المكونة من 13 سؤالاً",
            "hair_photo_reviews": "مراجعات صور الشعر",
            "hair_photo_reviews_desc": "فحص صور فروة الرأس وتقديم الإرشادات",
            "consultations_section": "الاستشارات والجدول",
            "progress_data_section": "المراجعات والبيانات",
            "book_consultation": "حجز استشارة",
            "request_consultation": "طلب استشارة",
            "select_slot_subtitle": "اختر خبيراً معتمداً والموعد المناسب لك",
            "no_open_slots": "لا توجد مواعيد متاحة حالياً",
            "no_open_slots_desc": "لم يقم الخبراء بنشر مواعيد جديدة بعد. يُرجى التحقق لاحقاً.",
            "weekly_momentum": "التقدم الأسبوعي",
            "goal": "الهدف",
            "streak": "التتابع",
            "logged_target": "من 7 أيام مكتملة",
            "open_serum_calendar": "فتح تقويم روتين السيروم",
            "daily_treatment_section": "العلاج اليومي والعادات",
            "compliance": "الالتزام",
            "serum_calendar": "تقويم السيروم",
            "serum_calendar_desc": "تسجيل الجرعات وتتبع الالتزام",
            "my_routines": "روتيناتي",
            "my_routines_desc": "المنتجات النشطة والأنظمة الموصى بها",
            "visual_progress_section": "التقدم البصري والصور",
            "tracking": "المتابعة",
            "hair_progress_tracker": "متتبع تقدم الشعر",
            "before_and_after": "قبل وبعد",
            "growth_comparison": "مقارنة نمو الشعر جنباً إلى جنب",
            "upload_photos": "رفع الصور",
            "upload_photos_desc": "تسجيل زوايا الأمام والجوانب والأعلى",
            "my_hair_photos": "صور شعري",
            "my_hair_photos_desc": "عرض الألبومات وملاحظات الخبراء",
            "assessments_and_experts": "التقييمات والخبراء",
            "specialist_care": "رعاية متخصصة",
            "hair_growth_quiz": "اختبار نمو الشعر",
            "hair_growth_quiz_desc": "تقييم حالة الفروة والوراثة وتساقط الشعر",
            "quiz_reports": "تقارير الاختبارات",
            "quiz_reports_desc": "مراجعة التشخيصات والنتائج السابقة",
            "my_consultations": "استشاراتي",
            "my_consultations_desc": "متابعة المواعيد المؤكدة والمعلقة",
        
            "select_portal": "اختر بوابتك",
            "member_user": "عضو / مستخدم",
            "member_portal_desc": "تتبع نمو الشعر وسجل السيروم واستشر الخبراء",
            "member_badge": "عضو",
            "expert_specialist": "أخصائي الشعر / خبير",
            "expert_portal_desc": "مراجعة ملفات الأعضاء وإدارة الاستشارات",
            "expert_badge": "خبير",
            "tagline": "العناية بالشعر المخصصة وتتبع التقدم",
            "photo_journey": "رحلة الصور",
            "expert_care": "رعاية الخبراء",
            "daily_habits": "عادات يومية",
            "privacy_policy": "سياسة الخصوصية",
            "terms_of_service": "شروط الخدمة",
            "about": "حول التطبيق",
            "welcome_back": "مرحباً بعودتك",
            "expert_portal": "بوابة الخبراء",
            "user_login_subtitle": "سجل الدخول لمتابعة رحلة شعرك",
            "doctor_login_subtitle": "سجل الدخول لإدارة الاستشارات",
            "email_address": "البريد الإلكتروني",
            "password": "كلمة المرور",
            "forgot_password": "هل نسيت كلمة المرور؟",
            "log_in": "تسجيل الدخول",
            "dont_have_account": "ليس لديك حساب؟",
            "register": "إنشاء حساب",
            "enter_email_password": "يرجى إدخال البريد الإلكتروني وكلمة المرور",
            "create_account": "إنشاء حساب جديد",
            "registering_as": "التسجيل كـ:",
            "full_name": "الاسم الكامل",
            "phone_placeholder": "رقم الهاتف (اختياري)",
            "location_placeholder": "المدينة / الموقع (اختياري)",
            "date_of_birth": "تاريخ الميلاد",
            "password_req_placeholder": "كلمة المرور (8+ أحرف وأرقام)",
            "confirm_password": "تأكيد كلمة المرور",
            "already_have_account": "هل لديك حساب بالفعل؟",
            "reset_password": "إعادة تعيين كلمة المرور",
            "reset_password_desc": "تحقق من بريدك المسجل واختر كلمة مرور جديدة آمنة.",
            "step1_verify_email": "الخطوة 1: التحقق من البريد",
            "verify_email_btn": "التحقق من البريد",
            "step2_new_password": "الخطوة 2: كلمة مرور جديدة",
            "new_password_placeholder": "أدخل كلمة المرور الجديدة",
            "update_password_btn": "تحديث كلمة المرور",
        ],
        .italian: [
            "app_title": "Hair Journey Tracker",
            "welcome_title": "Benvenuto",
            "choose_language": "Scegli la Tua Lingua",
            "choose_language_desc": "Seleziona la tua lingua preferita per personalizzare l'esperienza di cura dei capelli.",
            "continue_button": "Continua",
            "home": "Home",
            "profile": "Profilo",
            "save_changes": "Salva Modifiche",
            "logout": "Disconnetti",
            "delete_account": "Elimina Account",
            "good_morning": "Buongiorno",
            "good_afternoon": "Buon pomeriggio",
            "good_evening": "Buonasera",
            "verified_member": "Membro Verificato",
            "app_language": "Lingua dell'App",
            "change": "Modifica",
            "specialization_and_languages": "Specializzazione & Lingue",
            "language_preferences": "Preferenze di Lingua",
            "preferences": "Preferenze",
            "clinical_specialization": "Specializzazione Clinica",
            "languages_spoken": "Lingue Parlate",
            "preferred_consultation_lang": "Lingua di Consulto Preferita",
            "select_language": "Seleziona Lingua",
            "switch_language_subtitle": "Seleziona la tua lingua preferita per tutte le schermate",
            "expert_workspace": "AREA ESPERTI",
            "member_portfolios": "Portafogli Membri",
            "member_portfolios_desc": "Storia dei capelli, foto multi-angolazione e aderenza alla routine",
            "appointment_requests": "Richieste di Consulto",
            "appointment_requests_desc": "Revisiona le prenotazioni e conferma le sessioni individuali",
            "consultation_slots": "I Miei Orari di Consulto",
            "consultation_slots_desc": "Gestisci le disponibilità e le consulenze dal vivo",
            "quiz_reports_feed": "Feed Valutazioni Quiz",
            "quiz_reports_feed_desc": "Visualizza i questionari diagnostici a 13 domande",
            "hair_photo_reviews": "Revisioni Foto Capelli",
            "hair_photo_reviews_desc": "Esamina il cuoio capelluto e fornisci consulenza",
            "consultations_section": "Consulti e Pianificazione",
            "progress_data_section": "Revisioni e Dati",
            "book_consultation": "Prenota Consulto",
            "request_consultation": "Richiedi Consulto",
            "select_slot_subtitle": "Seleziona uno specialista certificato e il tuo orario preferito",
            "no_open_slots": "Nessun Orario Disponibile al Momento",
            "no_open_slots_desc": "Gli specialisti non hanno ancora pubblicato nuove disponibilità. Ricontrolla più tardi.",
            "weekly_momentum": "Progresso Settimanale",
            "goal": "OBIETTIVO",
            "streak": "Serie",
            "logged_target": "giorni su 7 completati",
            "open_serum_calendar": "Apri Calendario Routine Siero",
            "daily_treatment_section": "Trattamento Quotidiano & Abitudini",
            "compliance": "Conformità",
            "serum_calendar": "Calendario Siero",
            "serum_calendar_desc": "Registra le dosi e mantieni la costanza",
            "my_routines": "Le Mie Routine",
            "my_routines_desc": "Prodotti attivi e regimi prescritti",
            "visual_progress_section": "Progresso Visivo & Foto",
            "tracking": "Tracciamento",
            "hair_progress_tracker": "Tracciatore Progresso Capelli",
            "before_and_after": "PRIMA & DOPO",
            "growth_comparison": "Confronto visivo della crescita",
            "upload_photos": "Carica Foto",
            "upload_photos_desc": "Registra angoli frontale, laterale e vertice",
            "my_hair_photos": "Le Mie Foto Capelli",
            "my_hair_photos_desc": "Visualizza album e commenti degli esperti",
            "assessments_and_experts": "Valutazioni ed Esperti",
            "specialist_care": "Cura Specialistica",
            "hair_growth_quiz": "Quiz Salute Capillare",
            "hair_growth_quiz_desc": "Valuta il cuoio capelluto e i fattori di caduta",
            "quiz_reports": "Report Quiz",
            "quiz_reports_desc": "Esamina i test diagnostici precedenti",
            "my_consultations": "I Miei Consulti",
            "my_consultations_desc": "Visualizza prenotazioni approvate e in attesa",
            "select_portal": "SELEZIONA IL TUO PORTALE",
            "member_user": "Membro / Utente",
            "member_portal_desc": "Traccia la crescita, registra il siero e consulta gli specialisti",
            "member_badge": "MEMBRO",
            "expert_specialist": "Specialista Capelli / Esperto",
            "expert_portal_desc": "Esamina i profili dei membri e gestisci le consulenze",
            "expert_badge": "ESPERTO",
            "tagline": "Cura dei Capelli Personalizzata e Monitoraggio",
            "photo_journey": "Diario Fotografico",
            "expert_care": "Cura Specialistica",
            "daily_habits": "Abitudini Quotidiane",
            "privacy_policy": "Informativa sulla Privacy",
            "terms_of_service": "Termini di Servizio",
            "about": "Informazioni",
            "welcome_back": "Bentornato",
            "expert_portal": "Portale Esperti",
            "user_login_subtitle": "Accedi per continuare il tuo percorso",
            "doctor_login_subtitle": "Accedi per gestire le consulenze",
            "email_address": "Indirizzo Email",
            "password": "Password",
            "forgot_password": "Password dimenticata?",
            "log_in": "Accedi",
            "dont_have_account": "Non hai un account?",
            "register": "Registrati",
            "enter_email_password": "Per favore inserisci email e password",
            "create_account": "Crea Account",
            "registering_as": "Registrazione come:",
            "full_name": "Nome Completo",
            "phone_placeholder": "Telefono (Opzionale)",
            "location_placeholder": "Città / Località (Opzionale)",
            "date_of_birth": "Data di Nascita",
            "password_req_placeholder": "Password (8+ caratteri)",
            "confirm_password": "Conferma Password",
            "already_have_account": "Hai già un account?",
            "reset_password": "Reimposta Password",
            "reset_password_desc": "Verifica la tua email e scegli una nuova password sicura.",
            "step1_verify_email": "Passaggio 1: Verifica Email",
            "verify_email_btn": "Verifica Email",
            "step2_new_password": "Passaggio 2: Nuova Password",
            "new_password_placeholder": "Inserisci Nuova Password",
            "update_password_btn": "Aggiorna Password"
        ]
    ]
}

// Global convenience helper
func localized(_ key: String) -> String {
    AppLanguageManager.shared.text(key)
}

// MARK: - Expert Specialization Manager
final class ExpertSpecializationManager: ObservableObject {
    static let shared = ExpertSpecializationManager()
    
    // Curated list of hair & scalp clinical specializations
    static let availableSpecializations = [
        "Trichology & Scalp Health",
        "Hair Follicle Restoration & Regrowth",
        "Clinical Scalp Therapy & Scaling",
        "Androgenetic Alopecia & Density Care",
        "Holistic Hair Nutrition & Care",
        "Post-Transplant & Routine Maintenance"
    ]
    
    // Curated list of consultation languages
    static let consultationLanguages = [
        "English", "Spanish", "French", "German",
        "Hindi", "Tamil", "Telugu", "Arabic", "Italian"
    ]
    
    func getSpecialization(for userId: String) -> String {
        UserDefaults.standard.string(forKey: "expert_spec_\(userId)") ?? "Trichology & Scalp Health"
    }
    
    func setSpecialization(for userId: String, specialization: String) {
        UserDefaults.standard.set(specialization, forKey: "expert_spec_\(userId)")
        objectWillChange.send()
    }
    
    func getLanguages(for userId: String) -> [String] {
        UserDefaults.standard.stringArray(forKey: "expert_lang_\(userId)") ?? ["English"]
    }
    
    func setLanguages(for userId: String, languages: [String]) {
        UserDefaults.standard.set(languages, forKey: "expert_lang_\(userId)")
        objectWillChange.send()
    }
    
    // For members: their preferred consultation language
    func getMemberPreferredLanguage(for userId: String) -> String {
        UserDefaults.standard.string(forKey: "member_pref_lang_\(userId)") ?? "English"
    }
    
    func setMemberPreferredLanguage(for userId: String, language: String) {
        UserDefaults.standard.set(language, forKey: "member_pref_lang_\(userId)")
        objectWillChange.send()
    }
}

// MARK: - App Launch Language Selection Screen (Shown upon opening app)
struct AppLaunchLanguageView: View {
    @ObservedObject private var langManager = AppLanguageManager.shared
    var onContinue: () -> Void
    
    @State private var animate = false
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [AppTheme.emeraldMint.opacity(0.2), AppTheme.primaryBrand.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 54, height: 54)
                            
                            Image(systemName: "globe.americas.fill")
                                .font(.system(size: 26, weight: .semibold))
                                .foregroundColor(AppTheme.primaryBrand)
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(langManager.text("choose_language"))
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.titleText)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            
                            Text(langManager.text("choose_language_desc"))
                                .font(.subheadline)
                                .foregroundColor(AppTheme.bodyText(0.75))
                                .lineLimit(2)
                                .minimumScaleFactor(0.85)
                                .multilineTextAlignment(.leading)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 8)
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : -15)
                .animation(.easeOut(duration: 0.5), value: animate)
                
                // Languages List
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(AppLanguage.allCases) { lang in
                            let isSelected = langManager.currentLanguage == lang
                            
                            Button(action: {
                                langManager.setLanguage(lang)
                            }) {
                                GlassCard(cornerRadius: 18, paddingAmount: 14) {
                                    HStack(spacing: 14) {
                                        Text(lang.flag)
                                            .font(.system(size: 28))
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(lang.nativeName)
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(AppTheme.titleText)
                                            
                                            Text(lang.displayName)
                                                .font(.caption)
                                                .foregroundColor(AppTheme.bodyText(0.7))
                                        }
                                        
                                        Spacer()
                                        
                                        if isSelected {
                                            HStack(spacing: 4) {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.system(size: 20, weight: .bold))
                                                    .foregroundColor(AppTheme.emeraldMint)
                                            }
                                        } else {
                                            Text(lang.shortCode)
                                                .font(.system(size: 11, weight: .heavy, design: .monospaced))
                                                .foregroundColor(AppTheme.bodyText(0.4))
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.black.opacity(0.04))
                                                .clipShape(Capsule())
                                        }
                                    }
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(isSelected ? AppTheme.emeraldMint : Color.clear, lineWidth: 2)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 16)
                }
                
                // Bottom Continue Action
                VStack(spacing: 8) {
                    Button(action: onContinue) {
                        HStack(spacing: 8) {
                            Text(langManager.text("continue_button"))
                                .font(.headline.weight(.bold))
                            
                            Text("• \(langManager.currentLanguage.nativeName)")
                                .font(.subheadline.weight(.medium))
                                .opacity(0.9)
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .bold))
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(height: 52))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
                .background(
                    LinearGradient(
                        colors: [Color.white.opacity(0.0), Color.white.opacity(0.95), Color.white],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

// MARK: - Language Picker Modal Sheet (Used in Profile)
struct LanguagePickerSheet: View {
    @ObservedObject private var langManager = AppLanguageManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            
            VStack(spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "globe.americas.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(AppTheme.primaryBrand)
                        Text("APP LOCALIZATION")
                            .font(.system(size: 11, weight: .heavy))
                            .tracking(1.2)
                            .foregroundColor(AppTheme.primaryBrand)
                    }
                    
                    Text(langManager.text("select_language"))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.titleText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    Text(langManager.text("switch_language_subtitle"))
                        .font(.subheadline)
                        .foregroundColor(AppTheme.bodyText(0.75))
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 24)
                
                // Languages Grid / List
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(AppLanguage.allCases) { lang in
                            let isSelected = langManager.currentLanguage == lang
                            
                            Button(action: {
                                langManager.setLanguage(lang)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                    dismiss()
                                }
                            }) {
                                GlassCard(cornerRadius: 18, paddingAmount: 14) {
                                    HStack(spacing: 14) {
                                        Text(lang.flag)
                                            .font(.system(size: 32))
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(lang.nativeName)
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(AppTheme.titleText)
                                            
                                            Text(lang.displayName)
                                                .font(.caption)
                                                .foregroundColor(AppTheme.bodyText(0.7))
                                        }
                                        
                                        Spacer()
                                        
                                        if isSelected {
                                            HStack(spacing: 4) {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.system(size: 18, weight: .bold))
                                                    .foregroundColor(AppTheme.emeraldMint)
                                            }
                                        } else {
                                            Text(lang.shortCode)
                                                .font(.system(size: 11, weight: .heavy, design: .monospaced))
                                                .foregroundColor(AppTheme.bodyText(0.4))
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.black.opacity(0.04))
                                                .clipShape(Capsule())
                                        }
                                    }
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(isSelected ? AppTheme.emeraldMint : Color.clear, lineWidth: 2)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
        }
    }
}
