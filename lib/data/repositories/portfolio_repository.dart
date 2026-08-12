import '../models/project_model.dart';
import '../models/skill_group_model.dart';

abstract final class PortfolioRepository {
  static const String name = 'Mark Joseph';
  static const String nameDisplay = 'Mark\nJoseph';
  static const String nameKr = '마크 조셉';
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
      "Outside of work, you'll often find me camping under the stars, "
      "traveling to new destinations, or tinkering with personal coding projects. "
      "I also love sharing programming content on TikTok and connecting with the dev community.";

  static const String bio2 =
      "I approach development with a strong emphasis on clarity and structure, "
      "writing code that remains easy to understand and evolve over time. "
      "I value thoughtful testing, consistency, and building systems that scale without becoming difficult to maintain.";

  static const String heroBio =
      'I primarily build high performance Android apps using Kotlin and Jetpack Compose,'
      ' while also creating cross platform experiences with Flutter. '
      'I focus on clean architecture, smooth micro-interactions, '
      'and products people genuinely enjoy using.';

  static const List<String> haiku = [
    'I\'m a Computer Engineer focused on Android and iOS development, with experience in both academic projects and corporate work. I enjoy turning ideas into apps that feel effortless, making software that\'s functional, efficient, maintainable, and fun to use.',
  ];

  static const List<({String value, String label})> stats = [
    (value: '7+', label: 'Years'),
    (value: '∞', label: 'Adventure'),
    (value: '10K+', label: 'Coffee day'),
    (value: '100%', label: 'Kotlin/Dart'),
  ];

  static const List<({String label, String value})> details = [
    (label: 'Based in:', value: 'Bulacan, Philippines'),
    (label: 'Education:', value: 'BS Computer Engineering'),
    (label: 'Languages:', value: 'Kotlin · Java · Dart'),
    (label: 'Focus:', value: 'Android · Flutter · Web'),
    (label: 'Available:', value: 'Freelance & Full-time'),
  ];

  static final List<SkillGroupModel> skillGroups = [
    const SkillGroupModel(
      label: 'Android',
      featured: true,
      reception: 5,
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
    const SkillGroupModel(
      label: 'Flutter',
      featured: true,
      reception: 5,
      skills: [
        'Dart',
        'Flutter Widgets',
        'Bloc',
        'Flutter Web',
        'Flutter Animate',
      ],
    ),
    const SkillGroupModel(
      label: 'Backend & Infra',
      featured: false,
      reception: 3,
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
    const SkillGroupModel(
      label: 'Tools',
      featured: false,
      reception: 3,
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

  static const List<ProjectModel> work = [
    ProjectModel(
      index: '01',
      title: 'Digital Space Explorer Inc.',
      year: '2026',
      role: 'Android Developer',
      description:
      'Built and maintained complex feed components and caching architecture for '
          'a enterprise mobile CRM, prioritizing offline availability and dynamic UI rendering.',
      techStack: ['Kotlin', 'Jetpack Compose', 'Clean Architecture', 'Room Database'],
      playStoreUrl:
      'https://play.google.com/store/apps/details?id=com.digitalspaceexplorer.squadzip&hl=en',
    ),
    ProjectModel(
      index: '02',
      title: 'Accenture Philippines',
      year: '2024',
      role: 'Software Engineer',
      description:
      'Developed and refined digital onboarding flows and real time financial tracking features '
          'for the UBS key4 platform, ensuring seamless UI state management and cross device '
          'stability under strict regulatory compliance.',
      techStack: ['Kotlin', 'Jetpack Compose', 'MVVM', 'Coroutines'],
      playStoreUrl: 'https://play.google.com/store/apps/details?id=com.ubs.swidKXJ.android&hl=en',
    ),
    ProjectModel(
      index: '03',
      title: 'Invisible Hand Inc.',
      year: '2021',
      role: 'Android Developer',
      description:
      'Developed a betting application for cockfighting Local/International '
          'with GCash payment integration, live streaming, and wallet management.',
      techStack: ['Java', 'Kotlin', 'Agora', 'Payment', 'AWS'],
    ),
    ProjectModel(
      index: '04',
      title: 'Byltax Systems Inc.',
      year: '2020',
      role: 'Mobile Developer',
      description:
      "Built and maintained a mobile application for Sweden's leading "
          'association of Authorized Accountants serving over 7,000 members '
          'engaged by 300,000 companies across Sweden.',
      techStack: ['Java', 'Kotlin', 'Flutter', 'Swift', 'Firebase'],
    ),
    ProjectModel(
      index: '05',
      title: 'Chase Technologies Inc.',
      year: '2019',
      role: 'Android Developer',
      description:
      'Developed mobile and software solutions for a leading Philippine '
          'IT systems integrator serving industries from retail to enterprise, '
          'specializing in POS systems and business management applications.',
      techStack: ['Java', 'Kotlin', 'Swift', 'Firebase', 'SQLite'],
    ),
  ];

  static const List<ProjectModel> sideProjects = [
    ProjectModel(
      index: '01',
      title: 'HatidGo',
      year: '',
      role: 'Mobile/Web',
      description:
      'A ride hailing and car booking platform featuring real time driver matching, '
          'live location tracking, and an interactive fare bidding system for flexible pricing.',
      techStack: ['Flutter', 'Dart', 'Laravel'],
      category: ProjectCategory.freelance,
      thumbnailAsset: 'assets/thumbnails/hatidgo.png',
      urlLink: 'https://hatidgo.com/home/',
    ),
    ProjectModel(
      index: '02',
      title: 'MasidStream',
      year: '2026',
      role: 'Mobile/Web',
      description:
      'An ad free movie streaming app. Browse a wide selection of movies and series, '
          'watch instantly or with friends using real time syncing, and keep track of your favorites.',
      techStack: ['Flutter', 'Dart', 'Flutter Animate', 'Supabase', 'Laravel'],
      category: ProjectCategory.personal,
      thumbnailAsset: 'assets/showcase/masid_stream/0.png',
      screenshots: [
        'assets/showcase/masid_stream/1.png',
        'assets/showcase/masid_stream/2.png',
        'assets/showcase/masid_stream/3.png',
        'assets/showcase/masid_stream/7.png',
        'assets/showcase/masid_stream/5.png',
        'assets/showcase/masid_stream/4.png',
        'assets/showcase/masid_stream/6.png',
        'assets/showcase/masid_stream/8.png',
      ],
    ),
    ProjectModel(
      index: '03',
      title: 'MasidTunes',
      year: '2026',
      role: 'Mobile/Web',
      description:
      'A spotify style music app with zero ads. Discover new tracks, watch music videos, '
          'create your own playlists, and enjoy high quality streaming.',
      techStack: ['Flutter', 'Dart', 'Flutter Animate'],
      category: ProjectCategory.personal,
      thumbnailAsset: 'assets/showcase/masid_tunes/0.png',
      screenshots: [
        'assets/showcase/masid_tunes/1.png',
        'assets/showcase/masid_tunes/2.png',
        'assets/showcase/masid_tunes/3.png',
        'assets/showcase/masid_tunes/7.png',
        'assets/showcase/masid_tunes/5.png',
        'assets/showcase/masid_tunes/4.png',
      ],
    ),
    ProjectModel(
      index: '04',
      title: 'Personal Mobile Assistant',
      year: '2023',
      role: 'Android',
      description:
      'A personal mobile assistant built with Kotlin for Android, '
          'designed to handle everyday tasks with quick, offline responses '
          'powered by a local database.',
      techStack: ['Kotlin', 'Room', 'Firebase', 'Tensorflow'],
      category: ProjectCategory.personal,
      thumbnailAsset: 'assets/thumbnails/mobileassistant.jpg',
      urlLink:
      'https://www.tiktok.com/@dev.imrkjoseph/video/7268900076364336389',
    ),
    ProjectModel(
      index: '05',
      title: 'Motorcycle Fingerprint Security',
      year: '2023',
      description:
      'A motorcycle security system with fingerprint authentication '
          'replacing traditional keys with biometric access using '
          'fingerprint recognition technology.',
      techStack: ['Arduino', 'C++', 'Micro-controller'],
      category: ProjectCategory.personal,
      thumbnailAsset: 'assets/thumbnails/motorcyclefingerprint.jpg',
      urlLink:
      'https://www.tiktok.com/@dev.imrkjoseph/video/7273514618864127238',
    ),
    ProjectModel(
      index: '06',
      title: 'Animeflix',
      year: '2024',
      role: 'Android/iOS',
      description:
      'A free movie streaming application that allows users to browse '
          'and watch films through an intuitive interface focused on '
          'accessibility and seamless streaming performance.',
      techStack: ['Flutter', 'Dart', 'Flutter Animate'],
      category: ProjectCategory.personal,
      urlLink:
      'https://www.tiktok.com/@dev.imrkjoseph/video/7350223416059759878',
    ),
    ProjectModel(
      index: '07',
      title: 'KwikSerbisyo',
      year: '2023',
      role: 'Mobile/Web',
      description:
      'An online booking platform connecting users with trusted service '
          'providers for home, technical, and personal services such as '
          'aircon and cellphone repair.',
      techStack: ['Flutter', 'Dart', 'Laravel'],
      category: ProjectCategory.freelance,
      urlLink: 'https://kwikserbisyo.online/',
    ),
    ProjectModel(
      index: '08',
      title: 'Traysitek',
      year: '2023',
      role: 'Mobile/Web',
      description:
      'A ride-booking platform connecting commuters with local tricycle '
          'drivers. Users can book rides, view driver details, and experience '
          'a more convenient transportation service.',
      techStack: ['Laravel', 'Flutter', 'Dart'],
      category: ProjectCategory.freelance,
      thumbnailAsset: 'assets/thumbnails/traysitek.jpg',
      urlLink: 'https://traysikel.tech/',
    ),
    ProjectModel(
      index: '09',
      title: 'E-Robot',
      year: '2019',
      description:
      'Autonomous obstacle-avoidance robot powered by Arduino Nano with '
          'distance sensors to detect obstacles and dynamically change '
          'direction, preventing collisions.',
      techStack: ['Arduino Nano', 'Micro-controller'],
      category: ProjectCategory.personal,
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
    url: 'https://github.com/imrkjoseph16',
    ),
    (
    label: 'LinkedIn:',
    value: 'linkedin.com/in/imrkjoseph16',
    url: 'https://linkedin.com/in/imrkjoseph16',
    ),
    (
    label: 'TikTok:',
    value: '@dev.imrkjoseph',
    url: 'https://www.tiktok.com/@dev.imrkjoseph',
    ),
  ];
}