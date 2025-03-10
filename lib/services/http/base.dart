enum Method { get, post, put, delete }

enum LastPage {
  ok,
  err,
  delete,
  nochange,
  change,
  changeConfig,
  create,
  nocreate
}


class Basic {
  int err;
  String msg;
  Basic({required this.err, required this.msg});

  bool get isNotOK => err != 0;

  bool get isOK => err == 0;

  void getmsg() {
    print(msg);
  }
}
