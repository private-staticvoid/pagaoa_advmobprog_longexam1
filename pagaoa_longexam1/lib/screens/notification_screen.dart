import '../widgets/custom_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    final dividerColor = secondaryTextColor(context);
    return Scaffold(
      backgroundColor: bgColor(context),
      body: ListView(
        padding: EdgeInsets.all(10.w),
        children: [
          CustomInfo(
            name: 'Cam',
            post: 'Updated profile picture',
            description: 'Cam just refreshed their look!',
            date: 'Jan 3, 2026',
            numOfLikes: 0,
          ),
          Divider(color: dividerColor),
          CustomInfo(
            name: 'Cam',
            post: 'Posted a new photo',
            description: 'Check out Cam’s new post!',
            date: 'Jan 2, 2026',
            numOfLikes: 0,
          ),
          Divider(color: dividerColor),
          CustomInfo(
            name: 'Achiles',
            post: 'Posted in Hirono Buy & Sell',
            description: 'Selling a rare Hirono item!',
            date: 'Dec 30, 2025',
            numOfLikes: 0,
          ),
          Divider(color: dividerColor),
          CustomInfo(
            name: 'Achiles',
            post: 'Updated his cover Photo',
            description: 'Adventure Time',
            date: 'Dec 28, 2025',
            numOfLikes: 0,
          ),
          Divider(color: dividerColor),
          CustomInfo(
            name: 'Achiles',
            post: 'Posted a new status',
            description: 'Kelan ba labasan T-T',
            date: 'Dec 25, 2025',
            numOfLikes: 0,
          ),
          Divider(color: dividerColor),
          CustomInfo(
            name: 'Rhodney Mabaho',
            post: 'Updated his profile photo',
            description: 'Bat ang baho ko?',
            date: 'Dec 20, 2025',
            numOfLikes: 0,
          ),
          Divider(color: dividerColor),
          CustomInfo(
            name: 'Marahuyo',
            post: 'Successfully created your account',
            description: '',
            date: 'Dec 10, 2025',
            numOfLikes: 0,
          ),
        ],
      ),
    );
  }
}
