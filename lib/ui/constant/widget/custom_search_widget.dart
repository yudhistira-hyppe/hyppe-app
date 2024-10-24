import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';

class CustomSearchWidget extends StatefulWidget {
  final double? width;
  final String? hintText;
  final ValueChanged<String>? onTyping;
  final ValueChanged<String>? onFieldSubmitted;
  final TextEditingController textEditingController;
  const CustomSearchWidget({
    Key? key,
    this.width,
    this.onTyping,
    this.hintText,
    required this.onFieldSubmitted,
    required this.textEditingController,
  }) : super(key: key);

  @override
  State<CustomSearchWidget> createState() => _CustomSearchWidgetState();
}

class _CustomSearchWidgetState extends State<CustomSearchWidget> {
  @override
  void initState() {
    widget.textEditingController.addListener(() {
      Future.delayed(Duration.zero, () {
        if (widget.textEditingController.value.text.isEmpty ||
            widget.textEditingController.value.text.length == 1) {
          setState(() {});
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    widget.textEditingController.removeListener(() => this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themes = Theme.of(context);

    return Container(
      height: 45,
      width: widget.width,
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(8.0),
      //   border: Border.all(
      //     width: 1.0,
      //     style: BorderStyle.solid,
      //   ),
      // ),
      margin: const EdgeInsets.only(top: 16),
      child: TextFormField(
        maxLines: 1,
        onChanged: widget.onTyping,
        controller: widget.textEditingController,
        style:
            themes.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        onFieldSubmitted: widget.textEditingController.text.isNotEmpty
            ? widget.onFieldSubmitted
            : null,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1.0,
            ),
          ),
          isDense: true,
          prefixIcon: const CustomIconWidget(
            iconData: '${AssetPath.vectorPath}search-nav.svg',
          ),
          hintText: widget.hintText ?? 'Search',
          hintStyle: themes.primaryTextTheme.bodyMedium,
        ),
      ),
    );
  }
}
