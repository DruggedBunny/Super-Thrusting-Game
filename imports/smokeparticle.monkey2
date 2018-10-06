
Class SmokeParticle Extends Behaviour

#Rem

		Local smat:SpriteMaterial = New SpriteMaterial ()
		smat.ColorFactor = Color.White
		
		sprite = New Sprite (smat)
		
		sprite.Move (0, 0, 1)
		
#End

	Public
	
		Function Create:SmokeParticle (rocket:Rocket, thrust:Vec3f)

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

			Local TMP_use_sprites:Bool = True
			
			Local sp:SmokeParticle
			
			If Not TMP_use_sprites
						
				' TODO: Temp model, need something better, maybe sprites...
	
				Local model:Model				= Model.CreateBox (New Boxf (-size * 0.5, -size * 0.5, -size * 0.5, size * 0.5, size * 0.5, size * 0.5), 2, 2, 2, mat, rocket.RocketModel)
	'			
					model.Move (Rnd (-1.0, 1.0), -Rnd (2.5, 3.5), Rnd (-1.0, 1.0))
	'
					model.Parent				= Null
					model.Alpha					= 1.0

				sp		= New SmokeParticle (model)

			Else

				Local smat:SpriteMaterial		= New SpriteMaterial ()
			
					smat.ColorFactor			= col
					smat.AlphaDiscard			= 0.1
					
				Local sprite:Sprite = New Sprite (smat, rocket.RocketModel)
			
					sprite.Move (Rnd (-0.1, 0.1), Rnd (-2.1, -2.5), Rnd (-0.1, 0.1))
					
					Local sprite_scale:Float	= Rnd (0.05, 0.25)
					
					sprite.Scale				= New Vec3f (sprite_scale, sprite_scale, sprite_scale)
					sprite.Parent				= Null
					sprite.Alpha				= 1.0 ' TMP

				sp								= New SmokeParticle (sprite)

			Endif
			
			sp.thrust							= thrust

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
	
				body.CollisionMask		= COLL_NOTHING'COLL_SMOKE
				'body.CollisionGroup		= SMOKE_COLLIDES_WITH
			
				body.ApplyImpulse (thrust)
			
				thrust					= Null ' Don't need to keep temp Vec3f object
				
		End
		
		Method OnUpdate (elapsed:Float) Override
			
			If Game.GameState.GetCurrentState () <> States.Paused
			
				Entity.Alpha = Entity.Alpha * 0.95 ' TODO: Needs adjusting for framerate!
				
				If Entity.Alpha < 0.1
					Entity.Destroy ()
				Endif
			
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
