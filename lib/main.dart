import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() => runApp(const PortfoliApp());

class PortfoliApp extends StatelessWidget {
  const PortfoliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const PortfolioHomePageRoot();
  }
}

class PortfolioHomePageRoot extends StatefulWidget {
  const PortfolioHomePageRoot({super.key});
  @override
  State<PortfolioHomePageRoot> createState() => _PortfolioHomePageRootState();
}

class _PortfolioHomePageRootState extends State<PortfolioHomePageRoot> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Anyahuru Oluebube Daniel',
      theme: ThemeData(
        brightness: isDark ? Brightness.dark : Brightness.light,
        fontFamily: 'Sans',
        scaffoldBackgroundColor:
            isDark ? const Color(0xFF181818) : Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE0CC9F),
          brightness: isDark ? Brightness.dark : Brightness.light,
        ),
        dividerColor: isDark ? Colors.grey[700] : Colors.grey,
        textTheme: ThemeData.light().textTheme.apply(
              bodyColor: isDark ? Colors.white : Colors.black,
              displayColor: isDark ? Colors.white : Colors.black,
            ),
      ),
      home: PortfolioHomePage(
        isDark: isDark,
        onToggleTheme: () => setState(() => isDark = !isDark),
      ),
    );
  }
}

class PortfolioHomePage extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;
  const PortfolioHomePage(
      {super.key, required this.isDark, required this.onToggleTheme});

  @override
  State<PortfolioHomePage> createState() => _PortfolioHomePageState();
}

class _PortfolioHomePageState extends State<PortfolioHomePage> {
  final aboutKey = GlobalKey();
  final projectsKey = GlobalKey();
  final skillsKey = GlobalKey();
  final experienceKey = GlobalKey();
  final contactKey = GlobalKey();
  String activeSection = 'About Me';

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Helper to get the offset of a section
    double getOffset(GlobalKey key) {
      final ctx = key.currentContext;
      if (ctx == null) return double.infinity;
      final box = ctx.findRenderObject() as RenderBox;
      return box
          .localToGlobal(Offset.zero, ancestor: context.findRenderObject())
          .dy;
    }

    // Get the scroll position and section offsets
    final offsets = {
      'About Me': getOffset(aboutKey),
      'Projects': getOffset(projectsKey),
      'Skills': getOffset(skillsKey),
      'Experience': getOffset(experienceKey),
      'Contact': getOffset(contactKey),
    };

    // Find the section closest to the top (but not above)
    String current = activeSection;
    double minDiff = double.infinity;
    offsets.forEach((section, offset) {
      final diff = offset.abs();
      if (diff < minDiff) {
        minDiff = diff;
        current = section;
      }
    });

    if (current != activeSection) {
      setState(() {
        activeSection = current;
      });
    }
  }

  void scrollTo(GlobalKey key, String section) {
    setState(() => activeSection = section);
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: isMobile
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _buildNavItems(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                            widget.isDark ? Icons.light_mode : Icons.dark_mode),
                        tooltip: widget.isDark
                            ? 'Switch to Light Mode'
                            : 'Switch to Dark Mode',
                        onPressed: widget.onToggleTheme,
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: _buildNavItems()),
                      IconButton(
                        icon: Icon(
                            widget.isDark ? Icons.light_mode : Icons.dark_mode),
                        tooltip: widget.isDark
                            ? 'Switch to Light Mode'
                            : 'Switch to Dark Mode',
                        onPressed: widget.onToggleTheme,
                      ),
                    ],
                  ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionContainer(key: aboutKey, child: const HeroSection()),
                  Divider(
                      thickness: 1,
                      color: Theme.of(context).dividerColor,
                      height: 40),
                  SectionContainer(
                      key: projectsKey, child: const ProjectsSection()),
                  Divider(
                      thickness: 1,
                      color: Theme.of(context).dividerColor,
                      height: 40),
                  SectionContainer(
                      key: skillsKey, child: const SkillsSection()),
                  Divider(
                      thickness: 1,
                      color: Theme.of(context).dividerColor,
                      height: 40),
                  SectionContainer(
                      key: experienceKey, child: const ExperienceSection()),
                  Divider(
                      thickness: 1,
                      color: Theme.of(context).dividerColor,
                      height: 40),
                  SectionContainer(
                      key: contactKey, child: const ContactSection()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNavItems() {
    return [
      NavItem('About Me', () => scrollTo(aboutKey, 'About Me'),
          isActive: activeSection == 'About Me'),
      NavItem('Projects', () => scrollTo(projectsKey, 'Projects'),
          isActive: activeSection == 'Projects'),
      NavItem('Skills', () => scrollTo(skillsKey, 'Skills'),
          isActive: activeSection == 'Skills'),
      NavItem('Experience', () => scrollTo(experienceKey, 'Experience'),
          isActive: activeSection == 'Experience'),
      NavItem('Contact', () => scrollTo(contactKey, 'Contact'),
          isActive: activeSection == 'Contact'),
    ];
  }
}

class NavItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  const NavItem(this.label, this.onTap, {required this.isActive, super.key});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isActive
                ? const Color(0xFFE0CC9F)
                : (isDark ? Colors.white : Colors.black),
            shadows: isActive
                ? [
                    const Shadow(
                      blurRadius: 10.0,
                      color: Color(0xFFE0CC9F),
                      offset: Offset(0, 0),
                    ),
                  ]
                : [],
          ),
        ),
      ),
    );
  }
}

class SectionContainer extends StatelessWidget {
  final Widget child;
  const SectionContainer({required Key key, required this.child})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Padding(
      key: key,
      padding: EdgeInsets.all(isMobile ? 20.0 : 40.0),
      child: child,
    );
  }
}

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final player = AudioPlayer();

    Widget nameRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Hello, I’m Anyahuru Oluebube Daniel",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.volume_up, color: Colors.brown),
          tooltip: 'Hear my name',
          onPressed: () async {
            try {
              await player.play(AssetSource('audio/name.mp3'));
            } catch (e) {
              print('Audio error: $e');
            }
          },
        ),
      ],
    );

    // Social media row widget
    Widget socialRow = Row(
      mainAxisAlignment:
          isMobile ? MainAxisAlignment.start : MainAxisAlignment.start,
      children: [
        SocialMediaIconBox(
          icon: SvgPicture.string(
            '''<svg width="24" height="24" viewBox="0 0 24 24"><path fill="#0A66C2" d="M19 0h-14c-2.76 0-5 2.24-5 5v14c0 2.76 2.24 5 5 5h14c2.76 0 5-2.24 5-5v-14c0-2.76-2.24-5-5-5zm-11 19h-3v-9h3v9zm-1.5-10.29c-.97 0-1.75-.79-1.75-1.76s.78-1.76 1.75-1.76 1.75.79 1.75 1.76-.78 1.76-1.75 1.76zm13.5 10.29h-3v-4.5c0-1.08-.02-2.47-1.5-2.47-1.5 0-1.73 1.17-1.73 2.39v4.58h-3v-9h2.89v1.23h.04c.4-.75 1.37-1.54 2.82-1.54 3.01 0 3.57 1.98 3.57 4.56v4.75z"/></svg>''',
            width: 28,
            height: 28,
          ),
          url: 'https://www.linkedin.com/in/anyahuru-oluebube-26004b26a/',
        ),
        const SizedBox(width: 10),
        SocialMediaIconBox(
          icon: const Icon(Icons.code,
              color: Colors.black), // GitHub icon alternative
          url: 'https://github.com/MrDaniel07',
        ),
        const SizedBox(width: 10),
        SocialMediaIconBox(
          icon: const Icon(Icons.ondemand_video,
              color: Colors.red), // YouTube icon alternative
          url: 'https://www.youtube.com/@danieloluebube',
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.all(isMobile ? 20.0 : 40.0),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                nameRow,
                const SizedBox(height: 10),
                const SizedBox(height: 10),
                // Move the image here, right after the intro
                Center(
                  child: Container(
                    width: 160,
                    height: 170,
                    color: Colors.white,
                    child: Image.asset(
                      "assets/images/good_pic.jpeg",
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "A Software Engineer and Cloud Security Engineer",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                const Text(
                  "A Software Engineer and a Cloud Security Engineer with experience in developing applications, cloud security, and cybersecurity compliance. \nProficient in software development, AWS cloud security, risk assessment, and security analysis. Hands-on experience in endpoint protection, incident response, and network security. Skilled in data analysis, program management, and UI/UX engineering.Strong background in cross-platform app development, along with SQL database design and data visualization. Passionate about securing digital assets and building scalable applications.",
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 30),
                socialRow, // <-- Add here

                ElevatedButton(
                  onPressed: () {
                    final url = Uri.parse(
                        'https://raw.githubusercontent.com/MrDaniel07/RESUM-/main/Daniel_Software_Cybersecurity_Resume_Updated.docx');
                    launchUrl(url);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE0CC9F),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    textStyle: const TextStyle(fontSize: 14),
                  ),
                  child: const Text('Download Résumé'),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      nameRow,
                      const SizedBox(height: 10),
                      const SizedBox(height: 10),
                      const Text(
                        "A Software Engineer and Cloud Security Engineer",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "A Software Engineer and a Cloud Security Engineer with experience in developing applications, cloud security, and cybersecurity compliance. \nProficient in software development, AWS cloud security, risk assessment, and security analysis. Hands-on experience in endpoint protection, incident response, and network security. Skilled in data analysis, program management, and UI/UX engineering.Strong background in cross-platform app development, along with SQL database design and data visualization. Passionate about securing digital assets and building scalable applications.",
                        style: TextStyle(fontSize: 17),
                      ),
                      const SizedBox(height: 30),
                      socialRow, // <-- Add here
                      const SizedBox(height: 70),
                      ElevatedButton(
                        onPressed: () {
                          final url = Uri.parse(
                              'https://raw.githubusercontent.com/MrDaniel07/RESUM-/main/Daniel_Software_Cybersecurity_Resume_Updated.docx');
                          launchUrl(url);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE0CC9F),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        child: const Text('Download Résumé'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                Container(
                  width: 240,
                  height: 250,
                  color: Colors.white,
                  child: Image.asset(
                    "assets/images/good_pic.jpeg",
                    fit: BoxFit.fill,
                  ),
                )
              ],
            ),
    );
  }
}

class Project {
  final String title;
  final String description;
  final String imagePath;
  final String? link;

  const Project({
    required this.title,
    required this.description,
    required this.imagePath,
    this.link,
  });
}

class ProjectsSection extends StatelessWidget {
  const ProjectsSection({super.key});

  final List<Project> projects = const [
    Project(
      title: 'To Do List App',
      description:
          'A cross-platform To-Do app with local data storage and a clean, intuitive interface for managing daily tasks.',
      imagePath: 'assets/images/ToDo.png',
      link: 'https://github.com/MrDaniel07/ToDoApp',
    ),
    Project(
      title: 'E-commerce mobile app design',
      description:
          'A high-fidelity mobile app UI for an e-commerce platform, designed with intuitive navigation based on user flow analysis and wireframes.',
      imagePath: 'assets/images/Crypt.png',
      link:
          'https://www.figma.com/design/0WI5faaZQ79XhCtuXVdShP/First-Design?node-id=0-1&t=ZhhZefX4W3QjkvcH-1',
    ),
    Project(
      title: 'Safety Awareness Game Website',
      description:
          'An interactive fire safety awareness game set in a high-rise office building. Players must make quick decisions, answer safety questions, and navigate through a burning environment to reach safety—testing and improving their emergency preparedness in a fun, gamified way.',
      imagePath: 'assets/images/Fire.png',
      link: 'https://firesafetygame.netlify.app/',
    ),
    Project(
      title: 'Upcoming Project (Definitely Not Procrastination)',
      description: 'This project is still loading…',
      imagePath: 'assets/images/Fun.png',
      link: 'https://longdogechallenge.com/',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Padding(
      padding: EdgeInsets.all(isMobile ? 20.0 : 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Projects',
              style: TextStyle(
                  fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          isMobile
              ? Column(
                  children: projects
                      .map((project) => Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: ProjectCard(project: project),
                          ))
                      .toList(),
                )
              : Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: projects
                      .map((project) => ProjectCard(project: project))
                      .toList(),
                ),
        ],
      ),
    );
  }
}

class ProjectCard extends StatefulWidget {
  final Project project;
  const ProjectCard({required this.project, super.key});

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final project = widget.project;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isMobile ? double.infinity : 250,
        padding: const EdgeInsets.all(16),
        margin: isMobile ? const EdgeInsets.symmetric(horizontal: 0) : null,
        decoration: BoxDecoration(
          color: _isHovering
              ? const Color.fromARGB(255, 195, 195, 195)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 5,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              project.imagePath,
              height: isMobile ? 160 : 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 10),
            Text(
              project.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black, // Always black
              ),
            ),
            const SizedBox(height: 5),
            Text(
              project.description,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black, // Always black
              ),
            ),
            if (project.link != null) ...[
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => launchUrl(Uri.parse(project.link!)),
                child: const Text('View Project'),
              )
            ],
          ],
        ),
      ),
    );
  }
}

class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});

  final List<Map<String, dynamic>> skills = const [
    {'name': 'AWS cloud security', 'level': 0.7},
    {'name': 'Red team security', 'level': 0.65},
    {'name': 'Problem solving', 'level': 0.9},
    {'name': 'Communication', 'level': 0.9},
    {'name': 'Data analysis', 'level': 0.85},
    {'name': 'Software development', 'level': 0.75},
    {'name': 'Programming', 'level': 0.85},
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Padding(
      padding: EdgeInsets.all(isMobile ? 20.0 : 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Skills',
              style: TextStyle(
                  fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ...skills.map((skill) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(skill['name'],
                        style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 5),
                    LinearProgressIndicator(
                      value: skill['level'],
                      backgroundColor: Colors.grey[300],
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.black),
                      minHeight: isMobile ? 8 : 10,
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class ExperienceSection extends StatelessWidget {
  const ExperienceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Padding(
      padding: EdgeInsets.all(isMobile ? 20.0 : 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Experience',
              style: TextStyle(
                  fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildExperienceItem(
            context,
            isMobile: isMobile,
            title:
                'IHS Towers – Internship [Cybersecurity Analyst] (Jan 2025 – Feb 2025)',
            description:
                '- Monitored Sophos alerts, responded to malware, and collaborated with Red Team to enhance protection.\n- Gained experience using Sophos Endpoint Protection, device control, and email security.',
            imagePath: 'assets/images/Ihs.png',
          ),
          ElevatedButton(
            onPressed: () {
              final url = Uri.parse(
                  'https://drive.google.com/uc?export=download&id=139JsEa2s759EZ8j9XCev8FXQgIyra4ad');
              launchUrl(url);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE0CC9F)),
            child: const Text(
              'Download document',
              style: TextStyle(color: Colors.black),
            ),
          ),
          const SizedBox(height: 20),
          _buildExperienceItem(
            context,
            isMobile: isMobile,
            title:
                'Seplat Energy Plc – Internship [Software Engineer & Data Analyst] (Feb 2025 – June 2025)',
            description:
                '- Redesigned inventory system for usability and workflow.\n- Built interactive game with leaderboard, data collection, and storage.\n- Created Power BI dashboard to visualize Microsoft Forms data.\n- Analyzed survey results in Excel, conducted HSE solutions, and supported weekly meetings.',
            imagePath: 'assets/images/Seplat.png',
          ),
          ElevatedButton(
            onPressed: () {
              final url = Uri.parse(
                  'https://drive.google.com/uc?export=download&id=1KeFnZmVOqUhnDPZrrF6CB1sDoZVjaEJP');
              launchUrl(url);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE0CC9F)),
            child: const Text(
              'Download document',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceItem(BuildContext context,
      {required String title,
      required String description,
      required String imagePath,
      required bool isMobile}) {
    return isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(description,
                  style: const TextStyle(fontSize: 14), softWrap: true),
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: AssetImage(imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(description,
                        style: const TextStyle(fontSize: 14), softWrap: true),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          );
  }
}

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: EdgeInsets.only(
        left: isMobile ? 20.0 : 40.0,
        right: isMobile ? 20.0 : 40.0,
        top: 20.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact',
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Anyahuru Oluebube Daniel',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const Text(
                      '+234 8071678058',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const Text(
                      'anyahurudaniel55@gmail.com',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const Text(
                      'LinkedIn: ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        const url =
                            'https://www.linkedin.com/in/anyahuru-oluebube-26004b26a/';
                        if (kIsWeb) {
                          html.window.open(url, '_blank');
                        } else {
                          launchUrl(Uri.parse(url),
                              mode: LaunchMode.externalApplication);
                        }
                      },
                      child: Text(
                        'https://www.linkedin.com/in/anyahuru-oluebube-26004b26a/',
                        style: TextStyle(
                          fontSize: isMobile ? 18 : 20,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        final Uri emailLaunchUri = Uri(
                          scheme: 'mailto',
                          path: 'anyahurudaniel55@gmail.com',
                        );
                        await launchUrl(emailLaunchUri);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE0CC9F),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: const Text('Message me'),
                    ),
                    const SizedBox(height: 20),
                    const Center(
                      child: CoffeeEmojiEffect(width: 120, height: 120),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Anyahuru Oluebube Daniel',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          const Text(
                            '+234 8071678058',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          const Text(
                            'anyahurudaniel55@gmail.com',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          const Text(
                            'LinkedIn: ',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              const url =
                                  'https://www.linkedin.com/in/anyahuru-oluebube-26004b26a/';
                              if (kIsWeb) {
                                html.window.open(url, '_blank');
                              } else {
                                launchUrl(Uri.parse(url),
                                    mode: LaunchMode.externalApplication);
                              }
                            },
                            child: Text(
                              'https://www.linkedin.com/in/anyahuru-oluebube-26004b26a/',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () async {
                              final Uri emailLaunchUri = Uri(
                                scheme: 'mailto',
                                path: 'anyahurudaniel55@gmail.com',
                              );
                              await launchUrl(emailLaunchUri);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE0CC9F),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                            child: const Text('Message me'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    const CoffeeEmojiEffect(width: 200, height: 200),
                  ],
                ),
        ],
      ),
    );
  }
}

class SocialMediaIconBox extends StatelessWidget {
  final Widget icon;
  final String url;
  const SocialMediaIconBox({super.key, required this.icon, required this.url});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE0CC9F),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(6),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        child: icon,
      ),
    );
  }
}

class CoffeeEmojiEffect extends StatefulWidget {
  final double width;
  final double height;
  const CoffeeEmojiEffect({super.key, this.width = 120, this.height = 120});

  @override
  State<CoffeeEmojiEffect> createState() => _CoffeeEmojiEffectState();
}

class _CoffeeEmojiEffectState extends State<CoffeeEmojiEffect>
    with TickerProviderStateMixin {
  final List<_FloatingEmoji> _emojis = [];
  final Random _random = Random();

  void _showEmojis() {
    for (int i = 0; i < 6; i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 1200),
        vsync: this,
      );
      final animation = CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      );
      final left = _random.nextDouble() * (widget.width - 32);
      final uniqueKey = UniqueKey();
      final emoji = _FloatingEmoji(
        key: uniqueKey,
        left: left,
        animation: animation,
        onEnd: () {
          setState(() {
            _emojis.removeWhere((e) => e.key == uniqueKey);
          });
        },
      );
      setState(() {
        _emojis.add(emoji);
      });
      controller.forward().then((_) => controller.dispose());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showEmojis,
      child: Stack(
        children: [
          Container(
            width: widget.width,
            height: widget.height,
            color: Colors.brown[100],
            child: Center(
              child: Image.asset(
                "assets/images/coffe.png",
                fit: BoxFit.fill,
                width: widget.width,
                height: widget.height,
              ),
            ),
          ),
          ..._emojis,
        ],
      ),
    );
  }
}

class _FloatingEmoji extends StatefulWidget {
  final double left;
  final Animation<double> animation;
  final VoidCallback onEnd;

  const _FloatingEmoji({
    required Key key,
    required this.left,
    required this.animation,
    required this.onEnd,
  }) : super(key: key);

  @override
  State<_FloatingEmoji> createState() => _FloatingEmojiState();
}

class _FloatingEmojiState extends State<_FloatingEmoji> {
  @override
  void initState() {
    super.initState();
    widget.animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onEnd();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, child) {
        final double progress = widget.animation.value;
        return Positioned(
          left: widget.left,
          bottom: 0 + 10,
          child: Opacity(
            opacity: 1.0 - progress,
            child: Transform.translate(
              offset: Offset(0, -progress * 80),
              child: const Text(
                "😊",
                style: TextStyle(fontSize: 32),
              ),
            ),
          ),
        );
      },
    );
  }
}
