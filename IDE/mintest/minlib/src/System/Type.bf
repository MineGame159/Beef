using System;
using System.Reflection;
using System.Collections.Generic;
using System.Diagnostics;

namespace System
{
    struct ClassVData
    {
        public Type mType;
        // The rest of this structured is generated by the compiler,
        //  including the vtable and interface slots
    }

    [CRepr, AlwaysInclude(AssumeInstantiated=true)]
    public class Type
    {
		internal extern const Type* sTypes;

		protected const BindingFlags cDefaultLookup = BindingFlags.Instance | BindingFlags.Static | BindingFlags.Public;

        internal int32 mSize;
        internal TypeId mTypeId;
        internal TypeFlags mTypeFlags;
        internal int32 mMemberDataOffset;
        internal TypeCode mTypeCode;
        internal uint8 mAlign;
        
        public int32 Size
        {
            get
            {
                return mSize;
            }
        }

		public int32 Align
		{
		    get
		    {
		        return mAlign;
		    }
		}

		public int32 Stride
		{
		    get
		    {
		        return Math.Align(mSize, mAlign);
		    }
		}

		public TypeId TypeId
		{
			get
			{
				return mTypeId;
			}
		}

        public bool IsPrimitive
        {
            get
            {
                return (mTypeFlags & TypeFlags.Primitive) != 0;
            }
        }

		public bool IsInteger
		{
			get
			{
				switch (mTypeCode)
				{
				case .Int8,
					 .Int16,
					 .Int32,
					 .Int64,
					 .Int,
					 .UInt8,
					 .UInt16,
					 .UInt32,
					 .UInt64,
					 .UInt:
					return true;
				default:
					return false;
				}
			}
		}

		public bool IsIntegral
		{
			get
			{
				switch (mTypeCode)
				{
				case .Int8,
					 .Int16,
					 .Int32,
					 .Int64,
					 .Int,
					 .UInt8,
					 .UInt16,
					 .UInt32,
					 .UInt64,
					 .UInt,
					 .Char8,
					 .Char16,
					 .Char32:
					return true;
				default:
					return false;
				}
			}
		}

		public bool IsFloatingPoint
		{
			get
			{
				switch (mTypeCode)
				{
				case .Float,
					 .Double:
					return true;
				default:
					return false;
				}
			}
		}

		public bool IsSigned
		{
			get
			{
				switch (mTypeCode)
				{
				case .Int8,
					 .Int16,
					 .Int32,
					 .Int64,
					 .Float,
					 .Double:
					return true;
				default:
					return false;
				}
			}
		}

		public bool IsChar
		{
			get
			{
				switch (mTypeCode)
				{
				case .Char8,
					 .Char16,
					 .Char32:
					return true;
				default:
					return false;
				}
			}
		}

		public bool IsTypedPrimitive
		{
		    get
		    {
		        return (mTypeFlags & TypeFlags.TypedPrimitive) != 0;
		    }
		}

		public bool IsObject
		{
		    get
		    {
		        return (mTypeFlags & TypeFlags.Object) != 0;
		    }
		}

		public bool IsValueType
		{
		    get
		    {
		        return (mTypeFlags & (.Struct | .Primitive | .TypedPrimitive)) != 0;
		    }
		}

        public bool IsStruct
        {
            get
            {
                return (mTypeFlags & TypeFlags.Struct) != 0;
            }
        }

		public bool IsSplattable
		{
		    get
		    {
		        return (mTypeFlags & TypeFlags.Splattable) != 0;
		    }
		}

		public bool IsUnion
		{
		    get
		    {
		        return (mTypeFlags & TypeFlags.Union) != 0;
		    }
		}

        public bool IsBoxed
        {
            get
            {
                return (mTypeFlags & TypeFlags.Boxed) != 0;
            }
        }

		public bool IsEnum
		{
		    get
		    {
				return mTypeCode == TypeCode.Enum;
		    }
		}

		public bool IsTuple
		{
			get
			{
				return mTypeFlags.HasFlag(TypeFlags.Tuple);
			}
		}

		public bool IsNullable
		{
			get
			{
				return mTypeFlags.HasFlag(.Nullable);
			}
		}

		public bool WantsMark
		{
		    get
		    {
		        return (mTypeFlags & .WantsMark) != 0;
		    }
		}

		public bool HasDestructor
		{
		    get
		    {
		        return (mTypeFlags & .HasDestructor) != 0;
		    }
		}

		public bool IsGenericType
		{
		    get
		    {
		        return (mTypeFlags & (TypeFlags.SpecializedGeneric | TypeFlags.UnspecializedGeneric)) != 0;
		    }
		}

		public virtual int32 GenericParamCount
		{
			get
			{
				return 0;
			}
		}

		public virtual int32 InstanceSize
		{
		    get
		    {
		        return mSize;
		    }
		}

		public virtual int32 InstanceAlign
		{
		    get
		    {
		        return mAlign;
		    }
		}

		public virtual int32 InstanceStride
		{
		    get
		    {
		        return Math.Align(mSize, mAlign);
		    }
		}

		public virtual TypeInstance BaseType
		{
		    get
		    {
		        return null;
		    }
		}

		public virtual TypeInstance OuterType
		{
		    get
		    {
		        return null;
		    }
		}

		public virtual Type UnderlyingType
		{
		    get
		    {
		        return null;
		    }
		}

		public virtual int32 FieldCount
		{
			get
			{
				return 0;
			}
		}

		public virtual int32 MaxValue
		{
			[Error("This property can only be accessed directly from a typeof() expression")]
			get
			{
				return 0;
			}
		}


        public int32 GetTypeId()
        {
            return (int32)mTypeId;
        }
        
        internal static Type GetType(TypeId typeId)
        {
            return sTypes[(int32)typeId];
        }

		internal static Type GetType_(int32 typeId)
		{
		    return sTypes[typeId];
		}

		void GetBasicName(String strBuffer)
		{
			switch (mTypeCode)
			{
			case .None: strBuffer.Append("void");
			case .CharPtr: strBuffer.Append("char8*");
			case .Pointer: strBuffer.Append("void*");
			case .NullPtr: strBuffer.Append("void*");
			case .Var: strBuffer.Append("var");
			case .Let: strBuffer.Append("let");
			case .Boolean: strBuffer.Append("bool");
			case .Int8: strBuffer.Append("int8");
			case .UInt8: strBuffer.Append("uint8");
			case .Int16: strBuffer.Append("int16");
			case .UInt16: strBuffer.Append("uint16");
			case .Int32: strBuffer.Append("int32");
			case .UInt32: strBuffer.Append("uint32");
			case .Int64: strBuffer.Append("int64");
			case .UInt64: strBuffer.Append("uint64");
			case .Int: strBuffer.Append("int");
			case .UInt: strBuffer.Append("uint");
			case .Char8: strBuffer.Append("char8");
			case .Char16: strBuffer.Append("char16");
			case .Char32: strBuffer.Append("char32");
			case .Float: strBuffer.Append("float");
			case .Double: strBuffer.Append("double");
			default: ((int32)mTypeCode).ToString(strBuffer);
			}
		}

        public virtual void GetFullName(String strBuffer)
        {
			GetBasicName(strBuffer);
        }

        public virtual void GetName(String strBuffer)
        {
            GetBasicName(strBuffer);
        }

		// Putting this in causes sTypes to be required when Object.ToString is reified
        /*public override void ToString(String strBuffer)
        {
			GetFullName(strBuffer);
        }*/
        
        public virtual Type GetBaseType()
        {
            //return mBaseType;
            return null;
        }

        protected this()
        {
        }

        public virtual bool IsSubtypeOf(Type type)
        {
            return type == this;
        }

		public virtual FieldInfo? GetField(String fieldName)
		{
		    return null;
		}

		public virtual FieldInfo.Enumerator GetFields(BindingFlags bindingFlags = cDefaultLookup)
		{
		    return FieldInfo.Enumerator(null, bindingFlags);
		}
    }

    enum TypeCode : uint8
	{   
	    None,
	    CharPtr,
	    Pointer,
	    NullPtr,
		Self,
		Dot,
	    Var,
		Let,
	    Boolean,
	    Int8,
	    UInt8,
	    Int16,
	    UInt16,
	    Int32,
	    UInt32,
	    Int64,
	    UInt64, 
	    Int,
	    UInt,
		IntUnknown,
		UIntUnknown,
	    Char8,
		Char16,
	    Char32,
	    Float,
	    Double,         
	    Object,
	    Interface,
	    Struct,
	    Enum,
		TypeAlias,
		Extension
	}
}

namespace System.Reflection
{
    internal struct TypeId : int32
    {
        public Type ToType()
        {
            return Type.sTypes[(int32)this];
        }        
    }

    [CRepr, AlwaysInclude(AssumeInstantiated=true)]
    internal class TypeInstance : Type
    {
        [CRepr, AlwaysInclude]
        internal struct FieldData
        {
            internal String mName;
            internal int64 mConstValue;
            internal int32 mDataOffset;
            internal TypeId mFieldTypeId;
            internal FieldFlags mFlags;
            internal int32 mCustomAttributesIdx;
        }

		// This is only valid if there is no FieldData on a splattable struct
		[CRepr, AlwaysInclude]
		internal struct FieldSplatData
		{
			internal TypeId[3] mSplatTypes;
			internal int32[3] mSplatOffsets;
		}

        [CRepr, AlwaysInclude]
        internal struct MethodData
        {
            internal String mName; // mName
            internal void* mFuncPtr;
			internal ParamData* mParamData;
			internal TypeId mReturnType;
			internal int16 mParamCount;
			internal MethodFlags mFlags;
			internal int32 mVirtualIdx;
			internal int32 mCustomAttributesIdx;
        }

		internal enum ParamFlags : int16
		{
			None = 0,
			Splat = 1,
			Implicit = 2
		}

		[CRepr, AlwaysInclude]
		internal struct ParamData
		{
			internal String mName;
			internal TypeId mType;
			internal ParamFlags mParamFlags;
			internal int32 mDefaultIdx;
		}

        internal ClassVData* mTypeClassVData;
        internal String mName;
        internal String mNamespace;
        internal int32 mInstSize;
        internal int32 mInstAlign;
		internal int32 mCustomAttributesIdx;
        internal TypeId mBaseType;
        internal TypeId mUnderlyingType;
		internal TypeId mOuterType;
		internal int32 mInheritanceId;
		internal int32 mInheritanceCount;

		internal uint8 mInterfaceSlot;
        internal uint8 mInterfaceCount;        
        internal int16 mMethodDataCount;
        internal int16 mPropertyDataCount;
        internal int16 mFieldDataCount;
        internal int16 mConstructorDataCount;

        internal void* mInterfaceDataPtr;
        internal MethodData* mMethodDataPtr;
        internal void* mPropertyDataPtr;
        internal FieldData* mFieldDataPtr;
        internal void* mConstructorDataPtr;
        internal void** mCustomAttrDataPtr;


        public override int32 InstanceSize
        {
            get
            {
                return mInstSize;
            }
        }

		public override int32 InstanceAlign
		{
		    get
		    {
		        return mInstAlign;
		    }
		}

		public override int32 InstanceStride
		{
		    get
		    {
		        return Math.Align(mInstSize, mInstAlign);
		    }
		}

        public override TypeInstance BaseType
        {
            get
            {
                return (TypeInstance)Type.GetType(mBaseType);
            }
        }

		public override TypeInstance OuterType
		{
		    get
		    {
		        return (TypeInstance)Type.GetType(mOuterType);
		    }
		}

		public override Type UnderlyingType
		{
		    get
		    {
		        return Type.GetType(mUnderlyingType);
		    }
		}

		public override int32 FieldCount
		{
			get
			{
				return mFieldDataCount;
			}
		}

        public override bool IsSubtypeOf(Type checkBaseType)
		{
		    TypeInstance curType = this;
		    while (true)
		    {
		        if (curType == checkBaseType)
		            return true;
		        if (curType.mBaseType == 0)
		            return false;
		        curType = (TypeInstance)Type.GetType(curType.mBaseType);
		    }
		}

        public override void GetFullName(String strBuffer)
        {
			if (mTypeFlags.HasFlag(TypeFlags.Tuple))
			{
				strBuffer.Append('(');
				for (int fieldIdx < mFieldDataCount)
				{
					if (fieldIdx > 0)
						strBuffer.Append(", ");
					GetType(mFieldDataPtr[fieldIdx].mFieldTypeId).GetFullName(strBuffer);
				}
				strBuffer.Append(')');
			}
			else
			{
				if (mOuterType != 0)
				{
					GetType(mOuterType).GetFullName(strBuffer);
					strBuffer.Append(".");
				}
				else
				{
					if (!String.IsNullOrEmpty(mNamespace))
		            	strBuffer.Append(mNamespace, ".");
				}
				
				strBuffer.Append(mName);
			}
        }

        public override void GetName(String strBuffer)
        {
            strBuffer.Append(mName);
        }

		public override FieldInfo? GetField(String fieldName)
		{
		    for (int32 i = 0; i < mFieldDataCount; i++)
		    {
		        FieldData* fieldData = &mFieldDataPtr[i];
		        if (fieldData.mName == fieldName)
		            return FieldInfo(this, fieldData);
		    }
		    return null;
		}

		public override FieldInfo.Enumerator GetFields(BindingFlags bindingFlags = cDefaultLookup)
		{
		    return FieldInfo.Enumerator(this, bindingFlags);
		}
    }

	[CRepr, AlwaysInclude(AssumeInstantiated=true)]
	internal class PointerType : Type
	{
		internal TypeId mElementType;

		public override Type UnderlyingType
		{
			get
			{
				return Type.GetType(mElementType);
			}
		}

		public override void GetFullName(String strBuffer)
		{
			UnderlyingType.GetFullName(strBuffer);
			strBuffer.Append("*");
		}
	}

	[CRepr, AlwaysInclude(AssumeInstantiated=true)]
	internal class SizedArrayType : Type
	{
	    internal TypeId mElementType;
		internal int32 mElementCount;

		public override Type UnderlyingType
		{
			get
			{
				return Type.GetType(mElementType);
			}
		}

		public int ElementCount
		{
			get
			{
				return mElementCount;
			}
		}

		public override void GetFullName(String strBuffer)
		{
			UnderlyingType.GetFullName(strBuffer);
			strBuffer.Append("[");
			mElementCount.ToString(strBuffer);
			strBuffer.Append("]");
		}
	}

    [CRepr, AlwaysInclude(AssumeInstantiated=true)]
    internal class UnspecializedGenericType : TypeInstance
    {
        [CRepr, AlwaysInclude]
        internal struct GenericParam
        {
            internal String mName;
        }

        internal uint8 mGenericParamCount;
    }

    // Only for resolved types
    [CRepr, AlwaysInclude(AssumeInstantiated=true)]
    internal class SpecializedGenericType : TypeInstance
    {
        internal TypeId mUnspecializedType;
        internal TypeId* mResolvedTypeRefs;

		public override int32 GenericParamCount
		{
			get
			{
				var unspecializedTypeG = Type.GetType(mUnspecializedType);
				var unspecializedType = (UnspecializedGenericType)unspecializedTypeG;
				return unspecializedType.mGenericParamCount;
			}
		}

		public Type GetGenericArg(int argIdx)
		{
			return mResolvedTypeRefs[argIdx].ToType();
		}

		public override void GetFullName(String strBuffer)
		{
			var unspecializedTypeG = Type.GetType(mUnspecializedType);
			var unspecializedType = (UnspecializedGenericType)unspecializedTypeG;
			base.GetFullName(strBuffer);

			int32 outerGenericCount = 0;
			var outerType = OuterType;
			if (outerType != null)
				outerGenericCount = outerType.GenericParamCount;

			if (outerGenericCount < unspecializedType.mGenericParamCount)
			{
				strBuffer.Append('<');
				for (int i = outerGenericCount; i < unspecializedType.mGenericParamCount; i++)
				{
					if (i > 0)
						strBuffer.Append(", ");
					Type.GetType(mResolvedTypeRefs[i]).GetFullName(strBuffer);
				}
				strBuffer.Append('>');
			}
		}
    }

    [CRepr, AlwaysInclude(AssumeInstantiated=true)]
    internal class ArrayType : SpecializedGenericType
    {
        internal int32 mElementSize;
        internal uint8 mRank;
        internal uint8 mElementsDataOffset;

		public override void GetFullName(String strBuffer)
		{
			Type.GetType(mResolvedTypeRefs[0]).GetFullName(strBuffer);
			strBuffer.Append('[');
			for (int commaNum < mRank - 1)
				strBuffer.Append(',');
			strBuffer.Append(']');
		}
    }

    public enum TypeFlags : uint32
    {
        UnspecializedGeneric    = 0x0001,
        SpecializedGeneric      = 0x0002,
        Array                   = 0x0004,

        Object                  = 0x0008,
        Boxed                   = 0x0010,
        Pointer                 = 0x0020,
        Struct                  = 0x0040,
        Primitive               = 0x0080,
		TypedPrimitive          = 0x0100,
		Tuple					= 0x0200,
		Nullable				= 0x0400,
		SizedArray				= 0x0800,
		Splattable				= 0x1000,
		Union					= 0x2000,
		Sys_PointerT			= 0x4000, // System.Pointer<T>
		WantsMark				= 0x8000,
		Delegate				= 0x10000,
		HasDestructor			= 0x20000,
    }

    public enum FieldFlags : uint16
    {
        // member access mask - Use this mask to retrieve accessibility information.
        FieldAccessMask         = 0x0007,
        PrivateScope            = 0x0000,    // Member not referenceable.
        Private                 = 0x0001,    // Accessible only by the parent type.  
        FamAndProject           = 0x0002,    // Accessible by sub-types only in this Assembly.
        Project                 = 0x0003,    // Accessibly by anyone in the Assembly.
        Family                  = 0x0004,    // Accessible only by type and sub-types.    
        FamOrProject            = 0x0005,    // Accessibly by sub-types anywhere, plus anyone in assembly.
        Public                  = 0x0006,    // Accessibly by anyone who has visibility to this scope.    
        // end member access mask
    
        // field contract attributes.
        Static                  = 0x0010,     // Defined on type, else per instance.
        InitOnly                = 0x0020,     // Field may only be initialized, not written to after init.
        Const                   = 0x0040,     // Value is compile time constant.
        SpecialName             = 0x0080,     // field is special.  Name describes how.
        EnumPayload				= 0x0100,
		EnumDiscriminator		= 0x0200
    }

	[AllowDuplicates]
	public enum MethodFlags : int16
	{
		MethodAccessMask    	=  0x0007,
		PrivateScope        	=  0x0000,     // Member not referenceable.
		Private             	=  0x0001,     // Accessible only by the parent type.  
		FamANDAssem         	=  0x0002,     // Accessible by sub-types only in this Assembly.
		Assembly            	=  0x0003,     // Accessibly by anyone in the Assembly.
		Family              	=  0x0004,     // Accessible only by type and sub-types.    
		FamORAssem          	=  0x0005,     // Accessibly by sub-types anywhere, plus anyone in assembly.
		Public              	=  0x0006,     // Accessibly by anyone who has visibility to this scope.    
		// end member access mask

		// method contract attributes.
		Static              	=  0x0010,     // Defined on type, else per instance.
		Final               	=  0x0020,     // Method may not be overridden.
		Virtual             	=  0x0040,     // Method virtual.
		HideBySig           	=  0x0080,     // Method hides by name+sig, else just by name.
		CheckAccessOnOverride	=  0x0200,

		// vtable layout mask - Use this mask to retrieve vtable attributes.
		VtableLayoutMask    	=  0x0100,

		ReuseSlot           	=  0x0000,     // The default.
		NewSlot             	=  0x0100,     // Method always gets a new slot in the vtable.
		// end vtable layout mask

		// method implementation attributes.
		Abstract            	=  0x0400,     // Method does not provide an implementation.
		SpecialName         	=  0x0800,     // Method is special.  Name describes how.
		StdCall					=  0x1000,
		FastCall				=  0x2000,
		Mutating				=  0x4000
	}
}
