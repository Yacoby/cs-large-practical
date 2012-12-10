/**
 * @file
 *
 * Defines the constants that are used when creating NSError objects. The domain
 * of the application and the error codes within that domain. The error codes within
 * the domain all relate to one file.
 *
 * @see https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ErrorHandlingCocoa/ErrorObjectsDomains/ErrorObjectsDomains.html
 */

/**
 * @brief errors are segregated into domains, and this is the domain for this application
 */
#define ERROR_DOMAIN @"com.jacobessex.cslp"

/**
 * @brief The error code of command line parsing errors
 * @see CommandLineOptionParser
 */
#define COMMAND_LINE_ERROR 1

/**
 * @brief the error code when attempting to load configuration
 * @see ConfigurationSerilizer
 */
#define CFG_PARSE_ERROR 2

/**
 * @brief the error code for factories.
 * Usually when getting a class that isn't registered in the factory
 * @see Factory
 */
#define FACTORY_ERROR 3
