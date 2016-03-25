package;

@:build(flixel.system.FlxAssets.buildFileReferences("assets", true))
class AssetPaths {
	public static inline var IMAGE_RES	= "assets/images/res.png";
	public static inline var DATA_MAPDATA	= "assets/data/mapdata.txt";
}

class GameCommon{
	public static inline var ResSize 		: Int = 16;
	public static inline var MapChip_None	: Int = 0;
	public static inline var MapChip_Normal	: Int = 1;
	public static inline var MapChip_LT		: Int = 2;
	public static inline var MapChip_RT		: Int = 3;
	public static inline var MapChip_LB		: Int = 4;
	public static inline var MapChip_RB		: Int = 5;
	public static inline var MapChip_Max	: Int = 6;
	
	public static inline var MapChip_Raser	: Int = 6;
	public static inline var MapChip_Player	: Int = 7;
	public static inline var MapChip_Dir	: Int = 8;
	public static inline var MapChip_Enemy	: Int = 9;
	
}

enum E_RES_TYPE{
	E_RES_TYPE_NONE;
	E_RES_TYPE_UL;
	E_RES_TYPE_UR;
	E_RES_TYPE_DL;
	E_RES_TYPE_DR;
	E_RES_TYPE_LASER;
}

