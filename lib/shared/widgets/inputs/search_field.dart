import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class SearchField extends StatefulWidget {
  final String? hint;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;
  final FocusNode? focusNode;

  const SearchField({
    super.key,
    this.hint = 'Pesquisar...',
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
    this.focusNode,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChange);
    _hasText = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  void _onTextChange() {
    setState(() => _hasText = _controller.text.isNotEmpty);
  }

  void _clearText() {
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: AppDecorations.borderRadiusFull,
        border: Border.all(
          color: _isFocused ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textPrimary,
        ),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textMuted,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: _isFocused ? AppColors.primary : AppColors.textMuted,
            size: 20,
          ),
          suffixIcon: _hasText
              ? IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  onPressed: _clearText,
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
