## 2026-04-02 - Pre-calculate Animations in Grid itemBuilders
**Learning:** Instantiating `Tween` and `CurvedAnimation` objects inside an `itemBuilder` (such as in `MasonryGridView` or `SliverGrid`) creates O(n) new objects per scroll tick. This leads to memory churn and garbage collection pressure, causing UI jank during scrolling.
**Action:** Pre-calculate and cache static stagger animations inside `initState` or `didUpdateWidget` into a list. In the `itemBuilder`, perform an O(1) array lookup using the item index to retrieve the pre-built animation.
