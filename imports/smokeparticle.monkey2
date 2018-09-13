
Class SmokeParticle Extends Behaviour

	Public
	
		Function Create:SmokeParticle (rocket:Rocket, thrust:Vec3f = New Vec3f (1.0, 1.0, 1.0))

			Local col:Color
			
			Select Int (Rnd (5))
			
				Case 0
					col = Color.Black
				Case 1
					col = Color.White
				Case 2
					col = Color.Red
				Case 3
					col = Color.Orange
				Case 4
					col = Color.Yellow
					
			End
			
			Local size:Float			= 0.5
			Local mat:PbrMaterial		= New PbrMaterial (col)
			
			' TODO: Temp model, need something better, maybe sprites...

			Local model:Model			= Model.CreateBox (New Boxf (-size * 0.5, -size * 0.5, -size * 0.5, size * 0.5, size * 0.5, size * 0.5), 2, 2, 2, mat, rocket.RocketModel)
			
				model.Move (Rnd (-1.0, 1.0), -Rnd (2.5, 3.5), Rnd (-1.0, 1.0))

				model.Parent			= Null
				model.Alpha				= 1.0

			Local sp:SmokeParticle		= New SmokeParticle (model)

				sp.thrust				= thrust

			Return sp
			
		End

	Private
	
		Method New (entity:Entity)
		
			Super.New (entity)
			AddInstance ()
			
		End

		Method OnStart () Override

			Local collider:BoxCollider	= Entity.AddComponent <BoxCollider> () ' Unexpected: Collider needs to be added BEFORE applying impulse!

			Local body:RigidBody		= Entity.AddComponent <RigidBody> ()
	
				body.Mass				= 0.01
				body.Restitution		= 0.5
				body.Friction			= 0.1
	
				body.CollisionMask		= COLL_SMOKE
				body.CollisionGroup		= SMOKE_COLLIDES_WITH
			
				body.ApplyImpulse (thrust)
			
				thrust					= Null ' Don't need to keep temp Vec3f object
				
		End
		
		Method OnUpdate (elapsed:Float) Override
			
			Entity.Alpha = Entity.Alpha * 0.9 ' TODO: Needs adjusting for framerate!
			
			If Entity.Alpha < 0.1
				Entity.Destroy ()
			Endif
			
		End
	
		' Rocket thrust level -- need to temp-store here as OnStart can't be passed custom params!
		
		Field thrust:Vec3f
		
		' TODO?
		
'		Global PrototypeModel:Model

'			If Not PrototypeModel
'				PrototypeModel			= Model.CreateBox (New Boxf (-size * 0.5, -size * 0.5, -size * 0.5, size * 0.5, size * 0.5, size * 0.5), 2, 2, 2, New PbrMaterial (Color.Magenta))
'				PrototypeModel.Visible	= False

'				model = Proto... .Copy ()
'				model.Material[0] = ...

				' Oh... can't replace material on a copy!
				' https://github.com/blitz-research/monkey2/issues/424
				
'			Endif
			
End
