import 'package:flutter/material.dart';
import 'package:whispering_time/utils/ui.dart';
import 'package:whispering_time/pages/home.dart';
import 'package:whispering_time/services/http/index.dart';
import 'package:whispering_time/services/sp/sp.dart';
import 'package:whispering_time/services/isar/config.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _Welcome();
}

class _Welcome extends State<Welcome> {
  TextEditingController userController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController accountController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController registerPasswordController = TextEditingController();
  TextEditingController passwordAgainController = TextEditingController();

  bool _showLogin = false;
  bool _isRegister = false;
  bool isAutoLogin = false;

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Padding(
                    padding:
                        EdgeInsets.only(left: 70.0, right: 70.0, bottom: 20),
                    child: Image(
                        image:
                            AssetImage('assets/images/wt-transparent-512.png')),
                  ),
                  Text('枫迹',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text('生活不只是日复一日，更是步步印迹',
                      maxLines: 1,
                      style: TextStyle(fontSize: 15, color: Color(0xFF777777))),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_showLogin)
                      _isRegister ? registerForm() : loginForm()
                    else
                      accountType(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget accountType() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () => visitor(),
          icon: const Icon(Icons.explore),
          label: const Text('游客访问'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _showLogin = true;
            });
          },
          icon: const Icon(Icons.account_circle),
          label: const Text('账号登陆'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("游客模式说明"),
                  content: const Text("游客模式下，无法提交反馈且不支持多端数据共享"),
                  actions: [
                    TextButton(
                      child: const Text("知道了"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
          icon: const Icon(Icons.info_outline),
          label: const Text('了解更多'),
        ),
      ],
    );
  }

  // 注册UI
  Widget registerForm() {
    return Column(
      spacing: 20,
      children: [
        TextFormField(
          autofocus: true,
          controller: userController,
          decoration: const InputDecoration(
            labelText: '用户名',
            border: OutlineInputBorder(),
          ),
        ),
        TextFormField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: '邮箱',
            border: OutlineInputBorder(),
          ),
        ),
        TextFormField(
          controller: registerPasswordController,
          decoration: const InputDecoration(
            labelText: '密码',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        TextFormField(
          controller: passwordAgainController,
          decoration: const InputDecoration(
            labelText: '再次输入密码',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  _isRegister = false;
                });
              },
              child: const Text('已有账号'),
            ),
            ElevatedButton(
              onPressed: () => register(),
              child: const Text('注册'),
            ),
          ],
        ),
      ],
    );
  }

  // 登录UI
  Widget loginForm() {
    return Column(
      spacing: 20,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          TextButton(
            onPressed: () => visitor(),
            child: const Text('游客登陆'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _isRegister = true;
              });
            },
            child: const Text('注册账号'),
          ),
        ]),
        TextFormField(
          autofocus: true,
          controller: accountController,
          decoration: const InputDecoration(
            labelText: '用户名/邮箱',
            border: OutlineInputBorder(),
          ),
        ),
        TextFormField(
          controller: passwordController,
          decoration: const InputDecoration(
            labelText: '密码',
            border: OutlineInputBorder(),
          ),
          onFieldSubmitted: (value) => login(),
          obscureText: true,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: isAutoLogin,
                  onChanged: (bool? value) {
                    setState(() {
                      isAutoLogin = value!;
                    });
                  },
                ),
                const Text('自动登录'),
              ],
            ),
            ElevatedButton(
              onPressed: () => login(),
              child: const Text('登录'),
            ),
          ],
        ),
      ],
    );
  }

  // 游客访问
  void visitor() {
    showConfirmationDialog(context, MyDialog(content: "是否以游客身份登陆？"))
        .then((value) async {
      if (!value) {
        return;
      }
      final oldVisitorId = SP().getVisitorUID();
      bool isVisitorLogged = SP().getIsVisitorLogged();
      if (isVisitorLogged && oldVisitorId.isNotEmpty) {
        print("使用旧游客账号登陆");
        await Config().init(oldVisitorId);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
        }
        return;
      }
      print("使用新游客账号登陆");

      Http().userRegisterVisitor().then((value) async {
        final newVisitorId = value.id;
        if (value.isNotOK) {
          if (mounted) {
            showErrMsg(context, value.msg);
          }
          return;
        }
        if (value.id.isEmpty) {
          if (mounted) {
            showErrMsg(context, '用户不存在');
          }
          return;
        }
        SP().setIsVisitor(true);
        SP().setVisitorUID(value.id);
        SP().setIsVisitorLogged(true);
        await Config().init(newVisitorId);
        await Config.instance.setAPIs(value.apis);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
        }
      });
    });
  }

  bool checkAccount() {
    if (accountController.text.isEmpty) {
      showErrMsg(context, '用户名不能为空');
      return false;
    }
    return true;
  }

  bool checkPassword() {
    if (passwordController.text.isEmpty) {
      showErrMsg(context, '密码不能为空');
      return false;
    }
    return true;
  }

  bool loginCheck() {
    if (!checkAccount()) {
      return false;
    }
    if (!checkPassword()) {
      return false;
    }
    return true;
  }

  // 用户登录
  void login() {
    final ok = loginCheck();
    if (!ok) {
      return;
    }

    final String account = accountController.text;
    final String password = passwordController.text;

    Http()
        .userLogin(RequestPostUserLogin(account: account, password: password))
        .then((value) async {
          final loginUserId = value.id;
      if (value.isOK) {
        if (loginUserId.isEmpty) {
          if (mounted) {
            showErrMsg(context, '用户不存在');
          }
          return;
        }
        SP().setIsVisitor(false);
        SP().setUID(loginUserId);
        SP().setIsVisitorLogged(false);
        SP().setIsAutoLogin(isAutoLogin);
        await Config().init(loginUserId); 
        await Config.instance.setAPIs(value.apis);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
        }
      } else {
        if (mounted) {
          showErrMsg(context, value.msg);
        }
      }
    });
  }

  bool checkRegisterPasswd() {
    final password = registerPasswordController.text;

    if (password.isEmpty) {
      showErrMsg(context, '密码不能为空');
      return false;
    }

    if (password.length < 8) {
      showErrMsg(context, '密码长度不能少于 8 个字符');
      return false;
    }

    // 检查是否包含大写字母
    if (!password.contains(RegExp(r'[A-Z]'))) {
      showErrMsg(context, '密码需要包含至少一个大写字母');
      return false;
    }

    // 检查是否包含小写字母
    if (!password.contains(RegExp(r'[a-z]'))) {
      showErrMsg(context, '密码需要包含至少一个小写字母');
      return false;
    }

    // 检查是否包含数字
    if (!password.contains(RegExp(r''))) {
      showErrMsg(context, '密码需要包含至少一个数字');
      return false;
    }

    // 检查是否包含特殊字符
    // if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
    //   showErrMsg(context, '密码需要包含至少一个特殊字符如');
    //   return false;
    // }

    return true;
  }

  bool checkUser() {
    final username = userController.text;
    if (username.isEmpty) {
      showErrMsg(context, '用户名不能为空');
      return false;
    }
    if (username.length < 3) {
      showErrMsg(context, '用户名长度不能少于 3 个字符');
      return false;
    }

    if (username.length > 20) {
      showErrMsg(context, '用户名长度不能超过 20 个字符');
      return false;
    }

    // 允许字母、数字、下划线和点
    final allowedChars = RegExp(r'^[a-zA-Z0-9_.]+$');
    if (!allowedChars.hasMatch(username)) {
      showErrMsg(context, '用户名只能包含字母、数字、下划线和点');
      return false;
    }

    // 避免使用过于简单的数字组合
    final onlyNumbers = RegExp(r'^[0-9]+$');
    if (onlyNumbers.hasMatch(username) && username.length < 6) {
      showErrMsg(context, '不允许过于简单的纯数字用户名');
      return false;
    }

    // 避免常见的敏感词
    final forbiddenWords = [
      'admin',
      'test',
      'guest',
      'root',
      'administrator',
      'administrators',
      "superuser",
    ];
    if (forbiddenWords.contains(username.toLowerCase())) {
      showErrMsg(context, '该用户名已被禁用');
      return false;
    }
    return true;
  }

  bool checkEmail() {
    if (emailController.text.isEmpty) {
      showErrMsg(context, '邮箱不能为空');
      return false;
    }
    if (!RegExp(
      r'^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$',
    ).hasMatch(emailController.text)) {
      showErrMsg(context, '邮箱格式不正确');
      return false;
    }
    return true;
  }

  bool registerCheck() {
    if (!checkUser()) {
      return false;
    }
    if (!checkEmail()) {
      return false;
    }
    if (!checkRegisterPasswd()) {
      return false;
    }
    if (registerPasswordController.text != passwordAgainController.text) {
      showErrMsg(context, '密码不一致');
      return false;
    }
    return true;
  }

  // 用户注册
  void register() {
    final ok = registerCheck();
    if (!ok) {
      return;
    }

    final String user = userController.text;
    final String email = emailController.text;
    final String password = registerPasswordController.text;

    Http()
        .userRegister(
      RequestPostUserRegister(
        username: user,
        email: email,
        password: password,
      ),
    )
        .then((value) async {
          final registerUserId = value.id;
      if (value.isOK) {
        if (registerUserId.isEmpty) {
          if (mounted) {
            showErrMsg(context, '用户不存在');
          }
          return;
        }
        SP().setIsVisitor(false);
        SP().setUID(registerUserId);
        SP().setIsVisitorLogged(false);
        await Config().init(registerUserId);
        await Config.instance.setAPIs(value.apis);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
        }
      } else {
        if (mounted) {
          showErrMsg(context, value.msg);
        }
      }
    });
  }
}
