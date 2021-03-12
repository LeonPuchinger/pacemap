import 'package:petitparser/petitparser.dart';

final signedFloat = [
  char('-').optional(),
  digit().plus(),
  (char('.') & digit().plus()).optional()
].toSequenceParser().flatten().map<double>(double.parse);

final cGPX = signedFloat.separatedBy(
  char(';'),
  includeSeparators: false,
).castList<double>();
