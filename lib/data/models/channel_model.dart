enum ChannelModel {
  intro(1, '소개', 'INTRO'),
  about(2, '정보', 'ABOUT'),
  skills(3, '기술', 'SKILLS'),
  work(4, '작업', 'WORK'),
  projects(5, '프로젝트', 'PROJECTS'),
  contact(6, '연락', 'CONTACT');

  const ChannelModel(this.number, this.kr, this.en);
  final int number;
  final String kr, en;
}