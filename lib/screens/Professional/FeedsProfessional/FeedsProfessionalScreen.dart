// Professional Feed Screen
// Now using the common feed screen shared across all modules
import '../../shared/common_feed_screen.dart';

// Re-export with the same class name for backward compatibility
class FeedsProfessionalScreen extends CommonFeedScreen {
  const FeedsProfessionalScreen({super.key}) : super(showNewPostButton: false);
}
