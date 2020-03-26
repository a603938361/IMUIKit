//
//  NSData+NTES.m
//  NIM
//
//  Created by amao on 7/2/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NSData+NTES.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation NSData (NTES)

- (NSString *)MD5String {
    const char *cstr = [self bytes];
    unsigned char result[16];
    CC_MD5(cstr, (CC_LONG)[self length], result);
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (NSData *)aes256EncryptWithKey:(NSString *)key vector:(NSString *)vector {
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    assert(key.length == 32);
    char keyPtr[kCCKeySizeAES256 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    assert(vector.length == 16);
    char ivPtr[kCCKeySizeAES128 + 1];
    bzero(ivPtr, sizeof(vector));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    [vector getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    //
    NSUInteger dataLength = self.length;
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          ivPtr /* initialization vector (optional) */,
                                          self.bytes, dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer);
    return nil;
}

- (NSData *)aes256DecryptWithKey:(NSString *)key vector:(NSString *)vector {
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    assert(key.length == 32);
    char keyPtr[kCCKeySizeAES256 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    assert(vector.length == 16);
    char ivPtr[kCCKeySizeAES128 + 1];
    bzero(ivPtr, sizeof(vector));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    [vector getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    //
    NSUInteger dataLength = self.length;
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          ivPtr /* initialization vector (optional) */,
                                          self.bytes, dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer);
    return nil;
}


#define NTESSWAP(i, j) \
{ \
    char tmp = i; \
    i = j; \
    j = tmp; \
}


void RC4(const char *key, int keylen, char* output, const char* input, int len)
{
    // 设置密钥
    char key_[256];
    memset(key_, 0, 256);
    for (int i = 0; i < 256; i++)
    {
        key_[i] = i;
    }
    int j = 0;
    for (int i = 0; i < 256; i++)
    {
        j = (j + key_[i] + key[i%keylen]) & 0xff; // (j + key_[i] + key[i%keylen]) % 256;
        NTESSWAP(key_[i], key_[j]);
    }
    // 加/解密
    int i = 0;
    j = 0;
    for (int k = 0; k < len; k++)
    {
        i = (i+1) & 0xff; // (i + 1) % 256;
        j = (j + key_[i]) & 0xff; // (j + key_[i]) % 256;
        NTESSWAP(key_[i], key_[j]);
        unsigned char subkey = key_[(key_[i] + key_[j]) & 0xff]; // key_[(key_[i] + key_[j]) % 256];
        output[k] = subkey ^ input[k];
    }
    
    return;
}

- (NSData *)rc4EncryptWithKey:(NSString *)key {
    const char *pwd = [key UTF8String];
    char *outdata = (char *)calloc(self.length, 1);
    RC4(pwd, (int)key.length, outdata, self.bytes, (int)self.length);
    NSData *ret = [NSMutableData dataWithBytes:outdata length:self.length];
    free(outdata);
    return ret;
}

- (NSData *)rc4DecryptWithKey:(NSString *)key {
     const char *pwd = [key UTF8String];
     char *outdata = (char *)calloc(self.length + 1, 1);
     RC4(pwd, (int)key.length, outdata, self.bytes, (int)self.length);
     outdata[self.length] = 0;
     NSData *ret = [NSMutableData dataWithBytes:outdata length:self.length];
     free(outdata);
     return ret;}


+ (NSData *)zipImageWithImage:(UIImage *)image
{
    if (!image) {
        return nil;
    }
    CGFloat compression;
    int width=image.size.width;
    int height=image.size.height;
    width=(width % 2)==1?width+1:width;
    height=(height % 2)==1?height+1:height;
    int longSide;
    int shortSide;
    if(width>height){
        longSide=width;
        shortSide=height;
    }else{
        longSide=height;
        shortSide=width;
    }
    float scale=(float)shortSide/(float)longSide;
    if(scale<=1&&scale>0.5625){
    if(longSide<1664){
        compression=1.0f;
    }else if(longSide>1664&&longSide<4989){
        compression=0.5f;
    }else if(longSide>4991&&longSide<10239){
        compression=0.25f;
    }else{
        if(longSide/1280==0){
            compression=1.0f;
        }else{
            compression=1.0/((float)longSide/1280.0f);
        }
    }
    }else if(scale<=0.5625&&scale>0.5){
        if(longSide/1280==0){
            compression=1.0f;
        }else{
            compression=1.0/((float)longSide/1280.0f);
        }
    }else{
        compression=1.0/(float)((int)ceil(longSide/(1280.0/scale)));
    }
   NSData *compressedData = UIImageJPEGRepresentation([[self class] compressImage:image newWidth:compression], compression);
    return compressedData;
}
+ (UIImage *)compressImage:(UIImage *)image newWidth:(CGFloat)newImageWidth
{
    if (!image) return nil;
    float imageWidth = image.size.width;
    float imageHeight = image.size.height;
//    float width = newImageWidth;
//    float height = image.size.height/(image.size.width/width);
//
//    float widthScale = imageWidth /width;
//    float heightScale = imageHeight /height;
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(CGSizeMake(imageWidth*newImageWidth, imageHeight*newImageWidth));
    
//    if (widthScale > heightScale) {
        [image drawInRect:CGRectMake(0, 0, imageWidth*newImageWidth , imageHeight*newImageWidth)];
//    }
//    else {
//        [image drawInRect:CGRectMake(0, 0, width , imageHeight /widthScale)];
//    }
    
    // 从当前context中创建一个改变大小后的图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    return newImage;
        
}


@end
