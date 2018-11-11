
' -----------------------------------------------------------------------------
' What is it?
' -----------------------------------------------------------------------------

Class RocketParticle Extends Behaviour

	Public

		Function Create:RocketParticle (rocket:Rocket, thrust:Vec3f, size:Float, fadeout:Float = 0.95)

			If Not ParticleSprite

				ParticleSprite			= New Sprite ()
				ParticleSprite.Color	= Color.White
				ParticleSprite.Visible	= False

			Endif
			
			Local sprite:Sprite = ParticleSprite.Copy (rocket.RocketModel)'New Sprite (rocket.RocketModel)
		
				sprite.Move (Rnd (-0.1, 0.1), Rnd (-2.1, -2.5), Rnd (-0.1, 0.1))
				
				sprite.Parent				= Null
				sprite.Color				= Color.White
				
				sprite.Visible				= True
				
				Local spark:Bool = False
				
				If Rnd (1.0) > 0.9
					size = Rnd (0.05, 0.095)
					thrust = thrust * New Vec3f (2.5, 3.33, 2.5)
					spark = True
				Endif
				
				sprite.Scale				= New Vec3f (size, size, 1.0)
				sprite.Alpha				= 1.0
				sprite.CastsShadow			= False
				
			Local sp:RocketParticle			= New RocketParticle (sprite)
			
				sp.thrust					= thrust
				sp.update_fader				= fadeout
				sp.spark					= spark
				
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
' No Boxf!
				body.Mass				= 0.01
				body.Restitution		= 0.5
				body.Friction			= 0.1
	
				body.CollisionMask		= COLL_NOTHING
			
				body.ApplyImpulse (thrust)
			
				thrust					= Null ' Don't need to keep temp Vec3f object
				
				smoke_scaler = 1.0 + Rnd (0.033)
				
		End
		
		Method OnUpdate (elapsed:Float) Override
			
			If Game.GameState.GetCurrentState () <> States.Paused
			
				Select Int (color_change * 5.0)

					Case 0
						Entity.Color = Color.Black
					Case 1
						Entity.Color = Color.Red
					Case 2
						Entity.Color = Color.Orange
					Case 3
						Entity.Color = Color.Yellow
					Case 4
						Entity.Color = Color.White
				End

				Entity.GetComponent <RigidBody> ().LinearDamping = FrameStretch (1.0 - color_change, elapsed)

				If Entity.Color = Color.Black

					If Not TMP_LeaveTrail
				
						Entity.Alpha = Entity.Alpha * FrameStretch (0.96, elapsed)
						Entity.Scale = Entity.Scale * FrameStretch (smoke_scaler, elapsed)
						
						Entity.GetComponent <RigidBody> ().ApplyForce (New Vec3f (0.0, 0.15, 0.0))

						If Entity.GetComponent <RigidBody> ().LinearDamping > 0.999
							Entity.Destroy ()
						Endif

					Else
					
						Local sprite:Sprite = ParticleSprite.Copy (Entity)
	
							sprite.Parent				= Null
							sprite.Scale				= Entity.Scale
							sprite.Alpha				= 1.0
							sprite.Visible				= True
							
							Entity.Destroy ()

					Endif

				Else
					If spark
						color_change = color_change * FrameStretch (1.025 * update_fader, elapsed)
					Else
						color_change = color_change * FrameStretch (update_fader, elapsed)
					Endif
				End
				
			Endif
			
		End
	
		Global ParticleSprite:Sprite

		Global TMP_LeaveTrail:Bool = False
		
		' Need to temp-store stuff here as OnStart can't be passed custom params!
		
		Field thrust:Vec3f
		Field update_fader:Float
		Field color_change:Float = 0.99
		Field spark:Bool
		Field smoke_scaler:Float
		
End
