//
//  JSNRSigType.hpp
//  Dynosoar
//
//  Created by Bailey Seymour on 12/4/17.
//  Copyright © 2017 Bailey Seymour. All rights reserved.
//

#ifndef JSNRSigType_h
#define JSNRSigType_h

#define _CPUnsignedOrSigned(TYPE, EXPR) (this->isUnsigned ? createPointer<unsigned TYPE>(EXPR) : createPointer<TYPE>(EXPR));
#define _CP(TYPE, EXPR) createPointer<TYPE>(EXPR)

namespace JSNR {
class SigType {
public:
    typedef enum {
        ENCTypeUnknown,
        // Numbers
        ENCTypeInt,
        ENCTypeShort,
        ENCTypeLong,
        ENCTypeLongLong,
        ENCTypeFloat,
        ENCTypeDouble,
        // Strings
        ENCTypeChar,
        ENCTypeCharPointer,
        // Booleans
        ENCTypeBool,
        // Other objects
        ENCTypeObject,
        ENCTypeClass,
        ENCTypeSelector,
    } ENCType;
    
    struct Encoding {
        static const char Int = 'i';
        static const char Short = 's';
        static const char Long = 'l';
        static const char LongLong = 'q';
        static const char Float = 'f';
        static const char Double = 'd';
        static const char Char = 'c';
        static const char CharPointer = '*';
        static const char Bool = 'B';
        static const char Object = '@';
        static const char Class = '#';
        static const char Selector = ':';
    };
    
    bool isConst;
    bool isUnsigned;
    ENCType type;
    char encoding;
    
    bool isEncodingNumber() {
        char _enc = tolower(encoding);
        return (_enc==Encoding::Int||_enc==Encoding::Short||_enc==Encoding::Long
                ||_enc==Encoding::LongLong||_enc==Encoding::Float||_enc==Encoding::Double);
    }
    
    bool isEncodingBoolean() {
        return (encoding==Encoding::Bool||encoding==Encoding::Char);
    }
    
    bool isEncodingString() {
        return (encoding==Encoding::Char||encoding==Encoding::CharPointer);
    }
    
    bool isEncodingInstanceOrClass() {
        return (encoding==Encoding::Object||encoding==Encoding::Class);
    }
    
    bool isEncodingSelector() {
        return (encoding==Encoding::Selector);
    }
    
    unsigned long sizeOfType() {
        switch (type) {
            case ENCTypeInt: {
                if (isUnsigned) return sizeof(unsigned int);
                return sizeof(int);
            }
                break;
            case ENCTypeShort: {
                if (isUnsigned) return sizeof(unsigned short);
                return sizeof(short);
            }
                break;
                
            case ENCTypeLong: {
                if (isUnsigned) return sizeof(unsigned long);
                return sizeof(long);
            }
                break;
            case ENCTypeLongLong: {
                if (isUnsigned) return sizeof(unsigned long long);
                return sizeof(long long);
            }
                break;
            case ENCTypeFloat:
                return sizeof(float);
                break;
            case ENCTypeDouble:
                return sizeof(double);
                break;
            case ENCTypeChar: {
                if (isUnsigned) return sizeof(unsigned char);
                return sizeof(char);
            }
                break;
            case ENCTypeCharPointer: {
                if (isUnsigned) return sizeof(unsigned char *);
                return sizeof(char *);
            }
                break;
            case ENCTypeObject:
                return sizeof(id);
                break;
            case ENCTypeClass:
                return sizeof(Class);
                break;
            case ENCTypeSelector:
                return sizeof(SEL);
                break;
            default:
                return 0; // not sure if I should assert size to be greater than 0
                break;
        }
        
        return 0;
    }

    
    SigType(std::string sigStr) {
        NSString *string = [NSString stringWithFormat:@"%s", sigStr.c_str()];
        
        
        if ([string containsString:@"r"]) {
            isConst = true;
            string = [string stringByReplacingOccurrencesOfString:@"r" withString:@""];
        }
        // at this point it should only be the type id ex. 'd' for double
        
        if (string.length == 1) {
            char typeId = [string characterAtIndex:0];
            encoding = typeId;
            
            if (isupper(typeId) && isEncodingNumber()) {
              isUnsigned = true;
                typeId = tolower(typeId);
            }
        
            
            switch (typeId) {
                case Encoding::Int:
                    type = ENCTypeInt;
                    break;
                case Encoding::Short:
                    type = ENCTypeShort;
                    break;
                case Encoding::Long:
                    type = ENCTypeLong;
                    break;
                case Encoding::LongLong:
                    type = ENCTypeLongLong;
                    break;
                case Encoding::Float:
                    type = ENCTypeFloat;
                    break;
                case Encoding::Double:
                    type = ENCTypeDouble;
                    break;
                case Encoding::Char:
                    type = ENCTypeChar;
                    break;
                case Encoding::CharPointer:
                    type = ENCTypeCharPointer;
                    break;
                case Encoding::Bool:
                    type = ENCTypeBool;
                    break;
                case Encoding::Object:
                    type = ENCTypeObject;
                    break;
                case Encoding::Class:
                    type = ENCTypeClass;
                    break;
                case Encoding::Selector:
                    type = ENCTypeSelector;
                    break;
                default:
                    type = ENCTypeUnknown;
                    break;
            }
        }
        else {
            type = ENCTypeUnknown;
            printf("*** ERROR: UNABLE TO PARSE TYPE: '%s'\n", sigStr.c_str());
        }
        
        
    }
    
//    template<typename Type_>
//    void *allocatePointer(Type2_ inVar) {
//        void *pointer = malloc(sizeOfType());
//        *pointer = static_cast<Type_>(inVar);
//        return pointer;
//    }
    
    template<typename Type_, typename Type2_>
    void* createPointer(Type2_ inVar) {
        Type_ *pointer = static_cast<Type_*>(malloc(sizeof(Type_))); //
        
        *pointer = static_cast<Type_>(inVar);
        
        return reinterpret_cast<Type_ *>(pointer);
    }
    
    static void *allocateAggregatePointer(Value val, unsigned long *fieldSizes, int numberOfFields) {
        // i think this function works with carrays in addition to working with structs
//        int numberOfFields = 4;
//        int sizeOfField = sizeof(double); // actually this math only works if all are same type
//        int sizeOfStruct = sizeOfField*numberOfFields; // can use a loop to get a correct summation
        int sizeOfStruct = 0;
        for (int i=0; i < numberOfFields; i++) {
            int aSize = (int)fieldSizes[i];
            sizeOfStruct+=aSize;
        }
        
        void *structPtr = (void *)malloc(sizeOfStruct);
        
        memset(structPtr, 0, sizeOfStruct); // zero out struct
        
        for (int i=0; i < numberOfFields; i++) {
            CGFloat mynum = 400;
            JSValueRef propAtIdx= JSObjectGetPropertyAtIndex(val.context, val.objectRef, i, NULL);
            // assuming field is double
            mynum = JSValueToNumber(val.context, propAtIdx, NULL);
            
            void *fieldAddr = ((char *)structPtr)+(fieldSizes[i]*i);
            memcpy(fieldAddr, &mynum, fieldSizes[i]);
        }
        
        
        return structPtr;
    }
    
    void *boolToSig(JSNR::Value val) {
        void *ptr = NULL;
        
        bool boolValue = val.toBoolean();
        
        switch (type) {
            case ENCTypeBool:
                ptr = _CP(bool, boolValue);
                break;
            case ENCTypeChar:
                ptr = _CP(char, boolValue);
                break;
                
            default:
                assert(ptr != NULL);
                break;
        }
        
        assert(ptr != NULL);
        
        return ptr;
    }
    
    void *stringToSig(JSNR::Value val) {
        void *ptr = NULL;
        JSNR::String str = JSNR::String(val);
        
        switch (type) {
            case ENCTypeChar:
                ptr = _CPUnsignedOrSigned(char, [str.NSString() characterAtIndex:0]);
                break;
            case ENCTypeCharPointer:{
                const char *cstring = [str.NSString() UTF8String];
                if (isConst) {
                    ptr = _CP(const char *, cstring);
                } else {
                    ptr = _CP(char *, const_cast<char *>(cstring));
                }
                break;
            }
            case ENCTypeObject: // handle js string to NSString
                ptr = _CP(NSString *, str.NSString());
                
                break;
            default:
                assert(ptr != NULL);
                break;
        }
        
        assert(&ptr != NULL);
        
        return ptr;
    }
    
    void *numberToSig(JSNR::Value val) {
        void *ptr = NULL;
        double num = val.toNumber();
        switch (type) {
                
            case ENCTypeInt:
                ptr = _CPUnsignedOrSigned(int, num);
                break;
            case ENCTypeShort:
                ptr = _CPUnsignedOrSigned(short, num);
                break;
            case ENCTypeLong:
                ptr = _CPUnsignedOrSigned(long, num);
                break;
            case ENCTypeLongLong:
                ptr = _CPUnsignedOrSigned(long long, num);
                break;
            case ENCTypeFloat:
                ptr = _CP(float, num);
                break;
            case ENCTypeDouble:
                ptr = _CP(double, num);
                break;
            default:
                assert(ptr != NULL);
                break;
        }
        assert(ptr != NULL);
        
        return ptr;
    }
    
    void *instanceOrClassToSig(JSNR::Value val) {
        void *ptr = NULL;
        id object = val.toObjCTypeObject(*this);
        ptr = createPointer<NSObject *>(object);
        // assert(ptr != NULL); //allow nil and NULL objects
        return ptr;
    }
    
    template<typename Type_>
    double doubleFromPointer(void *pointer) {
        void *result = malloc(sizeOfType());
        result = pointer;
        
        return (double)reinterpret_cast<Type_ &>(result);
    }
    
    template<typename Type_>
    bool boolFromPointer(void *pointer) {
        void *result = malloc(sizeOfType());
        result = pointer;
        
        return (bool)reinterpret_cast<Type_ &>(result);
    }
};
};
#endif /* JSNRSigType_h */
