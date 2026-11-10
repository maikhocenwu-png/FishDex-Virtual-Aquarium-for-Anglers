import 'package:flutter/material.dart';

import 'theme.dart';

/// Gray bar at the top of every screen, with an optional back control.
class TopBar extends StatelessWidget {
  const TopBar({
    super.key,
    required this.title,
    this.back,
    this.onBack,
    this.trailing,
  });

  final String title;
  final String? back; // '<' or 'Cancel'; null means no back control
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final arrow = back == '<';
    return Container(
      color: kBar,
      height: 64 + top,
      padding: EdgeInsets.fromLTRB(16, top, 16, 0),
      child: Row(
        children: [
          if (back != null)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onBack ?? () => Navigator.of(context).maybePop(),
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  back!,
                  style: TextStyle(
                    fontSize: arrow ? 22 : 16,
                    fontWeight: arrow ? FontWeight.w500 : FontWeight.w400,
                    color: kInk,
                  ),
                ),
              ),
            ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: kInk,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Big dark pill button (main action).
class DarkButton extends StatelessWidget {
  const DarkButton(this.label, {super.key, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kDark,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: SizedBox(
          height: 48,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// White pill button with an outline (secondary action).
class OutlinePill extends StatelessWidget {
  const OutlinePill(
    this.label, {
    super.key,
    this.onTap,
    this.height = 48,
    this.width,
    this.fontSize = 16,
  });

  final String label;
  final VoidCallback? onTap;
  final double height;
  final double? width;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.white,
        shape: const StadiumBorder(side: BorderSide(color: kLine)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: kInk,
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Outlined text box.
class AppField extends StatelessWidget {
  const AppField({
    super.key,
    this.controller,
    this.hint,
    this.obscure = false,
    this.maxLines = 1,
    this.onChanged,
    this.keyboardType,
  });

  final TextEditingController? controller;
  final String? hint;
  final bool obscure;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: kLine),
    );
    return TextField(
      controller: controller,
      obscureText: obscure,
      minLines: obscure ? 1 : maxLines,
      maxLines: maxLines,
      onChanged: onChanged,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 16, color: kInk),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 16, color: kMuted),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: border,
        enabledBorder: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kDark, width: 1.5),
        ),
      ),
    );
  }
}

/// A box that looks like a text field but opens something when tapped.
class PickField extends StatelessWidget {
  const PickField(this.text, {super.key, this.placeholder = false, this.onTap});

  final String text;
  final bool placeholder;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          border: Border.all(color: kLine),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 16, color: placeholder ? kMuted : kInk),
        ),
      ),
    );
  }
}

/// Small gray label above a field.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 12, color: kMuted)),
    );
  }
}

/// Small rounded label such as "Fed" or "Waiting to upload".
class Tag extends StatelessWidget {
  const Tag(this.label, {super.key, this.selected = false, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? kDark : kTag,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? Colors.white : kInk,
          ),
        ),
      ),
    );
  }
}

/// Gray rectangle standing in for a photo.
class PhotoBox extends StatelessWidget {
  const PhotoBox({super.key, this.height, this.width, this.label = 'PHOTO'});

  final double? height;
  final double? width;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: kPhoto,
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: kMuted,
        ),
      ),
    );
  }
}

/// One row in the catch list.
class CatchCard extends StatelessWidget {
  const CatchCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.tag,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String? tag;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: kLine),
    );
    return Material(
      color: Colors.white,
      shape: shape,
      child: InkWell(
        customBorder: shape,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 88),
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              const PhotoBox(width: 60, height: 60),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: kInk,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 13, color: kMuted),
                    ),
                    if (tag != null) ...[
                      const SizedBox(height: 6),
                      Tag(tag!),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A bordered row with a title, a small line under it, and something on the right.
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.italicSubtitle = false,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool italicSubtitle;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: kLine),
    );
    return Material(
      color: Colors.white,
      shape: shape,
      child: InkWell(
        customBorder: shape,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: kInk,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 12,
                          color: kMuted,
                          fontStyle: italicSubtitle
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                      ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom bar with two tabs: Catches and Aquarium.
class BottomTabs extends StatelessWidget {
  const BottomTabs({super.key, required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    Widget tab(String label, int i) {
      final selected = index == i;
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(i),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected ? kInk : kMuted,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      height: 64 + bottom,
      padding: EdgeInsets.only(bottom: bottom),
      decoration: const BoxDecoration(
        color: kBar,
        border: Border(top: BorderSide(color: kLine)),
      ),
      child: Row(children: [tab('Catches', 0), tab('Aquarium', 1)]),
    );
  }
}

/// Small ON / OFF switch drawn like the wireframe.
class WireSwitch extends StatelessWidget {
  const WireSwitch({super.key, required this.on, required this.onChanged});

  final bool on;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!on),
      child: Container(
        width: 48,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? kDark : kTag,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          on ? 'ON' : 'OFF',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: on ? Colors.white : kMuted,
          ),
        ),
      ),
    );
  }
}

/// The simple fish drawing used in the aquarium and the share card.
class FishShape extends StatelessWidget {
  const FishShape({super.key, this.color = const Color(0xFF666666)});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(96, 40), painter: _FishPainter(color));
  }
}

class _FishPainter extends CustomPainter {
  _FishPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = color;
    final stroke = Paint()
      ..color = kInk
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final tail = Path()
      ..moveTo(1, 6)
      ..lineTo(1, 34)
      ..lineTo(25, 20)
      ..close();
    canvas.drawPath(tail, fill);
    canvas.drawPath(tail, stroke);
    canvas.drawOval(Rect.fromLTWH(22, 0, 72, 40), fill);
    canvas.drawCircle(const Offset(77, 15), 3, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _FishPainter oldDelegate) =>
      oldDelegate.color != color;
}
