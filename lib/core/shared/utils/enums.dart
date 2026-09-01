enum BelieveInYouLogEvent {
  // Provider
  providerAdded,
  providerUpdated,
  providerDisposed,
  providerFailed,

  // Screen Orientation
  screenOrientationLocked,
  failedToLockScreenOrientation,

  // Navigator
  navigatorDidPush,
  navigatorDidPop,
  navigatorDidRemove,
  navigatorDidReplace,
  navigatorDidChangeTop,
  navigatorDidStartUserGesture,
  navigatorDidStopUserGesture,

  // Lifecycle
  lifecycleDidPopNext,
  lifecycleDidPush,
  lifecycleDidPop,
  lifecycleDidPushNext,
  lifecycleDidChangeAppLifecycleState,
}
