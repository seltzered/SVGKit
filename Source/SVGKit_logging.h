//
//#ifndef IS_ALSO_LUMBERJACK_LOG_LEVEL
//#define IS_ALSO_LUMBERJACK_LOG_LEVEL 1
//#endif
//
//#if IS_ALSO_LUMBERJACK_LOG_LEVEL
//extern int ddLogLevel CA_HIDDEN;
//#else
//int SVGCurrentLogLevel() CA_HIDDEN;
//#define ddLogLevel SVGCurrentLogLevel()
//#endif
//

#ifdef DEBUG
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
#else
static const DDLogLevel ddLogLevel = DDLogLevelWarn;
#endif

