//
//  sha1.h
//  letslunch_iPhone2
//
//  Created by Florian Reiss on 01/07/13.
//  Copyright (c) 2013 Florian Reiss. All rights reserved.
//

// From http://www.mirrors.wiretapped.net/security/cryptography/hashes/sha1/sha1.c

#include "sys/types.h"


typedef struct {
    u_int32_t state[5];
    u_int32_t count[2];
    u_int8_t buffer[64];
} SHA1_CTX;

extern void SHA1Init(SHA1_CTX* context);
extern void SHA1Update(SHA1_CTX* context, u_int8_t* data, u_int32_t len);
extern void SHA1Final(u_int8_t digest[20], SHA1_CTX* context);
