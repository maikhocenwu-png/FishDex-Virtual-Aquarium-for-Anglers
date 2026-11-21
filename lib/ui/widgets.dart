import 'package:material_ui/material_ui.dart';

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
  const DarkButton(this.label, {super.key, this.onTap, this.enabled = true});

  final String label;
  final VoidCallback? onTap;

  /// false = the main action is not possible yet, so the button is gray.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? kDark : kTag,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: enabled ? onTap : null,
        child: SizedBox(
          height: 48,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: enabled ? Colors.white : kMuted,
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
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
          style: TextStyle(fontSize: 12, color: selected ? Colors.white : kInk),
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
    this.species,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String? tag;
  final String? species;
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
              species != null
                  ? const PhotoBox(width: 60, height: 60)
                  : FishTile(species: species!),
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
                    if (tag != null) ...[const SizedBox(height: 6), Tag(tag!)],
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
/// Colors and a pattern for each species.
class FishStyle {
  const FishStyle(this.top, this.bottom, {this.pattern = 0});

  final Color top;
  final Color bottom;
  final int pattern; // 0 plain, 1 stripes, 2 spots

  static const _palette = [
    FishStyle(Color(0xFF5BAE5B), Color(0xFFC9E8A0)),
    FishStyle(Color(0xFF3C7FD0), Color(0xFFF2A65A)),
    FishStyle(Color(0xFFE2573B), Color(0xFFFFC09A)),
    FishStyle(Color(0xFF2BA8A0), Color(0xFFA7E6DF)),
    FishStyle(Color(0xFF8A6BD1), Color(0xFFD9C8F5)),
    FishStyle(Color(0xFFE6B422), Color(0xFFFFE9A3)),
  ];

  /// Picks a look from the species name. Same species, same look.
  static FishStyle of(String species) {
    final s = species.toLowerCase();
    if (s.contains('striped')) {
      return const FishStyle(Color(0xFF7F9BB3), Color(0xFFE6EEF3), pattern: 1);
    }
    if (s.contains('perch')) {
      return const FishStyle(Color(0xFFE0A91C), Color(0xFFFFE9A3), pattern: 1);
    }
    if (s.contains('bass')) {
      return const FishStyle(Color(0xFF4FA05A), Color(0xFFCDE9A4), pattern: 2);
    }
    if (s.contains('bluegill') ||
        s.contains('pumpkinseed') ||
        s.contains('crappie')) {
      return const FishStyle(Color(0xFF3C7FD0), Color(0xFFF2A65A), pattern: 2);
    }
    if (s.contains('trout')) {
      return const FishStyle(Color(0xFF2BA8A0), Color(0xFFF4C6D0), pattern: 2);
    }
    if (s.contains('catfish') || s.contains('carp')) {
      return const FishStyle(Color(0xFF9B6B43), Color(0xFFE5C7A3));
    }
    if (s.contains('mackerel') ||
        s.contains('bluefish') ||
        s.contains('weakfish')) {
      return const FishStyle(Color(0xFF2F6DB5), Color(0xFFDCE9F5), pattern: 1);
    }
    if (s.contains('flounder') || s.contains('tautog') || s.contains('scup')) {
      return const FishStyle(Color(0xFFA9763F), Color(0xFFF0D3A0), pattern: 2);
    }
    final hash = species.codeUnits.fold<int>(
      0,
      (a, b) => (a * 31 + b) & 0x7fffffff,
    );
    return _palette[hash % _palette.length];
  }
}

/// A colored fish facing right. Pass the species name to get its look.
class FishShape extends StatelessWidget {
  const FishShape({super.key, this.species = '', this.width = 96, this.color});

  final String species;
  final double width;
  final Color? color; // old option, kept so older code still compiles

  @override
  Widget build(BuildContext context) {
    final style = color != null
        ? FishStyle(color!, color!)
        : FishStyle.of(species);
    return CustomPaint(
      size: Size(width, width * 0.5),
      painter: _FishPainter(style),
    );
  }
}

class _FishPainter extends CustomPainter {
  _FishPainter(this.style);

  final FishStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    // Everything below is drawn on a 96 x 48 grid, then scaled to fit.
    canvas.scale(size.width / 96, size.height / 48);

    final dark = Color.lerp(style.top, Colors.black, 0.35)!;
    final outline = Paint()
      ..color = dark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeJoin = StrokeJoin.round;
    final finPaint = Paint()
      ..color = Color.lerp(style.top, style.bottom, 0.25)!;

    // Fins: tail, back fin, belly fin.
    final tail = Path()
      ..moveTo(30, 24)
      ..lineTo(3, 5)
      ..quadraticBezierTo(12, 24, 3, 43)
      ..close();
    final dorsal = Path()
      ..moveTo(40, 13)
      ..quadraticBezierTo(52, -1, 68, 13)
      ..close();
    final pelvic = Path()
      ..moveTo(46, 36)
      ..lineTo(54, 47)
      ..lineTo(62, 36)
      ..close();
    for (final p in [tail, dorsal, pelvic]) {
      canvas.drawPath(p, finPaint);
      canvas.drawPath(p, outline);
    }

    // Body: darker on top, lighter belly.
    const body = Rect.fromLTWH(22, 9, 72, 30);
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [style.top, style.bottom],
      ).createShader(body);
    canvas.drawOval(body, bodyPaint);

    // Stripes or spots, drawn only inside the body.
    canvas.save();
    canvas.clipPath(Path()..addOval(body));
    final mark = Paint()..color = dark.withValues(alpha: 0.28);
    if (style.pattern == 1) {
      for (var x = 38.0; x < 80; x += 11) {
        canvas.drawRect(Rect.fromLTWH(x, 9, 5, 30), mark);
      }
    } else if (style.pattern == 2) {
      for (final o in const [
        Offset(40, 18),
        Offset(50, 28),
        Offset(58, 16),
        Offset(66, 27),
        Offset(46, 22),
        Offset(74, 19),
      ]) {
        canvas.drawCircle(o, 2.6, mark);
      }
    }
    canvas.restore();

    canvas.drawOval(body, outline);

    // Gill line, eye, mouth.
    canvas.drawArc(
      const Rect.fromLTWH(64, 14, 12, 20),
      2.2,
      1.8,
      false,
      outline,
    );
    canvas.drawCircle(const Offset(82, 21), 4.6, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(83, 21), 2.3, Paint()..color = Colors.black);
    canvas.drawCircle(
      const Offset(83.8, 20.2),
      0.8,
      Paint()..color = Colors.white,
    );
    canvas.drawLine(const Offset(93, 26), const Offset(88, 27.5), outline);
  }

  @override
  bool shouldRepaint(covariant _FishPainter old) =>
      old.style.top != style.top ||
      old.style.bottom != style.bottom ||
      old.style.pattern != style.pattern;
}

/// Small blue tile with a fish, used on catch rows when there is no photo.
class FishTile extends StatelessWidget {
  const FishTile({super.key, required this.species, this.size = 60});

  final String species;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFD3EEF9), Color(0xFF8CC8E3)],
        ),
      ),
      child: FishShape(species: species, width: size * 0.8),
    );
  }
}
