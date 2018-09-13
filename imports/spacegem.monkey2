
Class SpaceGem Extends Behaviour

	Public
	
	' TODO: Fucking hell, what a disaster
	
		Function Create:SpaceGem (in_model:Model, box:Boxf, x:Float, y:Float, z:Float)

			' TODO: THIS IS STUPID! Create model here!
			
			If Not CollectedSound Then CollectedSound = Sound.Load (ASSET_PREFIX_AUDIO + "spacegem_collected.ogg")
			If Not CollectedSound Then Abort ("SpaceGem: Failed to load collected audio!")

			in_model.Move (x, y + box.Height * 3.0, z)
			in_model.Alpha = 0.5
'			
			' Ho-ly! I can... see through... time!
			
			Cast <PbrMaterial> (Cast <Model> (in_model).Material).MetalnessFactor = 1.0
		
			Local sg:SpaceGem = New SpaceGem (in_model)
			
				' TODO: FUCKING RETARDED
				
				sg.AddRigidBody (box)
				sg.model = in_model
				
			Game.CurrentLevel.SpaceGemAdded ()

			Return sg
			
		End
		
		Method New (entity:Entity)
			
			Super.New (entity)
	
			AddInstance ()
	
		End
		
		Method AddRigidBody (box:Boxf)
	
			collider = Entity.AddComponent <BoxCollider> ()
			collider.Box = box
	
			body = Entity.AddComponent <RigidBody> ()
			body.Mass = 1.0
			body.AngularDamping = 0.0
			body.btBody.setCollisionFlags (bullet.btCollisionObject.CF_NO_CONTACT_RESPONSE)
	
			body.CollisionMask	= COLL_GEM
			body.CollisionGroup	= GEM_COLLIDES_WITH
			
			body.ApplyTorqueImpulse (New Vec3f (1.0, 2.0, 4.0))
		
			body.Collided += Lambda (other_body:RigidBody)
	
				If Not collected
	
					Cast <PbrMaterial> (Cast <Model> (Entity).Material).ColorFactor = Color.Lime
					
					Entity.Scale = Entity.Scale * 1.2
	
					collected_channel = CollectedSound.Play (False)
					collected_channel.Volume = 0.25
					
					Game.CurrentLevel.SpaceGemRemoved ()
	
					collected = True
					
				Endif
	
			End
	
		End
		
		Method OnUpdate (elapsed:Float) Override
		
			Entity.GetComponent <RigidBody> ()?.ApplyForce (Game.GameScene.World.Gravity * New Vec3f (1.0, -1.0, 1.0))	
	
			If collected
	
				Local secs_per_frame:Float = 1000.0 / App.FPS
				
				Entity.Alpha = Entity.Alpha - (THOUSANDTH * secs_per_frame) * 0.25 ' Don't get why 0.25 scales this to 1 sec!
				
				If Entity.Alpha > THOUSANDTH
					body.ApplyForce (Game.GameScene.World.Gravity * New Vec3f (1.0, -5.0, 1.0)) ' Boost upwards...
				Else
					Destroy ()
				Endif
				
			Endif
			
		End

		' TODO: STUPID STUPID STUPID
		
		Method GetSpaceGemModel:Model ()
			Return model
		End
	
		' TODO: STUPID STUPID STUPID

		Method SetSpaceGemModel (new_model:Model)
				model = new_model
		End
	
		' TODO: STUPID STUPID STUPID

		Method GetSpaceGemBody:RigidBody ()
			Return body
		End
	
	Private

		Const ASSET_PREFIX_AUDIO:String = "asset::audio/common/"
	
		Global CollectedSound:Sound
		
		Field collected_channel:Channel
	
		Field model:Model ' TODO: FUCKING STUPID IDIOT
		
		Field body:RigidBody			' Bullet physics body
		Field collider:BoxCollider		' Bullet physics collider
	
		Field collected:Bool = False
		
End
