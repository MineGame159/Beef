using System;
using IDE.Compiler;
namespace BeefLsp;

class SymbolData
{
	public int32 mLocalId = -1;
	public append String mTypeDef;
	public append String mNamespace;
	public int32 mFieldIdx = -1;
	public int32 mMethodIdx = -1;
	public int32 mPropertyIdx = -1;
	public int32 mTypeGenericParamIdx = -1;
	public int32 mMethodGenericParamIdx = -1;

	public void Apply(BfResolvePassData passData)
	{
		if (!mTypeDef.IsEmpty)
			passData.SetSymbolReferenceTypeDef(mTypeDef);
		if (mFieldIdx != -1)
			passData.SetSymbolReferenceFieldIdx(mFieldIdx);
		if (mMethodIdx != -1)
			passData.SetSymbolReferenceMethodIdx(mMethodIdx);
		if (mPropertyIdx != -1)
			passData.SetSymbolReferencePropertyIdx(mPropertyIdx);
		if (mLocalId != -1)
			passData.SetLocalId(mLocalId);
		if (mTypeGenericParamIdx != -1)
			passData.SetTypeGenericParamIdx(mTypeGenericParamIdx);
		if (mMethodGenericParamIdx != -1)
			passData.SetMethodGenericParamIdx(mMethodGenericParamIdx);
		if (!mNamespace.IsEmpty)
			passData.SetSymbolReferenceNamespace(mNamespace);
	}
}