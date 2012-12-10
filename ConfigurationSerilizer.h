#import <Foundation/Foundation.h>
#import "SimulationConfiguration.h"
#import "ReactionDefinition.h"


/**
 * @brief Protocol defines the deserilization of anything into a SimulationConfiguration*
 */
@protocol ConfigurationSerilizer
+ (SimulationConfiguration*)deserilize:(NSString*)input;
+ (SimulationConfiguration*)deserilize:(NSString*)input error:(NSError**)err;
@end

/**
 * @brief Parses the script configuration as defined in the handout
 */
@interface ConfigurationTextSerilizer : NSObject<ConfigurationSerilizer>{
}
+ (SimulationConfiguration*)deserilize:(NSString*)input;

/**
 * 
 * @note This is not how I would have written the function had I had access
 *       to a decent set of libraries. However getting things like ParseKit
 *       to compile seemed to be an absolute nightmare
 */
+ (SimulationConfiguration*)deserilize:(NSString*)input error:(NSError**)err;

/**
 * @brief Parses an assignment such as b = 5
 * @param cfg The configuration to apply the parsed line to
 * @param fromLine the line to parse. This must be an assignment
 * @param lineNumber the line number to be used in error messages
 * @param error the error to be filled with details if an error occurs
 * @return YES on success NO otherwise
 *
 * @note This method is only meant to be called by deserilize:error:
 */
+ (BOOL)parseSimpleAssignmentForCfg:(SimulationConfiguration*)cfg 
                           fromLine:(NSString*)line 
                         lineNumber:(int)lineNumber
                              error:(NSError**)err;

/**
 * @brief parses a molecule assignment such as A = 60
 * 
 * @param cfg The configuration to apply the assignment to
 * @param key The name (key) of the molecule
 * @param value The value of the assignment. This should be an integer in string form
 * @param lineNumber the line number to be used in error messages
 * @param error the error to be filled with details if an error occurs
 * @return YES on success NO otherwise
 *
 * @note this method is only meant to be called from parseSimpleAssignmentForCfg:fromLine:lineNumber:error
 */
+ (BOOL)parseMoleculeAssignmentForCfg:(SimulationConfiguration*)cfg
                                  key:(NSString*)key
                                value:(NSString*)value
                           lineNumber:(int)lineNumber
                                error:(NSError**)err;

/**
 * @brief parses a kinetic constant assignment such as x = 10e-5
 * @param cfg
 * @param key The name (key) of the kinetic constant.
 * @param value The value of the assignment. This should be a double in string form
 * @param lineNumber the line number to be used in error messages
 * @param error the error to be filled with details if an error occurs
 * @return YES on success NO otherwise
 *
 * @note this method is only meant to be called from parseSimpleAssignmentForCfg:fromLine:lineNumber:error
 */
+ (BOOL)parseKineticConstantAssignmentForCfg:(SimulationConfiguration*)cfg
                                         key:(NSString*)key
                                       value:(NSString*)value
                                  lineNumber:(int)lineNumber
                                       error:(NSError**)err;

/**
 * @brief parses an equation such as f : A -> B
 * @param cfg The configuration to apply the parsed line to
 * @param fromLine the line to parse. This must be an equation assignment
 * @param lineNumber the line number to be used in error messages
 * @param error the error to be filled with details if an error occurs
 * @return YES on success NO otherwise
 */
+ (BOOL)parseEquationForCfg:(SimulationConfiguration*)cfg
                   fromLine:(NSString*)line
                 lineNumber:(int)lineNumber
                      error:(NSError**)err;
/**
 * @brief Parses the reaction components. E.g: A + B -> C
 */
+ (ReactionEquation*)parseEquationComponents: (NSString*) reaction error:(NSError**)err;
+ (NSCountedSet*)parsePartOfEquationComponents:(NSString*) part error:(NSError**)err;

/**
 * @brief Removes all white space from the lhs and rhs of a string
 */
+ (NSString*)trimWhiteSpace:(NSString*)str;

/**
 * @brief returns true if a string variable is a molecule count
 *
 * Returns true if it starts with a capital letter
 */ 
+ (BOOL)isVariableMoleculeCount:(NSString*)var;

/**
 * @brief returns true if a string variable is a kinetic constant
 *
 * Returns true if it starts with a lower case letter
 */ 
+ (BOOL)isKineticConstant:(NSString*)var;

/**
 * @brief removes everything after the first # symbol (including the # symbol)
 */ 
+ (NSString*)removeCommentFromLine:(NSString*)line;

/**
 * @brief makes an error object for the ConfigurationSerilizer.
 */ 
+ (void)makeError:(NSError**)err withDescription:(NSString*)desc;
@end
