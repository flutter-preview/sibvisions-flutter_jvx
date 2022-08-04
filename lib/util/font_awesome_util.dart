import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'parse_util.dart';

abstract class FontAwesomeUtil {
  static bool checkFontAwesome(String pText) {
    return pText.contains('FontAwesome');
  }

  static FaIcon getFontAwesomeIcon({required String pText, double? pIconSize, Color? pColor}) {
    List<String> arr = pText.split(",");

    String iconName = arr[0];
    double? iconSize;

    if (iconName.contains(";")) {
      var nameAndSize = iconName.split(";");

      // Currently ignore "size=X" parameter;
      iconName = nameAndSize[0];
    }

    if (arr.length >= 2) {
      iconSize = double.parse(arr[1]);
    }

    Color iconColor = arr.length > 4 ? (ParseUtil.parseHexColor(arr[4]) ?? Colors.black) : Colors.black;

    if (pColor != null) {
      iconColor = pColor;
    }

    if (pIconSize != null) {
      iconSize = pIconSize;
    }

    IconData iconData = ICONS[iconName] ?? FontAwesomeIcons.circleQuestion;

    return FaIcon(
      iconData,
      size: iconSize,
      color: iconColor,
    );
  }

  static const Map<String, IconData> ICONS = {
    "FontAwesome.glass": FontAwesomeIcons.whiskeyGlass,
    "FontAwesome.music": FontAwesomeIcons.music,
    "FontAwesome.search": FontAwesomeIcons.magnifyingGlass,
    "FontAwesome.envelope-o": FontAwesomeIcons.solidEnvelope,
    "FontAwesome.heart": FontAwesomeIcons.heart,
    "FontAwesome.star": FontAwesomeIcons.star,
    "FontAwesome.star-o": FontAwesomeIcons.solidStar,
    "FontAwesome.user": FontAwesomeIcons.user,
    "FontAwesome.film": FontAwesomeIcons.film,
    "FontAwesome.th-large": FontAwesomeIcons.tableCellsLarge,
    "FontAwesome.th": FontAwesomeIcons.tableCells,
    "FontAwesome.th-list": FontAwesomeIcons.tableList,
    "FontAwesome.check": FontAwesomeIcons.check,
    "FontAwesome.remove": FontAwesomeIcons.trashCan,
    "FontAwesome.close": FontAwesomeIcons.xmark,
    "FontAwesome.times": FontAwesomeIcons.xmark,
    "FontAwesome.search-plus": FontAwesomeIcons.magnifyingGlassPlus,
    "FontAwesome.search-minus": FontAwesomeIcons.magnifyingGlassMinus,
    "FontAwesome.power-off": FontAwesomeIcons.powerOff,
    "FontAwesome.signal": FontAwesomeIcons.signal,
    "FontAwesome.gear": FontAwesomeIcons.gears,
    "FontAwesome.cog": FontAwesomeIcons.gear,
    "FontAwesome.trash-o": FontAwesomeIcons.solidTrashCan,
    "FontAwesome.home": FontAwesomeIcons.house,
    "FontAwesome.file-o": FontAwesomeIcons.solidFile,
    "FontAwesome.clock-o": FontAwesomeIcons.solidClock,
    "FontAwesome.road": FontAwesomeIcons.road,
    "FontAwesome.download": FontAwesomeIcons.download,
    "FontAwesome.arrow-circle-o-down": FontAwesomeIcons.solidCircleDown,
    "FontAwesome.arrow-circle-o-up": FontAwesomeIcons.solidCircleUp,
    "FontAwesome.inbox": FontAwesomeIcons.inbox,
    "FontAwesome.play-circle-o": FontAwesomeIcons.solidCirclePlay,
    "FontAwesome.rotate-right": FontAwesomeIcons.arrowsRotate,
    "FontAwesome.repeat": FontAwesomeIcons.rotateRight,
    "FontAwesome.refresh": FontAwesomeIcons.arrowRotateRight,
    "FontAwesome.list-alt": FontAwesomeIcons.rectangleList,
    "FontAwesome.lock": FontAwesomeIcons.lock,
    "FontAwesome.flag": FontAwesomeIcons.flag,
    "FontAwesome.headphones": FontAwesomeIcons.headphones,
    "FontAwesome.volume-off": FontAwesomeIcons.volumeOff,
    "FontAwesome.volume-down": FontAwesomeIcons.volumeLow,
    "FontAwesome.volume-up": FontAwesomeIcons.volumeHigh,
    "FontAwesome.qrcode": FontAwesomeIcons.qrcode,
    "FontAwesome.barcode": FontAwesomeIcons.barcode,
    "FontAwesome.tag": FontAwesomeIcons.tag,
    "FontAwesome.tags": FontAwesomeIcons.tags,
    "FontAwesome.book": FontAwesomeIcons.book,
    "FontAwesome.bookmark": FontAwesomeIcons.bookmark,
    "FontAwesome.print": FontAwesomeIcons.print,
    "FontAwesome.camera": FontAwesomeIcons.camera,
    "FontAwesome.font": FontAwesomeIcons.font,
    "FontAwesome.bold": FontAwesomeIcons.bold,
    "FontAwesome.italic": FontAwesomeIcons.italic,
    "FontAwesome.text-height": FontAwesomeIcons.textHeight,
    "FontAwesome.text-width": FontAwesomeIcons.textWidth,
    "FontAwesome.align-left": FontAwesomeIcons.alignLeft,
    "FontAwesome.align-center": FontAwesomeIcons.alignCenter,
    "FontAwesome.align-right": FontAwesomeIcons.alignRight,
    "FontAwesome.align-justify": FontAwesomeIcons.alignJustify,
    "FontAwesome.list": FontAwesomeIcons.list,
    "FontAwesome.dedent": FontAwesomeIcons.outdent,
    "FontAwesome.outdent": FontAwesomeIcons.outdent,
    "FontAwesome.indent": FontAwesomeIcons.indent,
    "FontAwesome.video-camera": FontAwesomeIcons.video,
    "FontAwesome.photo": FontAwesomeIcons.image,
    "FontAwesome.image": FontAwesomeIcons.image,
    "FontAwesome.picture-o": FontAwesomeIcons.solidImage,
    "FontAwesome.pencil": FontAwesomeIcons.pencil,
    "FontAwesome.map-marker": FontAwesomeIcons.locationPin,
    "FontAwesome.adjust": FontAwesomeIcons.circleHalfStroke,
    "FontAwesome.tint": FontAwesomeIcons.droplet,
    "FontAwesome.edit": FontAwesomeIcons.penToSquare,
    "FontAwesome.pencil-square-o": FontAwesomeIcons.squarePen,
    "FontAwesome.share-square-o": FontAwesomeIcons.solidShareFromSquare,
    "FontAwesome.check-square-o": FontAwesomeIcons.solidSquareCheck,
    "FontAwesome.arrows": FontAwesomeIcons.upDownLeftRight,
    "FontAwesome.step-backward": FontAwesomeIcons.backwardStep,
    "FontAwesome.fast-backward": FontAwesomeIcons.backwardFast,
    "FontAwesome.backward": FontAwesomeIcons.backward,
    "FontAwesome.play": FontAwesomeIcons.play,
    "FontAwesome.pause": FontAwesomeIcons.pause,
    "FontAwesome.stop": FontAwesomeIcons.stop,
    "FontAwesome.forward": FontAwesomeIcons.forward,
    "FontAwesome.fast-forward": FontAwesomeIcons.forwardFast,
    "FontAwesome.step-forward": FontAwesomeIcons.forwardStep,
    "FontAwesome.eject": FontAwesomeIcons.eject,
    "FontAwesome.chevron-left": FontAwesomeIcons.chevronLeft,
    "FontAwesome.chevron-right": FontAwesomeIcons.chevronRight,
    "FontAwesome.plus-circle": FontAwesomeIcons.circlePlus,
    "FontAwesome.minus-circle": FontAwesomeIcons.circleMinus,
    "FontAwesome.times-circle": FontAwesomeIcons.circleXmark,
    "FontAwesome.check-circle": FontAwesomeIcons.circleCheck,
    "FontAwesome.question-circle": FontAwesomeIcons.circleQuestion,
    "FontAwesome.info-circle": FontAwesomeIcons.circleInfo,
    "FontAwesome.crosshairs": FontAwesomeIcons.crosshairs,
    "FontAwesome.times-circle-o": FontAwesomeIcons.solidCircleXmark,
    "FontAwesome.check-circle-o": FontAwesomeIcons.solidCircleCheck,
    "FontAwesome.ban": FontAwesomeIcons.ban,
    "FontAwesome.arrow-left": FontAwesomeIcons.arrowLeft,
    "FontAwesome.arrow-right": FontAwesomeIcons.arrowRight,
    "FontAwesome.arrow-up": FontAwesomeIcons.arrowUp,
    "FontAwesome.arrow-down": FontAwesomeIcons.arrowDown,
    "FontAwesome.mail-forward": FontAwesomeIcons.share,
    "FontAwesome.share": FontAwesomeIcons.share,
    "FontAwesome.expand": FontAwesomeIcons.expand,
    "FontAwesome.compress": FontAwesomeIcons.compress,
    "FontAwesome.plus": FontAwesomeIcons.plus,
    "FontAwesome.minus": FontAwesomeIcons.minus,
    "FontAwesome.asterisk": FontAwesomeIcons.asterisk,
    "FontAwesome.exclamation-circle": FontAwesomeIcons.circleExclamation,
    "FontAwesome.gift": FontAwesomeIcons.gift,
    "FontAwesome.leaf": FontAwesomeIcons.leaf,
    "FontAwesome.fire": FontAwesomeIcons.fire,
    "FontAwesome.eye": FontAwesomeIcons.eye,
    "FontAwesome.eye-slash": FontAwesomeIcons.eyeSlash,
    "FontAwesome.warning": FontAwesomeIcons.exclamation,
    "FontAwesome.exclamation-triangle": FontAwesomeIcons.triangleExclamation,
    "FontAwesome.plane": FontAwesomeIcons.plane,
    "FontAwesome.calendar": FontAwesomeIcons.calendar,
    "FontAwesome.random": FontAwesomeIcons.shuffle,
    "FontAwesome.comment": FontAwesomeIcons.comment,
    "FontAwesome.magnet": FontAwesomeIcons.magnet,
    "FontAwesome.chevron-up": FontAwesomeIcons.chevronUp,
    "FontAwesome.chevron-down": FontAwesomeIcons.chevronDown,
    "FontAwesome.retweet": FontAwesomeIcons.retweet,
    "FontAwesome.shopping-cart": FontAwesomeIcons.cartShopping,
    "FontAwesome.folder": FontAwesomeIcons.folder,
    "FontAwesome.folder-open": FontAwesomeIcons.folderOpen,
    "FontAwesome.arrows-v": FontAwesomeIcons.upDown,
    "FontAwesome.arrows-h": FontAwesomeIcons.leftRight,
    "FontAwesome.bar-chart-o": FontAwesomeIcons.solidChartBar,
    "FontAwesome.bar-chart": FontAwesomeIcons.chartBar,
    "FontAwesome.twitter-square": FontAwesomeIcons.twitterSquare,
    "FontAwesome.facebook-square": FontAwesomeIcons.facebookSquare,
    "FontAwesome.camera-retro": FontAwesomeIcons.cameraRetro,
    "FontAwesome.key": FontAwesomeIcons.key,
    "FontAwesome.gears": FontAwesomeIcons.gears,
    "FontAwesome.cogs": FontAwesomeIcons.gears,
    "FontAwesome.comments": FontAwesomeIcons.comments,
    "FontAwesome.thumbs-o-up": FontAwesomeIcons.solidThumbsUp,
    "FontAwesome.thumbs-o-down": FontAwesomeIcons.solidThumbsDown,
    "FontAwesome.star-half": FontAwesomeIcons.starHalf,
    "FontAwesome.heart-o": FontAwesomeIcons.solidHeart,
    "FontAwesome.sign-out": FontAwesomeIcons.rightFromBracket,
    "FontAwesome.linkedin-square": FontAwesomeIcons.linkedin,
    "FontAwesome.thumb-tack": FontAwesomeIcons.thumbtack,
    "FontAwesome.external-link": FontAwesomeIcons.upRightFromSquare,
    "FontAwesome.sign-in": FontAwesomeIcons.rightToBracket,
    "FontAwesome.trophy": FontAwesomeIcons.trophy,
    "FontAwesome.github-square": FontAwesomeIcons.githubSquare,
    "FontAwesome.upload": FontAwesomeIcons.upload,
    "FontAwesome.lemon-o": FontAwesomeIcons.solidLemon,
    "FontAwesome.phone": FontAwesomeIcons.phone,
    "FontAwesome.square-o": FontAwesomeIcons.solidSquare,
    "FontAwesome.bookmark-o": FontAwesomeIcons.solidBookmark,
    "FontAwesome.phone-square": FontAwesomeIcons.squarePhone,
    "FontAwesome.twitter": FontAwesomeIcons.twitter,
    "FontAwesome.facebook-f": FontAwesomeIcons.facebookF,
    "FontAwesome.facebook": FontAwesomeIcons.facebook,
    "FontAwesome.github": FontAwesomeIcons.github,
    "FontAwesome.unlock": FontAwesomeIcons.unlock,
    "FontAwesome.credit-card": FontAwesomeIcons.creditCard,
    "FontAwesome.feed": FontAwesomeIcons.rss,
    "FontAwesome.rss": FontAwesomeIcons.rss,
    "FontAwesome.hdd-o": FontAwesomeIcons.solidHardDrive,
    "FontAwesome.bullhorn": FontAwesomeIcons.bullhorn,
    "FontAwesome.bell": FontAwesomeIcons.bell,
    "FontAwesome.certificate": FontAwesomeIcons.certificate,
    "FontAwesome.hand-o-right": FontAwesomeIcons.solidHandPointRight,
    "FontAwesome.hand-o-left": FontAwesomeIcons.solidHandPointLeft,
    "FontAwesome.hand-o-up": FontAwesomeIcons.solidHandPointUp,
    "FontAwesome.hand-o-down": FontAwesomeIcons.solidHandPointDown,
    "FontAwesome.arrow-circle-left": FontAwesomeIcons.circleArrowLeft,
    "FontAwesome.arrow-circle-right": FontAwesomeIcons.circleArrowRight,
    "FontAwesome.arrow-circle-up": FontAwesomeIcons.circleArrowUp,
    "FontAwesome.arrow-circle-down": FontAwesomeIcons.circleArrowDown,
    "FontAwesome.globe": FontAwesomeIcons.globe,
    "FontAwesome.wrench": FontAwesomeIcons.wrench,
    "FontAwesome.tasks": FontAwesomeIcons.listCheck,
    "FontAwesome.filter": FontAwesomeIcons.filter,
    "FontAwesome.briefcase": FontAwesomeIcons.briefcase,
    "FontAwesome.arrows-alt": FontAwesomeIcons.upDownLeftRight,
    "FontAwesome.group": FontAwesomeIcons.users,
    "FontAwesome.users": FontAwesomeIcons.users,
    "FontAwesome.chain": FontAwesomeIcons.link,
    "FontAwesome.link": FontAwesomeIcons.link,
    "FontAwesome.cloud": FontAwesomeIcons.cloud,
    "FontAwesome.flask": FontAwesomeIcons.flask,
    "FontAwesome.cut": FontAwesomeIcons.scissors,
    "FontAwesome.scissors": FontAwesomeIcons.scissors,
    "FontAwesome.copy": FontAwesomeIcons.copy,
    "FontAwesome.files-o": FontAwesomeIcons.solidFile,
    "FontAwesome.paperclip": FontAwesomeIcons.paperclip,
    "FontAwesome.save": FontAwesomeIcons.floppyDisk,
    "FontAwesome.floppy-o": FontAwesomeIcons.floppyDisk,
    "FontAwesome.square": FontAwesomeIcons.square,
    "FontAwesome.navicon": FontAwesomeIcons.bars,
    "FontAwesome.reorder": FontAwesomeIcons.bars,
    "FontAwesome.bars": FontAwesomeIcons.bars,
    "FontAwesome.list-ul": FontAwesomeIcons.listUl,
    "FontAwesome.list-ol": FontAwesomeIcons.listOl,
    "FontAwesome.strikethrough": FontAwesomeIcons.strikethrough,
    "FontAwesome.underline": FontAwesomeIcons.underline,
    "FontAwesome.table": FontAwesomeIcons.table,
    "FontAwesome.magic": FontAwesomeIcons.wandMagic,
    "FontAwesome.truck": FontAwesomeIcons.truck,
    "FontAwesome.pinterest": FontAwesomeIcons.pinterest,
    "FontAwesome.pinterest-square": FontAwesomeIcons.pinterestSquare,
    "FontAwesome.google-plus-square": FontAwesomeIcons.googlePlusSquare,
    "FontAwesome.google-plus": FontAwesomeIcons.googlePlus,
    "FontAwesome.money": FontAwesomeIcons.moneyBill,
    "FontAwesome.caret-down": FontAwesomeIcons.caretDown,
    "FontAwesome.caret-up": FontAwesomeIcons.caretUp,
    "FontAwesome.caret-left": FontAwesomeIcons.caretLeft,
    "FontAwesome.caret-right": FontAwesomeIcons.caretRight,
    "FontAwesome.columns": FontAwesomeIcons.tableColumns,
    "FontAwesome.unsorted": FontAwesomeIcons.sort,
    "FontAwesome.sort": FontAwesomeIcons.sort,
    "FontAwesome.sort-down": FontAwesomeIcons.sortDown,
    "FontAwesome.sort-desc": FontAwesomeIcons.arrowDown19,
    "FontAwesome.sort-up": FontAwesomeIcons.sortUp,
    "FontAwesome.sort-asc": FontAwesomeIcons.arrowUp19,
    "FontAwesome.envelope": FontAwesomeIcons.envelope,
    "FontAwesome.linkedin": FontAwesomeIcons.linkedin,
    "FontAwesome.rotate-left": FontAwesomeIcons.arrowRotateLeft,
    "FontAwesome.undo": FontAwesomeIcons.arrowRotateLeft,
    "FontAwesome.legal": FontAwesomeIcons.gavel,
    "FontAwesome.gavel": FontAwesomeIcons.gavel,
    "FontAwesome.dashboard": FontAwesomeIcons.gaugeHigh,
    "FontAwesome.tachometer": FontAwesomeIcons.gaugeHigh,
    "FontAwesome.comment-o": FontAwesomeIcons.solidComment,
    "FontAwesome.comments-o": FontAwesomeIcons.solidComments,
    "FontAwesome.flash": FontAwesomeIcons.bolt,
    "FontAwesome.bolt": FontAwesomeIcons.bolt,
    "FontAwesome.sitemap": FontAwesomeIcons.sitemap,
    "FontAwesome.umbrella": FontAwesomeIcons.umbrella,
    "FontAwesome.paste": FontAwesomeIcons.paste,
    "FontAwesome.clipboard": FontAwesomeIcons.clipboard,
    "FontAwesome.lightbulb-o": FontAwesomeIcons.solidLightbulb,
    "FontAwesome.exchange": FontAwesomeIcons.rightLeft,
    "FontAwesome.cloud-download": FontAwesomeIcons.cloudArrowDown,
    "FontAwesome.cloud-upload": FontAwesomeIcons.cloudArrowUp,
    "FontAwesome.user-md": FontAwesomeIcons.userDoctor,
    "FontAwesome.stethoscope": FontAwesomeIcons.stethoscope,
    "FontAwesome.suitcase": FontAwesomeIcons.suitcase,
    "FontAwesome.bell-o": FontAwesomeIcons.solidBell,
    "FontAwesome.coffee": FontAwesomeIcons.mugSaucer,
    "FontAwesome.cutlery": FontAwesomeIcons.utensils,
    "FontAwesome.file-text-o": FontAwesomeIcons.solidFileLines,
    "FontAwesome.building-o": FontAwesomeIcons.solidBuilding,
    "FontAwesome.hospital-o": FontAwesomeIcons.solidHospital,
    "FontAwesome.ambulance": FontAwesomeIcons.truckMedical,
    "FontAwesome.medkit": FontAwesomeIcons.suitcaseMedical,
    "FontAwesome.fighter-jet": FontAwesomeIcons.jetFighter,
    "FontAwesome.beer": FontAwesomeIcons.beerMugEmpty,
    "FontAwesome.h-square": FontAwesomeIcons.squareH,
    "FontAwesome.plus-square": FontAwesomeIcons.squarePlus,
    "FontAwesome.angle-double-left": FontAwesomeIcons.anglesLeft,
    "FontAwesome.angle-double-right": FontAwesomeIcons.anglesRight,
    "FontAwesome.angle-double-up": FontAwesomeIcons.anglesUp,
    "FontAwesome.angle-double-down": FontAwesomeIcons.anglesDown,
    "FontAwesome.angle-left": FontAwesomeIcons.angleLeft,
    "FontAwesome.angle-right": FontAwesomeIcons.angleRight,
    "FontAwesome.angle-up": FontAwesomeIcons.angleUp,
    "FontAwesome.angle-down": FontAwesomeIcons.angleDown,
    "FontAwesome.desktop": FontAwesomeIcons.desktop,
    "FontAwesome.laptop": FontAwesomeIcons.laptop,
    "FontAwesome.tablet": FontAwesomeIcons.tablet,
    "FontAwesome.mobile-phone": FontAwesomeIcons.mobileScreenButton,
    "FontAwesome.mobile": FontAwesomeIcons.mobile,
    "FontAwesome.circle-o": FontAwesomeIcons.solidCircle,
    "FontAwesome.quote-left": FontAwesomeIcons.quoteLeft,
    "FontAwesome.quote-right": FontAwesomeIcons.quoteRight,
    "FontAwesome.spinner": FontAwesomeIcons.spinner,
    "FontAwesome.circle": FontAwesomeIcons.circle,
    "FontAwesome.mail-reply": FontAwesomeIcons.reply,
    "FontAwesome.reply": FontAwesomeIcons.reply,
    "FontAwesome.github-alt": FontAwesomeIcons.githubAlt,
    "FontAwesome.folder-o": FontAwesomeIcons.solidFolder,
    "FontAwesome.folder-open-o": FontAwesomeIcons.solidFolderOpen,
    "FontAwesome.smile-o": FontAwesomeIcons.solidFaceSmile,
    "FontAwesome.frown-o": FontAwesomeIcons.solidFaceFrown,
    "FontAwesome.meh-o": FontAwesomeIcons.solidFaceMeh,
    "FontAwesome.gamepad": FontAwesomeIcons.gamepad,
    "FontAwesome.keyboard-o": FontAwesomeIcons.solidKeyboard,
    "FontAwesome.flag-o": FontAwesomeIcons.solidFlag,
    "FontAwesome.flag-checkered": FontAwesomeIcons.flagCheckered,
    "FontAwesome.terminal": FontAwesomeIcons.terminal,
    "FontAwesome.code": FontAwesomeIcons.code,
    "FontAwesome.mail-reply-all": FontAwesomeIcons.replyAll,
    "FontAwesome.reply-all": FontAwesomeIcons.replyAll,
    "FontAwesome.star-half-empty": FontAwesomeIcons.starHalfStroke,
    "FontAwesome.star-half-full": FontAwesomeIcons.starHalfStroke,
    "FontAwesome.star-half-o": FontAwesomeIcons.solidStarHalf,
    "FontAwesome.location-arrow": FontAwesomeIcons.locationArrow,
    "FontAwesome.crop": FontAwesomeIcons.crop,
    "FontAwesome.code-fork": FontAwesomeIcons.codeBranch,
    "FontAwesome.unlink": FontAwesomeIcons.linkSlash,
    "FontAwesome.chain-broken": FontAwesomeIcons.linkSlash,
    "FontAwesome.question": FontAwesomeIcons.question,
    "FontAwesome.info": FontAwesomeIcons.info,
    "FontAwesome.exclamation": FontAwesomeIcons.exclamation,
    "FontAwesome.superscript": FontAwesomeIcons.superscript,
    "FontAwesome.subscript": FontAwesomeIcons.subscript,
    "FontAwesome.eraser": FontAwesomeIcons.eraser,
    "FontAwesome.puzzle-piece": FontAwesomeIcons.puzzlePiece,
    "FontAwesome.microphone": FontAwesomeIcons.microphone,
    "FontAwesome.microphone-slash": FontAwesomeIcons.microphoneSlash,
    "FontAwesome.shield": FontAwesomeIcons.shieldHalved,
    "FontAwesome.calendar-o": FontAwesomeIcons.solidCalendar,
    "FontAwesome.fire-extinguisher": FontAwesomeIcons.fireExtinguisher,
    "FontAwesome.rocket": FontAwesomeIcons.rocket,
    "FontAwesome.maxcdn": FontAwesomeIcons.maxcdn,
    "FontAwesome.chevron-circle-left": FontAwesomeIcons.circleChevronLeft,
    "FontAwesome.chevron-circle-right": FontAwesomeIcons.circleChevronRight,
    "FontAwesome.chevron-circle-up": FontAwesomeIcons.circleChevronUp,
    "FontAwesome.chevron-circle-down": FontAwesomeIcons.circleChevronDown,
    "FontAwesome.html5": FontAwesomeIcons.html5,
    "FontAwesome.css3": FontAwesomeIcons.css3,
    "FontAwesome.anchor": FontAwesomeIcons.anchor,
    "FontAwesome.unlock-alt": FontAwesomeIcons.unlockKeyhole,
    "FontAwesome.bullseye": FontAwesomeIcons.bullseye,
    "FontAwesome.ellipsis-h": FontAwesomeIcons.ellipsis,
    "FontAwesome.ellipsis-v": FontAwesomeIcons.ellipsisVertical,
    "FontAwesome.rss-square": FontAwesomeIcons.squareRss,
    "FontAwesome.play-circle": FontAwesomeIcons.circlePlay,
    "FontAwesome.ticket": FontAwesomeIcons.ticketSimple,
    "FontAwesome.minus-square": FontAwesomeIcons.squareMinus,
    "FontAwesome.minus-square-o": FontAwesomeIcons.solidSquareMinus,
    "FontAwesome.level-up": FontAwesomeIcons.turnUp,
    "FontAwesome.level-down": FontAwesomeIcons.turnDown,
    "FontAwesome.check-square": FontAwesomeIcons.squareCheck,
    "FontAwesome.pencil-square": FontAwesomeIcons.squarePen,
    "FontAwesome.external-link-square": FontAwesomeIcons.squareUpRight,
    "FontAwesome.share-square": FontAwesomeIcons.shareFromSquare,
    "FontAwesome.compass": FontAwesomeIcons.compass,
    "FontAwesome.caret-square-o-down": FontAwesomeIcons.solidSquareCaretDown,
    "FontAwesome.caret-square-o-up": FontAwesomeIcons.solidSquareCaretUp,
    "FontAwesome.caret-square-o-right": FontAwesomeIcons.solidSquareCaretRight,
    "FontAwesome.euro": FontAwesomeIcons.euroSign,
    "FontAwesome.gbp": FontAwesomeIcons.sterlingSign,
    "FontAwesome.dollar": FontAwesomeIcons.dollarSign,
    "FontAwesome.usd": FontAwesomeIcons.dollarSign,
    "FontAwesome.rupee": FontAwesomeIcons.rupeeSign,
    "FontAwesome.inr": FontAwesomeIcons.rupeeSign,
    "FontAwesome.cny": FontAwesomeIcons.yenSign,
    "FontAwesome.rmb": FontAwesomeIcons.yenSign,
    "FontAwesome.yen": FontAwesomeIcons.yenSign,
    "FontAwesome.jpy": FontAwesomeIcons.yenSign,
    "FontAwesome.ruble": FontAwesomeIcons.rubleSign,
    "FontAwesome.rouble": FontAwesomeIcons.rubleSign,
    "FontAwesome.rub": FontAwesomeIcons.rubleSign,
    "FontAwesome.won": FontAwesomeIcons.wonSign,
    "FontAwesome.krw": FontAwesomeIcons.wonSign,
    "FontAwesome.bitcoin": FontAwesomeIcons.bitcoin,
    "FontAwesome.btc": FontAwesomeIcons.btc,
    "FontAwesome.file": FontAwesomeIcons.file,
    "FontAwesome.file-text": FontAwesomeIcons.fileLines,
    "FontAwesome.sort-alpha-asc": FontAwesomeIcons.arrowDownAZ,
    "FontAwesome.sort-alpha-desc": FontAwesomeIcons.arrowUpAZ,
    "FontAwesome.sort-amount-asc": FontAwesomeIcons.arrowDownWideShort,
    "FontAwesome.sort-amount-desc": FontAwesomeIcons.arrowUpWideShort,
    "FontAwesome.sort-numeric-asc": FontAwesomeIcons.arrowDown19,
    "FontAwesome.sort-numeric-desc": FontAwesomeIcons.arrowUp19,
    "FontAwesome.thumbs-up": FontAwesomeIcons.thumbsUp,
    "FontAwesome.thumbs-down": FontAwesomeIcons.thumbsDown,
    "FontAwesome.youtube-square": FontAwesomeIcons.youtubeSquare,
    "FontAwesome.youtube": FontAwesomeIcons.youtube,
    "FontAwesome.xing": FontAwesomeIcons.xing,
    "FontAwesome.xing-square": FontAwesomeIcons.xingSquare,
    "FontAwesome.youtube-play": FontAwesomeIcons.youtube,
    "FontAwesome.dropbox": FontAwesomeIcons.dropbox,
    "FontAwesome.stack-overflow": FontAwesomeIcons.stackOverflow,
    "FontAwesome.instagram": FontAwesomeIcons.instagram,
    "FontAwesome.flickr": FontAwesomeIcons.flickr,
    "FontAwesome.adn": FontAwesomeIcons.adn,
    "FontAwesome.bitbucket": FontAwesomeIcons.bitbucket,
    "FontAwesome.bitbucket-square": FontAwesomeIcons.bitbucket,
    "FontAwesome.tumblr": FontAwesomeIcons.tumblr,
    "FontAwesome.tumblr-square": FontAwesomeIcons.tumblrSquare,
    "FontAwesome.long-arrow-down": FontAwesomeIcons.downLong,
    "FontAwesome.long-arrow-up": FontAwesomeIcons.upLong,
    "FontAwesome.long-arrow-left": FontAwesomeIcons.leftLong,
    "FontAwesome.long-arrow-right": FontAwesomeIcons.rightLong,
    "FontAwesome.apple": FontAwesomeIcons.apple,
    "FontAwesome.windows": FontAwesomeIcons.windows,
    "FontAwesome.android": FontAwesomeIcons.android,
    "FontAwesome.linux": FontAwesomeIcons.linux,
    "FontAwesome.dribbble": FontAwesomeIcons.dribbble,
    "FontAwesome.skype": FontAwesomeIcons.skype,
    "FontAwesome.foursquare": FontAwesomeIcons.foursquare,
    "FontAwesome.trello": FontAwesomeIcons.trello,
    "FontAwesome.female": FontAwesomeIcons.personDress,
    "FontAwesome.male": FontAwesomeIcons.person,
    "FontAwesome.gittip": FontAwesomeIcons.gratipay,
    "FontAwesome.gratipay": FontAwesomeIcons.gratipay,
    "FontAwesome.sun-o": FontAwesomeIcons.solidSun,
    "FontAwesome.moon-o": FontAwesomeIcons.solidMoon,
    "FontAwesome.archive": FontAwesomeIcons.boxArchive,
    "FontAwesome.bug": FontAwesomeIcons.bug,
    "FontAwesome.vk": FontAwesomeIcons.vk,
    "FontAwesome.weibo": FontAwesomeIcons.weibo,
    "FontAwesome.renren": FontAwesomeIcons.renren,
    "FontAwesome.pagelines": FontAwesomeIcons.pagelines,
    "FontAwesome.stack-exchange": FontAwesomeIcons.stackExchange,
    "FontAwesome.arrow-circle-o-right": FontAwesomeIcons.solidCircleRight,
    "FontAwesome.arrow-circle-o-left": FontAwesomeIcons.solidCircleLeft,
    "FontAwesome.caret-square-o-left": FontAwesomeIcons.solidSquareCaretLeft,
    "FontAwesome.dot-circle-o": FontAwesomeIcons.solidCircleDot,
    "FontAwesome.wheelchair": FontAwesomeIcons.wheelchair,
    "FontAwesome.vimeo-square": FontAwesomeIcons.vimeoSquare,
    "FontAwesome.turkish-lira": FontAwesomeIcons.liraSign,
    "FontAwesome.try": FontAwesomeIcons.liraSign,
    "FontAwesome.plus-square-o": FontAwesomeIcons.solidSquarePlus,
    "FontAwesome.space-shuttle": FontAwesomeIcons.shuttleSpace,
    "FontAwesome.slack": FontAwesomeIcons.slack,
    "FontAwesome.envelope-square": FontAwesomeIcons.squareEnvelope,
    "FontAwesome.wordpress": FontAwesomeIcons.wordpress,
    "FontAwesome.openid": FontAwesomeIcons.openid,
    "FontAwesome.institution": FontAwesomeIcons.buildingColumns,
    "FontAwesome.bank": FontAwesomeIcons.buildingColumns,
    "FontAwesome.university": FontAwesomeIcons.buildingColumns,
    "FontAwesome.mortar-board": FontAwesomeIcons.graduationCap,
    "FontAwesome.graduation-cap": FontAwesomeIcons.graduationCap,
    "FontAwesome.yahoo": FontAwesomeIcons.yahoo,
    "FontAwesome.google": FontAwesomeIcons.google,
    "FontAwesome.reddit": FontAwesomeIcons.reddit,
    "FontAwesome.reddit-square": FontAwesomeIcons.redditSquare,
    "FontAwesome.stumbleupon-circle": FontAwesomeIcons.stumbleuponCircle,
    "FontAwesome.stumbleupon": FontAwesomeIcons.stumbleupon,
    "FontAwesome.delicious": FontAwesomeIcons.delicious,
    "FontAwesome.digg": FontAwesomeIcons.digg,
    "FontAwesome.pied-piper": FontAwesomeIcons.piedPiper,
    "FontAwesome.pied-piper-alt": FontAwesomeIcons.piedPiperAlt,
    "FontAwesome.drupal": FontAwesomeIcons.drupal,
    "FontAwesome.joomla": FontAwesomeIcons.joomla,
    "FontAwesome.language": FontAwesomeIcons.language,
    "FontAwesome.fax": FontAwesomeIcons.fax,
    "FontAwesome.building": FontAwesomeIcons.building,
    "FontAwesome.child": FontAwesomeIcons.child,
    "FontAwesome.paw": FontAwesomeIcons.paw,
    "FontAwesome.spoon": FontAwesomeIcons.spoon,
    "FontAwesome.cube": FontAwesomeIcons.cube,
    "FontAwesome.cubes": FontAwesomeIcons.cubes,
    "FontAwesome.behance": FontAwesomeIcons.behance,
    "FontAwesome.behance-square": FontAwesomeIcons.behanceSquare,
    "FontAwesome.steam": FontAwesomeIcons.steam,
    "FontAwesome.steam-square": FontAwesomeIcons.steamSquare,
    "FontAwesome.recycle": FontAwesomeIcons.recycle,
    "FontAwesome.automobile": FontAwesomeIcons.car,
    "FontAwesome.car": FontAwesomeIcons.car,
    "FontAwesome.cab": FontAwesomeIcons.taxi,
    "FontAwesome.taxi": FontAwesomeIcons.taxi,
    "FontAwesome.tree": FontAwesomeIcons.tree,
    "FontAwesome.spotify": FontAwesomeIcons.spotify,
    "FontAwesome.deviantart": FontAwesomeIcons.deviantart,
    "FontAwesome.soundcloud": FontAwesomeIcons.soundcloud,
    "FontAwesome.database": FontAwesomeIcons.database,
    "FontAwesome.file-pdf-o": FontAwesomeIcons.solidFilePdf,
    "FontAwesome.file-word-o": FontAwesomeIcons.solidFileWord,
    "FontAwesome.file-excel-o": FontAwesomeIcons.solidFileExcel,
    "FontAwesome.file-powerpoint-o": FontAwesomeIcons.solidFilePowerpoint,
    "FontAwesome.file-photo-o": FontAwesomeIcons.solidFileImage,
    "FontAwesome.file-picture-o": FontAwesomeIcons.solidFileImage,
    "FontAwesome.file-image-o": FontAwesomeIcons.solidFileImage,
    "FontAwesome.file-zip-o": FontAwesomeIcons.fileZipper,
    "FontAwesome.file-archive-o": FontAwesomeIcons.solidFileZipper,
    "FontAwesome.file-sound-o": FontAwesomeIcons.solidFileAudio,
    "FontAwesome.file-audio-o": FontAwesomeIcons.solidFileAudio,
    "FontAwesome.file-movie-o": FontAwesomeIcons.solidFileVideo,
    "FontAwesome.file-video-o": FontAwesomeIcons.solidFileVideo,
    "FontAwesome.file-code-o": FontAwesomeIcons.solidFileCode,
    "FontAwesome.vine": FontAwesomeIcons.vine,
    "FontAwesome.codepen": FontAwesomeIcons.codepen,
    "FontAwesome.jsfiddle": FontAwesomeIcons.jsfiddle,
    "FontAwesome.life-bouy": FontAwesomeIcons.lifeRing,
    "FontAwesome.life-buoy": FontAwesomeIcons.lifeRing,
    "FontAwesome.life-saver": FontAwesomeIcons.lifeRing,
    "FontAwesome.support": FontAwesomeIcons.squarePhone,
    "FontAwesome.life-ring": FontAwesomeIcons.lifeRing,
    "FontAwesome.circle-o-notch": FontAwesomeIcons.circleNotch,
    "FontAwesome.ra": FontAwesomeIcons.rebel,
    "FontAwesome.rebel": FontAwesomeIcons.rebel,
    "FontAwesome.ge": FontAwesomeIcons.empire,
    "FontAwesome.empire": FontAwesomeIcons.empire,
    "FontAwesome.git-square": FontAwesomeIcons.gitSquare,
    "FontAwesome.git": FontAwesomeIcons.git,
    "FontAwesome.y-combinator-square": FontAwesomeIcons.yCombinator,
    "FontAwesome.yc-square": FontAwesomeIcons.hackerNewsSquare,
    "FontAwesome.hacker-news": FontAwesomeIcons.hackerNews,
    "FontAwesome.tencent-weibo": FontAwesomeIcons.tencentWeibo,
    "FontAwesome.qq": FontAwesomeIcons.qq,
    "FontAwesome.wechat": FontAwesomeIcons.weixin,
    "FontAwesome.weixin": FontAwesomeIcons.weixin,
    "FontAwesome.send": FontAwesomeIcons.solidShareFromSquare,
    "FontAwesome.paper-plane": FontAwesomeIcons.paperPlane,
    "FontAwesome.send-o": FontAwesomeIcons.shareFromSquare,
    "FontAwesome.paper-plane-o": FontAwesomeIcons.solidPaperPlane,
    "FontAwesome.history": FontAwesomeIcons.clockRotateLeft,
    "FontAwesome.circle-thin": FontAwesomeIcons.circle,
    "FontAwesome.header": FontAwesomeIcons.heading,
    "FontAwesome.paragraph": FontAwesomeIcons.paragraph,
    "FontAwesome.sliders": FontAwesomeIcons.sliders,
    "FontAwesome.share-alt": FontAwesomeIcons.shareNodes,
    "FontAwesome.share-alt-square": FontAwesomeIcons.squareShareNodes,
    "FontAwesome.bomb": FontAwesomeIcons.bomb,
    "FontAwesome.soccer-ball-o": FontAwesomeIcons.solidFutbol,
    "FontAwesome.futbol-o": FontAwesomeIcons.solidFutbol,
    "FontAwesome.tty": FontAwesomeIcons.tty,
    "FontAwesome.binoculars": FontAwesomeIcons.binoculars,
    "FontAwesome.plug": FontAwesomeIcons.plug,
    "FontAwesome.slideshare": FontAwesomeIcons.slideshare,
    "FontAwesome.twitch": FontAwesomeIcons.twitch,
    "FontAwesome.yelp": FontAwesomeIcons.yelp,
    "FontAwesome.newspaper-o": FontAwesomeIcons.solidNewspaper,
    "FontAwesome.wifi": FontAwesomeIcons.wifi,
    "FontAwesome.calculator": FontAwesomeIcons.calculator,
    "FontAwesome.paypal": FontAwesomeIcons.paypal,
    "FontAwesome.google-wallet": FontAwesomeIcons.googleWallet,
    "FontAwesome.cc-visa": FontAwesomeIcons.ccVisa,
    "FontAwesome.cc-mastercard": FontAwesomeIcons.ccMastercard,
    "FontAwesome.cc-discover": FontAwesomeIcons.ccDiscover,
    "FontAwesome.cc-amex": FontAwesomeIcons.ccAmex,
    "FontAwesome.cc-paypal": FontAwesomeIcons.ccPaypal,
    "FontAwesome.cc-stripe": FontAwesomeIcons.ccStripe,
    "FontAwesome.bell-slash": FontAwesomeIcons.bellSlash,
    "FontAwesome.bell-slash-o": FontAwesomeIcons.solidBellSlash,
    "FontAwesome.trash": FontAwesomeIcons.trash,
    "FontAwesome.copyright": FontAwesomeIcons.copyright,
    "FontAwesome.at": FontAwesomeIcons.at,
    "FontAwesome.eyedropper": FontAwesomeIcons.eyeDropper,
    "FontAwesome.paint-brush": FontAwesomeIcons.paintbrush,
    "FontAwesome.birthday-cake": FontAwesomeIcons.cakeCandles,
    "FontAwesome.area-chart": FontAwesomeIcons.chartArea,
    "FontAwesome.pie-chart": FontAwesomeIcons.chartPie,
    "FontAwesome.line-chart": FontAwesomeIcons.chartLine,
    "FontAwesome.lastfm": FontAwesomeIcons.lastfm,
    "FontAwesome.lastfm-square": FontAwesomeIcons.lastfmSquare,
    "FontAwesome.toggle-off": FontAwesomeIcons.toggleOff,
    "FontAwesome.toggle-on": FontAwesomeIcons.toggleOn,
    "FontAwesome.bicycle": FontAwesomeIcons.bicycle,
    "FontAwesome.bus": FontAwesomeIcons.bus,
    "FontAwesome.ioxhost": FontAwesomeIcons.ioxhost,
    "FontAwesome.angellist": FontAwesomeIcons.angellist,
    "FontAwesome.cc": FontAwesomeIcons.closedCaptioning,
    "FontAwesome.shekel": FontAwesomeIcons.shekelSign,
    "FontAwesome.sheqel": FontAwesomeIcons.shekelSign,
    "FontAwesome.ils": FontAwesomeIcons.shekelSign,
    "FontAwesome.meanpath": FontAwesomeIcons.fontAwesome,
    "FontAwesome.buysellads": FontAwesomeIcons.buysellads,
    "FontAwesome.connectdevelop": FontAwesomeIcons.connectdevelop,
    "FontAwesome.dashcube": FontAwesomeIcons.dashcube,
    "FontAwesome.forumbee": FontAwesomeIcons.forumbee,
    "FontAwesome.leanpub": FontAwesomeIcons.leanpub,
    "FontAwesome.sellsy": FontAwesomeIcons.sellsy,
    "FontAwesome.shirtsinbulk": FontAwesomeIcons.shirtsinbulk,
    "FontAwesome.simplybuilt": FontAwesomeIcons.simplybuilt,
    "FontAwesome.skyatlas": FontAwesomeIcons.skyatlas,
    "FontAwesome.cart-plus": FontAwesomeIcons.cartPlus,
    "FontAwesome.cart-arrow-down": FontAwesomeIcons.cartArrowDown,
    "FontAwesome.diamond": FontAwesomeIcons.gem,
    "FontAwesome.ship": FontAwesomeIcons.ship,
    "FontAwesome.user-secret": FontAwesomeIcons.userSecret,
    "FontAwesome.motorcycle": FontAwesomeIcons.motorcycle,
    "FontAwesome.street-view": FontAwesomeIcons.streetView,
    "FontAwesome.heartbeat": FontAwesomeIcons.heartPulse,
    "FontAwesome.venus": FontAwesomeIcons.venus,
    "FontAwesome.mars": FontAwesomeIcons.mars,
    "FontAwesome.mercury": FontAwesomeIcons.mercury,
    "FontAwesome.intersex": FontAwesomeIcons.transgender,
    "FontAwesome.transgender": FontAwesomeIcons.transgender,
    "FontAwesome.transgender-alt": FontAwesomeIcons.transgender,
    "FontAwesome.venus-double": FontAwesomeIcons.venusDouble,
    "FontAwesome.mars-double": FontAwesomeIcons.marsDouble,
    "FontAwesome.venus-mars": FontAwesomeIcons.venusMars,
    "FontAwesome.mars-stroke": FontAwesomeIcons.marsStroke,
    "FontAwesome.mars-stroke-v": FontAwesomeIcons.marsStrokeUp,
    "FontAwesome.mars-stroke-h": FontAwesomeIcons.marsStrokeRight,
    "FontAwesome.neuter": FontAwesomeIcons.neuter,
    "FontAwesome.genderless": FontAwesomeIcons.genderless,
    "FontAwesome.facebook-official": FontAwesomeIcons.facebook,
    "FontAwesome.pinterest-p": FontAwesomeIcons.pinterestP,
    "FontAwesome.whatsapp": FontAwesomeIcons.whatsapp,
    "FontAwesome.server": FontAwesomeIcons.server,
    "FontAwesome.user-plus": FontAwesomeIcons.userPlus,
    "FontAwesome.user-times": FontAwesomeIcons.userXmark,
    "FontAwesome.hotel": FontAwesomeIcons.hotel,
    "FontAwesome.bed": FontAwesomeIcons.bed,
    "FontAwesome.viacoin": FontAwesomeIcons.viacoin,
    "FontAwesome.train": FontAwesomeIcons.train,
    "FontAwesome.subway": FontAwesomeIcons.trainSubway,
    "FontAwesome.medium": FontAwesomeIcons.medium,
    "FontAwesome.yc": FontAwesomeIcons.yCombinator,
    "FontAwesome.y-combinator": FontAwesomeIcons.yCombinator,
    "FontAwesome.optin-monster": FontAwesomeIcons.optinMonster,
    "FontAwesome.opencart": FontAwesomeIcons.opencart,
    "FontAwesome.expeditedssl": FontAwesomeIcons.expeditedssl,
    "FontAwesome.battery-4": FontAwesomeIcons.batteryFull,
    "FontAwesome.battery-full": FontAwesomeIcons.batteryFull,
    "FontAwesome.battery-3": FontAwesomeIcons.batteryThreeQuarters,
    "FontAwesome.battery-three-quarters": FontAwesomeIcons.batteryThreeQuarters,
    "FontAwesome.battery-2": FontAwesomeIcons.batteryHalf,
    "FontAwesome.battery-half": FontAwesomeIcons.batteryHalf,
    "FontAwesome.battery-1": FontAwesomeIcons.batteryQuarter,
    "FontAwesome.battery-quarter": FontAwesomeIcons.batteryQuarter,
    "FontAwesome.battery-0": FontAwesomeIcons.batteryEmpty,
    "FontAwesome.battery-empty": FontAwesomeIcons.batteryEmpty,
    "FontAwesome.mouse-pointer": FontAwesomeIcons.arrowPointer,
    "FontAwesome.i-cursor": FontAwesomeIcons.iCursor,
    "FontAwesome.object-group": FontAwesomeIcons.objectGroup,
    "FontAwesome.object-ungroup": FontAwesomeIcons.objectUngroup,
    "FontAwesome.sticky-note": FontAwesomeIcons.noteSticky,
    "FontAwesome.sticky-note-o": FontAwesomeIcons.noteSticky,
    "FontAwesome.cc-jcb": FontAwesomeIcons.ccJcb,
    "FontAwesome.cc-diners-club": FontAwesomeIcons.ccDinersClub,
    "FontAwesome.clone": FontAwesomeIcons.clone,
    "FontAwesome.balance-scale": FontAwesomeIcons.scaleBalanced,
    "FontAwesome.hourglass-o": FontAwesomeIcons.hourglass,
    "FontAwesome.hourglass-1": FontAwesomeIcons.hourglassStart,
    "FontAwesome.hourglass-start": FontAwesomeIcons.hourglassStart,
    "FontAwesome.hourglass-2": FontAwesomeIcons.hourglass,
    "FontAwesome.hourglass-half": FontAwesomeIcons.hourglass,
    "FontAwesome.hourglass-3": FontAwesomeIcons.hourglassEnd,
    "FontAwesome.hourglass-end": FontAwesomeIcons.hourglassEnd,
    "FontAwesome.hourglass": FontAwesomeIcons.hourglass,
    "FontAwesome.hand-grab-o": FontAwesomeIcons.solidHandBackFist,
    "FontAwesome.hand-rock-o": FontAwesomeIcons.solidHandBackFist,
    "FontAwesome.hand-stop-o": FontAwesomeIcons.solidHand,
    "FontAwesome.hand-paper-o": FontAwesomeIcons.solidHand,
    "FontAwesome.hand-scissors-o": FontAwesomeIcons.solidHandScissors,
    "FontAwesome.hand-lizard-o": FontAwesomeIcons.solidHandLizard,
    "FontAwesome.hand-spock-o": FontAwesomeIcons.solidHandSpock,
    "FontAwesome.hand-pointer-o": FontAwesomeIcons.solidHandPointer,
    "FontAwesome.hand-peace-o": FontAwesomeIcons.solidHandPeace,
    "FontAwesome.trademark": FontAwesomeIcons.trademark,
    "FontAwesome.registered": FontAwesomeIcons.registered,
    "FontAwesome.creative-commons": FontAwesomeIcons.creativeCommons,
    "FontAwesome.gg": FontAwesomeIcons.gg,
    "FontAwesome.gg-circle": FontAwesomeIcons.ggCircle,
    "FontAwesome.tripadvisor": FontAwesomeIcons.ggCircle,
    "FontAwesome.odnoklassniki": FontAwesomeIcons.odnoklassniki,
    "FontAwesome.odnoklassniki-square": FontAwesomeIcons.odnoklassnikiSquare,
    "FontAwesome.get-pocket": FontAwesomeIcons.getPocket,
    "FontAwesome.wikipedia-w": FontAwesomeIcons.wikipediaW,
    "FontAwesome.safari": FontAwesomeIcons.safari,
    "FontAwesome.chrome": FontAwesomeIcons.chrome,
    "FontAwesome.firefox": FontAwesomeIcons.firefox,
    "FontAwesome.opera": FontAwesomeIcons.opera,
    "FontAwesome.internet-explorer": FontAwesomeIcons.internetExplorer,
    "FontAwesome.tv": FontAwesomeIcons.tv,
    "FontAwesome.television": FontAwesomeIcons.tv,
    "FontAwesome.contao": FontAwesomeIcons.contao,
    "FontAwesome.500px": FontAwesomeIcons.circleQuestion,
    "FontAwesome.amazon": FontAwesomeIcons.amazon,
    "FontAwesome.calendar-plus-o": FontAwesomeIcons.solidCalendarPlus,
    "FontAwesome.calendar-minus-o": FontAwesomeIcons.solidCalendarMinus,
    "FontAwesome.calendar-times-o": FontAwesomeIcons.solidCalendarXmark,
    "FontAwesome.calendar-check-o": FontAwesomeIcons.solidCalendarCheck,
    "FontAwesome.industry": FontAwesomeIcons.industry,
    "FontAwesome.map-pin": FontAwesomeIcons.mapPin,
    "FontAwesome.map-signs": FontAwesomeIcons.signsPost,
    "FontAwesome.map-o": FontAwesomeIcons.solidMap,
    "FontAwesome.map": FontAwesomeIcons.map,
    "FontAwesome.commenting": FontAwesomeIcons.commentDots,
    "FontAwesome.commenting-o": FontAwesomeIcons.solidCommentDots,
    "FontAwesome.houzz": FontAwesomeIcons.houzz,
    "FontAwesome.vimeo": FontAwesomeIcons.vimeo,
    "FontAwesome.black-tie": FontAwesomeIcons.blackTie,
    "FontAwesome.fonticons": FontAwesomeIcons.fonticons,
  };
}
