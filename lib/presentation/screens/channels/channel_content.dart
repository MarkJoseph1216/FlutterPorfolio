import 'package:flutter/material.dart';
import '../../../core/utils/screen_utils.dart';
import '../../../data/models/channel_model.dart';
import 'intro_body.dart';
import 'about_body.dart';
import 'skills_body.dart';
import 'work_body.dart';
import 'projects_body.dart';
import 'contact_body.dart';

class ChannelContent extends StatelessWidget {
  const ChannelContent({super.key, required this.channel});
  final ChannelModel channel;

  @override
  Widget build(BuildContext context) {
    final fs = ScreenUtils.fontScale(context);
    final isCompact = ScreenUtils.isCompactMobile(context);

    switch (channel) {
      case ChannelModel.intro:
        return IntroBody(fs: fs, isCompact: isCompact);
      case ChannelModel.about:
        return AboutBody(fs: fs, isCompact: isCompact);
      case ChannelModel.skills:
        return SkillsBody(fs: fs);
      case ChannelModel.work:
        return WorkBody(fs: fs);
      case ChannelModel.projects:
        return ProjectsBody(fs: fs);
      case ChannelModel.contact:
        return ContactBody(fs: fs);
    }
  }
}