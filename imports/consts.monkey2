
' -----------------------------------------------------------------------------
' What is it?
' -----------------------------------------------------------------------------

' A collection of constant values used throughout the game.

' TODO: Currently includes collision constants -- ought to be separated out.
' (Then again, it's MOSTLY collision constants!)

#If __TARGET__ = "emscripten"
	Const TRI_SKIPPER:Int = 3 ' Skip every TRI_SKIPPER triangles for speed -- used in model.Collided Lambda
#Else
	Const TRI_SKIPPER:Int = 2
#Endif

' Model assets path...

Const ASSET_PREFIX_MODEL:String		= "asset::models/common/"

' Audio assets path...

Const ASSET_PREFIX_AUDIO:String = "asset::audio/common/"

' Collision types

Const COLL_NOTHING:Short						= 0
Const COLL_TERRAIN:Short						= 1
Const COLL_ROCKET:Short							= 2
Const COLL_ORB:Short							= 4
Const COLL_PAD:Short							= 8
Const COLL_TRI:Short							= 16
Const COLL_GEM:Short							= 32
Const COLL_PORTAL:Short							= 64
Const COLL_WALL:Short							= 128
Const COLL_DUMMY_ORB:Short						= 256
Const COLL_PORTAL_LOCK_PAD:Short				= 512
Const COLL_PORTAL_LOCK_SPHERE:Short				= 1024
Const COLL_PORTAL_LOCK_SPHERE_COLLIDER:Short	= 2048

' Collision groups

Const TERRAIN_COLLIDES_WITH:Short						= COLL_ROCKET	| COLL_ORB	| COLL_TRI
Const ROCKET_COLLIDES_WITH:Short						= COLL_TERRAIN	| COLL_PAD	| COLL_GEM				| COLL_PORTAL	| COLL_WALL | COLL_DUMMY_ORB		| COLL_PORTAL_LOCK_PAD | COLL_PORTAL_LOCK_SPHERE
Const ORB_COLLIDES_WITH:Short							= COLL_TERRAIN	| COLL_PAD	| COLL_PORTAL_LOCK_PAD	| COLL_WALL		| COLL_PORTAL_LOCK_SPHERE_COLLIDER
Const DUMMY_ORB_COLLIDES_WITH:Short						= COLL_ROCKET
Const SMOKE_COLLIDES_WITH:Short							= COLL_TERRAIN	| COLL_PAD
Const PAD_COLLIDES_WITH:Short							= COLL_ROCKET	| COLL_ORB	| COLL_TRI
Const TRI_COLLIDES_WITH:Short							= COLL_TERRAIN	| COLL_PAD
Const GEM_COLLIDES_WITH:Short							= COLL_ROCKET
Const PORTAL_COLLIDES_WITH:Short						= COLL_ROCKET
Const WALL_COLLIDES_WITH:Short							= COLL_ROCKET	| COLL_ORB
Const PORTAL_LOCK_PAD_COLLIDES_WITH:Short				= COLL_ROCKET	| COLL_ORB
Const PORTAL_LOCK_SPHERE_COLLIDES_WITH:Short			= COLL_ROCKET
Const PORTAL_LOCK_SPHERE_COLLIDER_COLLIDES_WITH:Short	= COLL_ORB

' For radians-based calculations...

Const RAD_DIVIDER:Float = Pi / 180.0
