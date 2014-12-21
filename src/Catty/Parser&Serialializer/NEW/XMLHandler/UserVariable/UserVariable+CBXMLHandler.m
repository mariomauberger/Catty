/**
 *  Copyright (C) 2010-2014 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

#import "UserVariable+CBXMLHandler.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "CBXMLValidator.h"
#import "CBXMLParserHelper.h"
#import "CBXMLContext.h"

@implementation UserVariable (CBXMLHandler)

#pragma mark - Parsing
+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLContext*)context
{
    [XMLError exceptionIfNode:xmlElement isNilOrNodeNameNotEquals:@"userVariable"];
    BOOL isReferencedVariable = [CBXMLParserHelper isReferenceElement:xmlElement];
    
    if (isReferencedVariable) {
        GDataXMLNode *referenceAttribute = [xmlElement attributeForName:@"reference"];
        NSString *xPath = [referenceAttribute stringValue];
        xmlElement = [xmlElement singleNodeForCatrobatXPath:xPath];
        [XMLError exceptionIfNil:xmlElement message:@"Invalid reference in UserVariable!"];
    }
    
    UserVariable *userVariable = [UserVariable new];
    [XMLError exceptionIfNil:[xmlElement stringValue] message:@"No name for user variable given"];
    userVariable.name = [xmlElement stringValue];

    if(! isReferencedVariable) {
        UserVariable *alreadyExistingUserVariable = [CBXMLParserHelper findUserVariableInArray:context.userVariableList withName:userVariable.name];
        if (alreadyExistingUserVariable) {
            NSLog(@"User variable with same name %@ already exists...\
                  Instantiated by other brick...", alreadyExistingUserVariable.name);
            return alreadyExistingUserVariable;
        }
        [context.userVariableList addObject:userVariable];
    }
    return userVariable;
}

#pragma mark - Serialization
- (GDataXMLElement*)xmlElementWithContext:(CBXMLContext*)context
{
    GDataXMLElement *xmlElement = [GDataXMLElement elementWithName:@"userVariable" stringValue:self.name context:context];
    return xmlElement;
}

@end
