// Transport Feed Screen
// Now using the common feed screen shared across all modules
import '../shared/common_feed_screen.dart';

// Re-export with the same class name for backward compatibility
class FeedScreen extends CommonFeedScreen {
  const FeedScreen({super.key});
}
