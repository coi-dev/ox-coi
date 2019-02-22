import 'package:flutter/material.dart';
import 'package:ox_talk/source/widgets/avatar.dart';
import 'package:ox_talk/source/utils/dimensions.dart';

class AvatarListItem extends StatelessWidget {
  final String title;
  final String subTitle;
  final String imagePath;
  final Color color;
  final Function onTap;
  final Widget titleIcon;
  final Widget subTitleIcon;
  final IconData avatarIcon;

  AvatarListItem(
      {@required this.title, @required this.subTitle, @required this.onTap, this.avatarIcon, this.imagePath, this.color, this.titleIcon, this.subTitleIcon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(title, subTitle),
      child: Container(
        padding: const EdgeInsets.only(top: listItemPaddingSmall),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            avatarIcon == null ? Avatar(
              imagePath: imagePath,
              initials: getInitials(),
              color: color,
            ) :  CircleAvatar(
              radius: 24,
              foregroundColor: Colors.white,
              backgroundColor: Colors.grey,
              child: Icon(avatarIcon),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: listItemPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: titleIcon != null ? titleIcon : Container(),
                        ),
                        Expanded(child: getTitle()),
                      ],
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(
                      vertical: listItemPaddingSmall,
                    )),
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: subTitleIcon != null ? subTitleIcon : Container(),
                        ),
                        Expanded(child: getSubTitle()),
                      ],
                    ),
                    Divider(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  StatelessWidget getTitle() {
    return title != null
        ? Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0),
          )
        : Container();
  }

  StatelessWidget getSubTitle() {
    return subTitle != null
        ? Text(
            subTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black45),
          )
        : Container();
  }

  String getInitials() {
    if (title != null && title.isNotEmpty) {
      return title.substring(0, 1);
    }
    if (subTitle != null && subTitle.isNotEmpty) {
      return subTitle.substring(0, 1);
    }
    return "";
  }

}
