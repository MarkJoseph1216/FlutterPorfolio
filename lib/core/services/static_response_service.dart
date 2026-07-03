import '../../data/models/channel_model.dart';
import '../../data/repositories/portfolio_repository.dart';

class StaticResponseService {
  static String getResponse(String userMessage, {ChannelModel? currentChannel}) {
    final message = userMessage.toLowerCase().trim();

    if (currentChannel != null) {
      if (message.contains('this') || message.contains('current') || message.contains('here')) {
        switch (currentChannel) {
          case ChannelModel.intro:
            return "You're currently on the INTRO channel. This is where you can learn about who I am - ${PortfolioRepository.name}, a ${PortfolioRepository.role} with ${PortfolioRepository.experience} of experience. Feel free to explore other channels!";
          case ChannelModel.about:
            return "You're on the ABOUT channel. Here you'll find detailed information about my background, including my ${PortfolioRepository.experience} of experience and ${PortfolioRepository.details.length} key details about my professional journey.";
          case ChannelModel.skills:
            return "You're on the SKILLS channel. This shows my technical expertise across ${PortfolioRepository.skillGroups.length} categories: ${PortfolioRepository.skillGroups.map((g) => g.label).join(', ')}. Check out the reception bars to see my proficiency levels!";
          case ChannelModel.work:
            return "You're on the WORK channel. This displays my professional experience at ${PortfolioRepository.work.length} companies: ${PortfolioRepository.work.map((p) => p.title).join(', ')}. Click on any card to see detailed descriptions!";
          case ChannelModel.projects:
            return "You're on the PROJECTS channel. Here you can explore my ${PortfolioRepository.sideProjects.length} side projects including ${PortfolioRepository.sideProjects.take(3).map((p) => p.title).join(', ')}. Each project has a link to view more!";
          case ChannelModel.contact:
            return "You're on the CONTACT channel. You can reach me at ${PortfolioRepository.email} or use the contact form to send me a message. I typically respond within 24 hours!";
        }
      }
    }

    // Hello responses
    if (message.contains('hello') || message.contains('hi') || message == 'hey' || message.startsWith('hel')) {
      return "Hello! Thanks for visiting my portfolio. I'm ${PortfolioRepository.name}, a ${PortfolioRepository.role} with ${PortfolioRepository.experience} of experience. How can I help you today? Feel free to ask about my skills, experience, or projects!";
    }

    // Tagalog responses
    if (message.contains('musta') || message.contains('kumusta') || message.contains('kamusta')) {
      return "Mabuti naman! Salamat sa pagbisita sa portfolio ko. Ako si ${PortfolioRepository.name}, isang ${PortfolioRepository.role}. Paano kita matutulungan ngayong araw?";
    }

    if (message.contains('salamat') || message.contains('thank')) {
      return "Walang anuman! Maraming salamat sa iyong interes sa aking trabaho. Ipagpaalam lang kung may mga katanungan ka!";
    }

    // Who are you / About me
    if (message.contains('who are you') || message.contains('tell me about yourself') || (message.contains('about') && message.contains('you'))) {
      return "I'm ${PortfolioRepository.name}, a ${PortfolioRepository.role} based in ${PortfolioRepository.location}. ${PortfolioRepository.title}. I have ${PortfolioRepository.experience} of experience building mobile apps. ${PortfolioRepository.heroBio.substring(0, 100)}... Check out my ABOUT channel for more details!";
    }

    // Work/Experience
    if (message.contains('work') || message.contains('experience') || message.contains('job') || message.contains('career')) {
      final workCount = PortfolioRepository.work.length;
      final companies = PortfolioRepository.work.map((p) => p.title).join(', ');
      return "I have ${PortfolioRepository.experience} of experience in mobile development! I've worked at $workCount companies including: $companies. My most recent role is as a ${PortfolioRepository.work.first.role} at ${PortfolioRepository.work.first.title}. Check out my WORK section for detailed experience!";
    }

    // Skills
    if (message.contains('skill') || message.contains('tech') || message.contains('technology') || message.contains('stack')) {
      final allSkills = PortfolioRepository.skillGroups.expand((g) => g.skills).toList();
      final featuredSkills = allSkills.take(8).join(', ');
      final categories = PortfolioRepository.skillGroups.map((g) => g.label).join(', ');
      return "My main tech stack includes:\n$featuredSkills\n\nI specialize in $categories. I have ${PortfolioRepository.experience} of experience with these technologies. Check out the SKILLS channel for my complete tech stack with proficiency indicators!";
    }

    // Projects
    if (message.contains('project') || message.contains('portfolio') || message.contains('build') || message.contains('made')) {
      final workProjects = PortfolioRepository.work;
      final sideProjects = PortfolioRepository.sideProjects;
      return "I've built ${workProjects.length + sideProjects.length}+ apps including:\n\nWORK PROJECTS:\n• ${workProjects.map((p) => p.title).join('\n• ')}\n\nSIDE PROJECTS:\n• ${sideProjects.take(4).map((p) => p.title).join('\n• ')}\n\nCheck out the WORK and PROJECTS channels to see them all with details!";
    }

    // Contact
    if (message.contains('contact') || message.contains('email') || message.contains('reach') || message.contains('get in touch')) {
      return "You can reach me at ${PortfolioRepository.email}\n\nGitHub: ${PortfolioRepository.github}\nLinkedIn: ${PortfolioRepository.linkedin}\nTikTok: ${PortfolioRepository.contactLinks.last.value}\n\nOr use the contact form in the CONTACT channel. I typically respond within 24 hours!";
    }

    // Hire/Work with me
    if (message.contains('hire') || message.contains('freelance') || message.contains('available') || message.contains('work with')) {
      return "Yes, I'm currently open for freelance opportunities and full-time positions! Based in ${PortfolioRepository.location}, I have ${PortfolioRepository.experience} of experience. I'm available for:\n• Android Development\n• Flutter Development\n• Mobile App Consulting\n\nFeel free to email me at ${PortfolioRepository.email} to discuss your project!";
    }

    // Thanks
    if (message.contains('thank') || message.contains('thanks') || message.contains('appreciate')) {
      return "You're very welcome! I appreciate your interest in my work. I've put a lot of effort into building these ${PortfolioRepository.work.length + PortfolioRepository.sideProjects.length} projects over my ${PortfolioRepository.experience} career. Let me know if you have any other questions!";
    }

    // Pricing
    if (message.contains('price') || message.contains('cost') || message.contains('rate') || message.contains('how much')) {
      return "My rates vary based on project scope and complexity. I've worked with companies ranging from startups to enterprise banks like ${PortfolioRepository.work.first.title}. Please contact me directly at ${PortfolioRepository.email} for a personalized quote tailored to your needs!";
    }

    // Android specific
    if (message.contains('android') || message.contains('kotlin') || message.contains('jetpack')) {
      final androidSkills = PortfolioRepository.skillGroups
          .firstWhere((g) => g.label == 'Android')
          .skills
          .take(6)
          .join(', ');
      return "Android development is my primary focus! I work with: $androidSkills. I have professional experience at ${PortfolioRepository.work.length} companies including ${PortfolioRepository.work.first.title} where I used Jetpack Compose and Kotlin. I love building smooth, performant apps with clean architecture!";
    }

    // Flutter specific
    if (message.contains('flutter') || message.contains('dart') || message.contains('cross-platform')) {
      final flutterSkills = PortfolioRepository.skillGroups
          .firstWhere((g) => g.label == 'Flutter')
          .skills
          .take(4)
          .join(', ');
      return "Flutter is my go-to for cross-platform development! I use: $flutterSkills. I've built several side projects with Flutter including ${PortfolioRepository.sideProjects.where((p) => p.techStack.contains('Flutter')).take(2).map((p) => p.title).join(' and ')}. It's amazing for building beautiful apps for both iOS and Android from a single codebase!";
    }

    // Location
    if (message.contains('location') || message.contains('based') || message.contains('where')) {
      return "I'm based in ${PortfolioRepository.location}, Philippines. I work remotely and am available for opportunities worldwide! I've worked with companies locally and internationally throughout my ${PortfolioRepository.experience} career.";
    }

    // Role/Title
    if (message.contains('role') || message.contains('title') || message.contains('what do you do')) {
      return "I'm a ${PortfolioRepository.role} specializing in mobile development. ${PortfolioRepository.title}. I focus on building high-quality Android and Flutter applications. ${PortfolioRepository.details.where((d) => d.label == 'Focus:').first.value}";
    }

    // Since/Started
    if (message.contains('since') || message.contains('started') || message.contains('when')) {
      return "I've been coding since ${PortfolioRepository.since}. That's ${PortfolioRepository.experience} of building apps, solving problems, and continuously learning. I started my professional career at ${PortfolioRepository.work.last.title} back in ${PortfolioRepository.work.last.year}!";
    }

    // Education
    if (message.contains('education') || message.contains('degree') || message.contains('study')) {
      return "${PortfolioRepository.details.where((d) => d.label == 'Education:').first.value} from the Philippines. My background combines theoretical knowledge with ${PortfolioRepository.experience} of hands-on industry experience!";
    }

    // Default response
    return "Thanks for your message! I appreciate you reaching out.\n\nHere's what you can explore on my portfolio:\n\n${ChannelModel.values.length} CHANNELS:\n• INTRO - About me\n• ABOUT - My background\n• SKILLS - ${PortfolioRepository.skillGroups.length} tech categories\n• WORK - ${PortfolioRepository.work.length} professional experiences\n• PROJECTS - ${PortfolioRepository.sideProjects.length} side projects\n• CONTACT - Get in touch\n\n~ Or email me directly: ${PortfolioRepository.email}\n\nIs there anything specific you'd like to know about my ${PortfolioRepository.experience} of experience or any of my projects?";
  }
}