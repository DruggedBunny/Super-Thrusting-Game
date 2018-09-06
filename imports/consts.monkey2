
#If __TARGET__ = "emscripten"
	Const TRI_SKIPPER:Int = 3 ' Skip every TRI_SKIPPER triangles for speed -- used in model.Collided Lambda
#Else
	Const TRI_SKIPPER:Int = 2
#Endif

' TODO: Smoke particle cleanup after death, not instant delete

' Collision types

Const COLL_NOTHING:Short			= 0
Const COLL_TERRAIN:Short			= 1
Const COLL_ROCKET:Short				= 2
Const COLL_ORB:Short				= 4
Const COLL_SMOKE:Short				= 8
Const COLL_PAD:Short				= 16
Const COLL_TRI:Short				= 32
Const COLL_GEM:Short				= 64
Const COLL_PORTAL:Short				= 128
Const COLL_WALL:Short				= 256
Const COLL_DUMMY_ORB:Short			= 512

' Collision groups

Const TERRAIN_COLLIDES_WITH:Short	= COLL_ROCKET	| COLL_ORB	| COLL_SMOKE	| COLL_TRI
Const ROCKET_COLLIDES_WITH:Short	= COLL_TERRAIN	| COLL_PAD	| COLL_GEM		| COLL_PORTAL | COLL_ROCKET | COLL_WALL | COLL_DUMMY_ORB
Const ORB_COLLIDES_WITH:Short		= COLL_TERRAIN	| COLL_PAD
Const DUMMY_ORB_COLLIDES_WITH:Short	= COLL_ROCKET
Const SMOKE_COLLIDES_WITH:Short		= COLL_TERRAIN	| COLL_PAD
Const PAD_COLLIDES_WITH:Short		= COLL_ROCKET	| COLL_ORB	| COLL_SMOKE	| COLL_TRI
Const TRI_COLLIDES_WITH:Short		= COLL_TERRAIN	| COLL_PAD
Const GEM_COLLIDES_WITH:Short		= COLL_ROCKET
Const PORTAL_COLLIDES_WITH:Short	= COLL_ROCKET
Const WALL_COLLIDES_WITH:Short		= COLL_ROCKET

' Used for FPS stuff...

Const THOUSANDTH:Float = 1.0 / 1000.0

' For radians-based calculations...

Const RadDivider:Float = Pi / 180.0
