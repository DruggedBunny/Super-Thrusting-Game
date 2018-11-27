
' -----------------------------------------------------------------------------
' What is it?
' -----------------------------------------------------------------------------

' A physics-based 3D sprite particle, generated in the event of an explosion.

' TODO: Still WIP, as Sprite isn't fully working -- shouldn't need to create
' materials, instead just changing colour/alpha directly. Using separate
' materials like this prevents mojo3d from 'batching' sprites together
' for greater efficiency.

' Above reported at https://github.com/blitz-research/monkey2/issues/434#issuecomment-432054239

Class ExplosionParticle Extends Behaviour

	Public
	
		Function Create:ExplosionParticle (model:Model, thrust:Vec3f, size:Float = 0.5, fadeout:Float = 0.975)

			If Not ParticleSprite

				ParticleSprite			= New Sprite ()
				ParticleSprite.Color	= Color.White
				ParticleSprite.Visible	= False
				ParticleSprite.Name		= "ExplosionParticle sprite"

			Endif
			
			Local sprite:Sprite = ParticleSprite.Copy (model)'New Sprite (SpriteMat [Int (Rnd (5))], model)
		
				sprite.Parent				= Null
				sprite.Scale				= New Vec3f (size, size, size)
				sprite.Alpha				= 1.0 ' TMP
				sprite.Visible				= True
				sprite.Name					= "ExplosionParticle sprite [copy]"
				
				Select Int (Rnd (5))
					Case 0
						sprite.Color = Color.Black
					Case 1
						sprite.Color = Color.Red
					Case 2
						sprite.Color = Color.Orange
					Case 3
						sprite.Color = Color.Yellow
					Case 4
						sprite.Color = Color.White
				End

			Local sp:ExplosionParticle		= New ExplosionParticle (sprite)
			
				sp.thrust					= thrust
				sp.update_fader				= fadeout

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

'				Game.PhysStack.Add (body)

				body.Mass				= 0.01
				body.Restitution		= 0.5
				body.Friction			= 0.1
	
				body.CollisionMask		= COLL_NOTHING
			
				body.ApplyImpulse (thrust)
			
				thrust					= Null ' Don't need to keep temp Vec3f object
				
		End
		
		Method OnUpdate (elapsed:Float) Override
			
			If Game.GameState.GetCurrentState () <> States.Paused
			
				' NB. update_fader may be passed in via fadeout param from ExplodeModel!
				
				Entity.Alpha = Entity.Alpha * FrameStretch (update_fader, elapsed)
				
				' Slow particle down (like air resistance)... very dependent on start speed and alpha fade amount...
				
				Entity.GetComponent <RigidBody> ().LinearDamping = FrameStretch (1.0 - Entity.Alpha, elapsed)
				
				If Entity.Alpha < 0.075
					Entity.Destroy ()
				Endif
			
			Endif
			
		End
	
		Global ParticleSprite:Sprite

		Field thrust:Vec3f
		Field update_fader:Float
		
End
