//
//  BasicEncodingRules.h
//
//  Created by Peter Suk on 5/16/12.
//  Copyright (c) Ooghamist LLC 2012. All rights reserved.
//
//  Distributed under the permissive zlib License
//  Get the latest version from here:
//
//  https://github.com/StCredZero/SCZ-BasicEncodingRules-iOS
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import <Foundation/Foundation.h>

@interface NSObject (BasicEncodingRules)
- (void)raiseUnimplemented;
- (uint8_t*)berTag;
- (NSData*)berHeader;
- (NSData*)berData;
- (NSUInteger)berLengthBytes;
- (NSUInteger)berContentsLengthBytes;   
@end

@interface NSData (BasicEncodingRules)
- (uint8_t*)berTag;
- (NSData*)berData;
- (NSUInteger)berContentsLengthBytes;
@end

@interface NSArray (BasicEncodingRules)
- (uint8_t*)berTag;
- (NSData*)berData;
- (NSUInteger)berContentsLengthBytes;
@end