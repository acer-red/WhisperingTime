import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whispering_time/utils/env.dart';
import 'package:whispering_time/utils/device.dart';
import 'package:whispering_time/services/http/self.dart';

class Edit extends StatefulWidget {
  const Edit({super.key});

  @override
  State<Edit> createState() => _EditState();
}

class _EditState extends State<Edit> {
  TextEditingController title = TextEditingController();
  TextEditingController desc = TextEditingController();
  List<String> images = [];
  FeedbackType feedbackType = FeedbackType.optFeature;

  bool isUploadDeviceInfo = true;
  bool isPublic = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("提交反馈"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              typeDropwown(),
              SizedBox(height: 16),
              titleEdit(),
              SizedBox(height: 16),
              descEdit(),
              SizedBox(height: 16),
              imageButton(),
              SizedBox(height: 16),
              moreCheckbox(),
              SizedBox(height: 16),
              submitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // 标题栏编辑框
  Widget titleEdit() {
    return TextFormField(
      controller: title,
      decoration: InputDecoration(
        labelText: '标题',
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  // 反馈类型选择下拉框
  Widget typeDropwown() {
    return DropdownButtonFormField<FeedbackType>(
      decoration: InputDecoration(
        labelText: '选择类型',
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: [
        DropdownMenuItem<FeedbackType>(
          value: FeedbackType.optFeature,
          child: Text("优化功能"),
        ),
        DropdownMenuItem<FeedbackType>(
          value: FeedbackType.bug,
          child: Text('问题缺陷'),
        ),
        DropdownMenuItem<FeedbackType>(
          value: FeedbackType.newFeature,
          child: Text('新增功能'),
        ),
        DropdownMenuItem<FeedbackType>(
          value: FeedbackType.other,
          child: Text('其他'),
        ),
      ],
      onChanged: (FeedbackType? newValue) {
        setState(() {
          feedbackType = newValue!;
        });
        // Handle dropdown value change
      },
      value: feedbackType,
    );
  }

  // 详细描述编辑框
  Widget descEdit() {
    return // 具体表述编辑框
        TextFormField(
      controller: desc,
      decoration: InputDecoration(
        labelText: '请详细描述您的问题和建议',
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      maxLines: 4, // Allows multiline input
    );
  }

// 图片上传区域
  Widget imageButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: GestureDetector(
            onTap: () {
              images.length > index ? screenImage(index) : getLocalimage(index);
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: images.length > index
                    ? null
                    : Border.all(
                        color: Colors.grey.shade400,
                        width: 1,
                      ),
                borderRadius: BorderRadius.circular(8),
                shape: BoxShape.rectangle,
              ),
              child: images.length > index
                  ? Image.file(
                      File(images[index]),
                      fit: BoxFit.cover,
                    )
                  : Center(
                      child: Icon(
                        Icons.add,
                        size: 20,
                        color: Colors.grey.shade600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  void getLocalimage(int index) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }
    setState(() {
      images.add(image.path);
    });
  }

  void screenImage(int index) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Stack(
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.file(
                    File(images[index]),
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    icon: Icon(Icons.delete),
                    label: Text('删除'),
                    onPressed: () {
                      setState(() {
                        images.removeAt(index);
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 其他多选框 (上传用户信息)
  Widget moreCheckbox() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              Checkbox(
                value: isUploadDeviceInfo,
                onChanged: (bool? value) {
                  setState(() {
                    isUploadDeviceInfo = value!;
                  });
                },
              ),
              Text('上传设备信息'),
            ],
          ),
        ),
         SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              Checkbox(
                value: isPublic,
                onChanged: (bool? value) {
                  setState(() {
                    isPublic = value!;
                  });
                },
              ),
              Text('公开'),
            ],
          ),
        ),
      ],
    );
  }

  // 提交按钮
  Widget submitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12),
      ),
      onPressed: () => submit(),
      child: Text('提交'),
    );
  }

  void check() {
    if (title.text.isEmpty) {
      msg('标题不能为空');
    } else if (desc.text.isEmpty) {
      msg('请添加描述');
    } else if (title.text.length > 30) {
      msg('标题不能超过30个字');
    }
  }

  void submit() async {
    check();
    RequestPostFeedback req = RequestPostFeedback(
        fbType: feedbackType,
        title: title.text,
        content: desc.text,
        isPublic: isPublic,
        );
    if (isUploadDeviceInfo) {
      req.deviceFilePath = await Device().write();
    }
    if (images.isNotEmpty) {
      req.images = images;
    }
    Http().postFeedback(req).then((value) {
      if (value.isNotOK) {
        msg('提交失败');
      } else {
        msg('提交成功');
        // if (mounted) {
        //   Navigator.pop(context);
        // }
      }
    });
  }

  msg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Text(msg),
          ],
        ),
        duration: Duration(seconds: 2),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
