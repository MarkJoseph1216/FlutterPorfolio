import '../models/project_model.dart';

abstract final class PortfolioRepository {
  static const String name = 'Mark Joseph';
  static const String nameDisplay = 'Mark\nJoseph';
  static const String role = 'Software Engineer';
  static const String title = 'Software Engineer · Content Creator';
  static const String location = 'Bulacan, PH';
  static const String since = 'Est. 2019';
  static const String experience = '7+ years';
  static const String email = 'imrkjoseph16@gmail.com';
  static const String github = 'github.com/imrkjoseph16';
  static const String linkedin = 'linkedin.com/in/imrkjoseph16';
  static const String playStore = 'Mark Joseph';

  static const String bio1 =
      "Outside of work, you’ll often find me camping under the stars, "
      "traveling to new destinations, or tinkering with personal coding projects. "
      "I also love sharing programming content on TikTok and connecting with the dev community.";

  static const String bio2 =
      "I approach development with a strong emphasis on clarity and structure, "
      "writing code that remains easy to understand and evolve over time. "
      "I value thoughtful testing, consistency, and building systems that scale without becoming difficult to maintain.";

  static const String heroBio =
      'I primarily build high performance Android apps using Kotlin and Jetpack Compose,'
      ' while also creating cross-platform experiences with Flutter. '
      'I focus on clean architecture, smooth micro-interactions, '
      'and products people genuinely enjoy using.';

  static const List<String> haiku = [
    'I’m a Computer Engineer focused on Android and iOS development, with experience in both academic projects and corporate work. I enjoy turning ideas into apps that feel effortless, making software that’s functional, efficient, maintainable, and fun to use.',
  ];

  static const List<({String value, String label})> stats = [
    (value: '7+', label: 'Years'),
    (value: '12+', label: 'Apps'),
    (value: '50K+', label: 'Downloads'),
    (value: '100%', label: 'Kotlin/Dart'),
  ];

  static const List<({String label, String value})> details = [
    (label: 'Based in:', value: 'Bulacan, Philippines'),
    (label: 'Education:', value: 'BS Computer Engineering'),
    (label: 'Languages:', value: 'Kotlin · Java · Dart'),
    (label: 'Focus:', value: 'Android · Flutter · Web'),
    (label: 'Available:', value: 'Freelance & Full-time'),
  ];

  static const List<ProjectModel> projects = [
    ProjectModel(
      index: '01',
      title: 'UnionBank of the Philippines',
      year: '2026',
      role: 'Software Engineer',
      description:
          'Developed and maintained a production-grade Android mobile banking '
          'application supporting real-time fund transfers and digital banking features.',
      techStack: ['Kotlin', 'Jetpack Compose', 'Room', 'Retrofit'],
      playStoreUrl:
          'https://play.google.com/store/apps/details?id=com.unionbankph.corporate&hl=en',
    ),
    ProjectModel(
      index: '02',
      title: 'Invisible Hand Inc.',
      year: '2021',
      role: 'Android Developer',
      description:
          'Developed an betting application for cock fighting Local/International and integrated with GCash payment, '
          'you can also watch live streaming cock fighting and withdraw and deposit to your account.',
      techStack: ['Java', 'Kotlin', 'Agora', 'Payment', 'AWS'],
    ),
    ProjectModel(
      index: '03',
      title: 'Byltax Systems Inc.',
      year: '2020',
      role: 'Mobile Developer',
      description:
          'Built and maintained a mobile application for Sweden\'s leading '
          'association of Authorized Accountants and Payroll consultants, '
          'serving over 7,000 members engaged by 300,000 companies across Sweden.',
      techStack: ['Java', 'Kotlin', 'Flutter', 'Swift', 'Firebase'],
    ),
    ProjectModel(
      index: '04',
      title: 'Chase Technologies Inc.',
      year: '2019',
      role: 'Android Developer',
      description:
          'Developed mobile and software solutions for a leading Philippine '
          'IT systems integrator serving industries from retail to enterprise, '
          'specializing in POS systems, barcode solutions, and business '
          'management applications.',
      techStack: ['Java', 'Kotlin', 'Swift', 'Firebase', 'SQLite'],
    ),
  ];

  static const List<ProjectModel> sideProjects = [
    ProjectModel(
      index: '01',
      title: 'Personal Mobile Assistant',
      year: '2023',
      role: 'Android',
      description: 'A personal mobile assistant built with Kotlin for Android, '
          'designed to handle everyday tasks with quick, offline responses powered by a local database.',
      techStack: ['Kotlin', 'Room', 'Firebase', 'Tensorflow'],
      category: ProjectCategory.personal,
      thumbnailAsset: 'assets/thumbnails/mobileassistant.jpg',
      urlLink:
          'https://www.tiktok.com/@dev.imrkjoseph/video/7268900076364336389',
    ),
    ProjectModel(
      index: '02',
      title: 'Motorcycle Fingerprint Security',
      year: '2023',
      description:
          'Developed a Motorcycle Security System with Fingerprint Authentication that '
          'enhances vehicle protection by replacing traditional keys with biometric access.'
          ' The system uses fingerprint recognition technology to ensure'
          ' that only authorized users can start the motorcycle,'
          ' improving security and reducing theft risk.',
      techStack: ['Arduino', 'C++', 'Micro-controller'],
      category: ProjectCategory.personal,
      thumbnailAsset: 'assets/thumbnails/motorcyclefingerprint.jpg',
      urlLink:
          'https://www.tiktok.com/@dev.imrkjoseph/video/7273514618864127238',
    ),
    ProjectModel(
      index: '03',
      title: 'Animeflix',
      year: '2024',
      role: 'Android/iOS',
      description:
          'Developed a free movie streaming application that allows users to'
          ' browse and watch films through an intuitive and user friendly interface.'
          'The platform focuses on accessibility and seamless streaming performance.',
      techStack: ['Flutter', 'Dart', 'Flutter Animate'],
      category: ProjectCategory.personal,
      urlLink:
          'https://www.tiktok.com/@dev.imrkjoseph/video/7350223416059759878',
    ),
    ProjectModel(
      index: '04',
      title: 'KwikSerbisyo',
      year: '2023',
      role: 'Mobile/Web',
      description:
          'Developed KwikSerbisyo, an online booking platform that connects users with trusted service providers for home, technical, '
          'and personal services such as aircon and cellphone repair. '
          'The system enables users to easily browse services, schedule appointments,'
          ' and access support in one convenient platform.',
      techStack: ['Flutter', 'Dart', 'Laravel'],
      category: ProjectCategory.freelance,
      urlLink: 'https://kwikserbisyo.online/',
    ),
    ProjectModel(
      index: '05',
      title: 'E-Robot',
      year: '2019',
      description: 'Designed and built an autonomous obstacle-avoidance '
          'robot powered by an Arduino Nano microcontroller. Integrated distance sensors to detect obstacles '
          'in real time and implemented control logic to dynamically '
          'change direction, preventing collisions and ensuring smooth navigation.',
      techStack: [
        'Arduino Nano',
        'Micro-controller',
      ],
      category: ProjectCategory.personal,
    ),
    ProjectModel(
      index: '06',
      title: 'Traysitek',
      year: '2023',
      role: 'Mobile/Web',
      description: 'Developed Traysitek, a ride-booking platform that connects '
          'commuters with local tricycle drivers through a mobile-friendly system. '
          'The application enables users to book rides, view driver details, '
          'and experience a more convenient and organized transportation service.',
      techStack: ['Laravel', 'Flutter', 'Dart'],
      category: ProjectCategory.freelance,
      thumbnailAsset: 'assets/thumbnails/traysitek.jpg',
      urlLink: 'https://traysikel.tech/',
    ),
  ];

  static const List<({String label, List<String> skills})> skillGroups = [
    (
      label: 'Android',
      skills: [
        'Kotlin',
        'Java',
        'Jetpack Compose',
        'Room',
        'Retrofit',
        'Hilt',
        'WorkManager',
        'MVVM',
      ],
    ),
    (
      label: 'Flutter',
      skills: [
        'Dart',
        'Flutter Widgets',
        'Bloc',
        'Flutter Web',
        'Flutter Animate',
      ],
    ),
    (
      label: 'Backend & Infra',
      skills: [
        'Firebase',
        'Laravel',
        'REST APIs',
        'AWS',
        'Git / GitHub',
        'Fastlane',
        'Docker',
      ],
    ),
    (
      label: 'Tools',
      skills: [
        'Android Studio',
        'Visual Studio',
        'Postman',
        'Unity',
        'Clean Architecture',
        'Unit Testing',
        'Agile / Scrum',
        'Code Review',
      ],
    ),
  ];

  static const List<({String label, String value, String url})> contactLinks = [
    (
      label: 'Email:',
      value: 'imrkjoseph16@gmail.com',
      url: 'mailto:imrkjoseph16@gmail.com',
    ),
    (
      label: 'GitHub:',
      value: 'github.com/imrkjoseph16',
      url: 'https://github.com',
    ),
    (
      label: 'LinkedIn:',
      value: 'linkedin.com/in/imrkjoseph16',
      url: 'https://linkedin.com',
    ),
    (
      label: 'Tiktok:',
      value: 'dev.imrkjoseph',
      url: 'https://www.tiktok.com/@dev.imrkjoseph',
    ),
  ];
}
