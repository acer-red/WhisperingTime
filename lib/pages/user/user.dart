import 'package:flutter/material.dart';
import 'package:whispering_time/services/http/base.dart';
import 'package:whispering_time/utils/ui.dart';
import 'package:whispering_time/utils/env.dart';
import 'package:whispering_time/pages/welcome.dart';
import 'package:whispering_time/services/isar/config.dart';
import 'package:whispering_time/services/sp/sp.dart';
import 'package:whispering_time/services/http/index.dart';

class UserPage extends StatefulWidget {
  @override
  State<UserPage> createState() => _UserPage();
}

class _UserPage extends State<UserPage> {
  late Future<UserBasicInfo> _userInfoFuture;
  UserBasicInfo user = UserBasicInfo(
      email: "",
      profile:
          Profile(nickname: "", avatar: Avatar(name: "", url: ""))); // 初始化 user

  @override
  void initState() {
    super.initState();
    _userInfoFuture = init();
  }

  @override
  void didUpdateWidget(covariant UserPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    SP().setIsAutoLogin(false);
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        logout();
      },
      child: avatarIcon(),
    );
  }

  logout() {
    showConfirmationDialog(context, MyDialog(content: "确定退出吗？")).then((value) {
      if (!value) {
        return;
      }
      Config().close();
      SP().setIsAutoLogin(false);
      if (mounted) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Welcome(),
            ));
      }
    });
  }

  Future<UserBasicInfo> init() async {
    final value = await Http().userInfo();
    if (value.isNotOK) {
      if (mounted) {
        showErrMsg(context, "服务器连接失败");
        return user;
      }
      return user;
    }
    setState(() {
      user = UserBasicInfo(email: value.email, profile: value.profile);
    });
    return user;
  }

  Widget avatarIcon() {
    return Padding(
        padding: const EdgeInsets.all(2.0),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {},
            child: FutureBuilder<UserBasicInfo>(
              future: _userInfoFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return CircleAvatar(
                    radius: 15,
                    child: Icon(Icons.person),
                  );
                }

                if (snapshot.hasData &&
                    snapshot.data?.profile.avatar.url != null) {
                  return CircleAvatar(
                    backgroundImage:
                        NetworkImage("${HTTPConfig.indexServerAddress}${snapshot.data!.profile.avatar.url}"),
                    radius: 15,
                  );
                } else {
                  return CircleAvatar(
                    radius: 15,
                    child: Icon(Icons.person), // 或者其他默认的占位符
                  );
                }
              },
            ),
          ),
        ));
  }
}
