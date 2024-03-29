import "package:markdown/markdown.dart" as md;

import "package:loure/component/content/markdown/markdown_mention_event_element_builder.dart";

class MarkdownNeventInlineSyntax extends md.InlineSyntax {
  MarkdownNeventInlineSyntax() : super("nostr:nevent[a-zA-Z0-9]+");

  @override
  bool onMatch(final md.InlineParser parser, final Match match) {
    // var text = match.input.substring(match.start, match.end);
    final text = match[0]!;
    final element =
        md.Element.text(MarkdownMentionEventElementBuilder.TAG, text);
    parser.addNode(element);

    return true;
  }
}
