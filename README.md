SCZ-BasicEncodingRules-iOS
==========================

Implementation of Basic Encoding Rules to enable import of RSA keys to iOS 
KeyChain using exponent. Code targets iOS 5 with ARC. 

Let's say you already have a modulus and exponent from 
an RSA public key as an NSData in variables named pubKeyModData and 
pubKeyModData. Then the following code will create an NSData containing that RSA 
public key, which you can then insert into the iOS or OS X Keychain.

    NSMutableArray *testArray = [[NSMutableArray alloc] init];
    [testArray addObject:pubKeyModData];
    [testArray addObject:pubKeyExpData];
    NSData *testPubKey = [testArray berData];
        
This would allow you to store the key using the addPeerPublicKey:keyBits: method from SecKeyWrapper in the Apple CryptoExercise example. Or, from the perspective of the low-level API, you can use SecItemAdd().

    NSString * peerName = @"Test Public Key";

	NSData * peerTag = 
	   [[NSData alloc] 
	       initWithBytes:(const void *)[peerName UTF8String] 
	       length:[peerName length]];
	       
	NSMutableDictionary * peerPublicKeyAttr = [[NSMutableDictionary alloc] init];
	
	[peerPublicKeyAttr 
	   setObject:(__bridge id)kSecClassKey 
	   forKey:(__bridge id)kSecClass];
	[peerPublicKeyAttr 
	   setObject:(__bridge id)kSecAttrKeyTypeRSA 
	   forKey:(__bridge id)kSecAttrKeyType];
	[peerPublicKeyAttr 
	   setObject:peerTag 
	   forKey:(__bridge id)kSecAttrApplicationTag];
	[peerPublicKeyAttr 
	   setObject:testPubKey 
	   forKey:(__bridge id)kSecValueData];
	[peerPublicKeyAttr 
	   setObject:[NSNumber numberWithBool:YES] 
	   forKey:(__bridge id)kSecReturnPersistentRef];
	
	sanityCheck = SecItemAdd((__bridge CFDictionaryRef) peerPublicKeyAttr, (CFTypeRef *)&persistPeer);
