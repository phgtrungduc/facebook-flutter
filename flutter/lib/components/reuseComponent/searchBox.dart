import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

Container searchBox(
    {onTapFunction,
    onChangedFunction,
    onEditingCompleteFunction,
    onSubmittedFunction,
    autoFocus = false,
    hintText = 'Tìm kiếm',
    enabled = true,
    hasSuffix = false,
    onSuffixAction,
    editController}) {
  return Container(
    height: 38,
    decoration: BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.all(Radius.circular(20)),
        border: Border.all(color: Color(0xFFFFFFFF), width: 0.0)),
    child: TextField(
      controller: editController,
      enabled: enabled,
      autofocus: autoFocus,
      onTap: onTapFunction,
      onChanged: onChangedFunction,
      onEditingComplete: onEditingCompleteFunction,
      onSubmitted: onSubmittedFunction,
      style: TextStyle(
        fontSize: 16,
      ),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.only(top: 6),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFFFFFFF),
            width: 0.0,
          ),
          borderRadius: BorderRadius.all(Radius.circular(20)),
          gapPadding: 0,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 0.0,
            color: Color(0xFFFFFFFF),
          ),
          borderRadius: BorderRadius.all(Radius.circular(20)),
          gapPadding: 0,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: Color(0xFF757575),
        ),
        hintText: '$hintText',
        border: OutlineInputBorder(
          borderSide: BorderSide(width: 0.0),
          borderRadius: BorderRadius.all(Radius.circular(20)),
          gapPadding: 0,
        ),
        suffix: hasSuffix
            ? GestureDetector(
                onTap: onSuffixAction,
                child: Padding(
                  padding: const EdgeInsets.only(top: 2.0, right: 8.0),
                  child: Icon(
                    Icons.close,
                    size: 20,
                    color: Color(0xFF757575),
                  ),
                ),
              )
            : null,
      ),
    ),
  );
}
