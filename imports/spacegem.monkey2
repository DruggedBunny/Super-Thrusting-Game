
Class SpaceGem Extends Behaviour

	Public
	
		Function Create:SpaceGem (pad_model:Model, color:Color)

			Local size:Float	= pad_model.Mesh.Bounds.Width * 0.5
			
			Local box:Boxf		= New Boxf (-size * 0.5, -size * 0.5, -size * 0.5, size * 0.5, size * 0.5, size * 0.5)
			
			Local model:Model	= Model.CreateBox (box, 1, 1, 1, New PbrMaterial (color))
			
				model.Name		= "SpaceGem [spawned at " + Time.Now () + "]"
				model.Alpha		= 0.5
			
				' Place at pad position plus 3 x gem height...
				
				model.Move (pad_model.X, pad_model.Y + (box.Height * 3.0), pad_model.Z)
				
				' Hmm, maybe later (ouch)...
				
				' Cast <PbrMaterial> (Cast <Model> (model).Material).MetalnessFactor = 1.0
			
			Local sg:SpaceGem	= New SpaceGem (model)
			
				'sg.model		= model

				sg.AddRigidBody (box)
				
			Game.CurrentLevel.SpaceGemAdded ()

			Return sg
			
		End
		
		Function InitSound ()

			If Not CollectedSound Then CollectedSound = Sound.Load (ASSET_PREFIX_AUDIO + "spacegem_collected.ogg")
			
				If Not CollectedSound Then Abort ("SpaceGem: Failed to load collected audio!")

		End

		Method New (entity:Entity)
			
			Super.New (entity)
			AddInstance ()
	
		End
		
		Method AddRigidBody (box:Boxf)
	
			Local collider:BoxCollider	= Entity.AddComponent <BoxCollider> ()
			collider.Box				= box
	
			Local body:RigidBody		= Entity.AddComponent <RigidBody> ()

				body.Mass				= 1.0
				body.AngularDamping		= 0.0
	
				body.CollisionMask		= COLL_GEM
				body.CollisionGroup		= GEM_COLLIDES_WITH

				body.btBody.setCollisionFlags (bullet.btCollisionObject.CF_NO_CONTACT_RESPONSE)
			
				body.ApplyTorqueImpulse (New Vec3f (1.0, 2.0, 4.0))
		
				body.Collided += Lambda (other_body:RigidBody)
		
					If Not collected
		
						Cast <PbrMaterial> (Cast <Model> (Entity).Material).ColorFactor = Color.Lime
						
						Entity.Scale				= Entity.Scale * 1.2
		
						collected_channel			= CollectedSound.Play (False)
						collected_channel.Volume	= 0.25
						
						collected					= True
						
						Game.CurrentLevel.SpaceGemRemoved ()
		
					Endif
		
				End
	
		End
		
		Method OnUpdate (elapsed:Float) Override
		
			SpaceGemBody.ApplyForce (Game.GameScene.World.Gravity * New Vec3f (1.0, -1.0, 1.0))	
	
			If collected
	
				Local secs_per_frame:Float = 1000.0 / App.FPS
				
				Entity.Alpha = Entity.Alpha - (THOUSANDTH * secs_per_frame) * 0.25 ' Don't get why 0.25 scales this to 1 sec!
				
				If Entity.Alpha > THOUSANDTH
					SpaceGemBody.ApplyForce (Game.GameScene.World.Gravity * New Vec3f (1.0, -5.0, 1.0)) ' Boost upwards...
				Else
					Game.CurrentLevel.RemoveSpaceGem (Self)
					Destroy ()
				Endif
				
			Endif
			
		End

		Property SpaceGemModel:Model ()
			Return Cast <Model> (Entity)
		End
		
		Property SpaceGemBody:RigidBody ()
			Return Entity.GetComponent <RigidBody> ()
		End
	
	Private

		Const ASSET_PREFIX_AUDIO:String = "asset::audio/common/"
	
		Global CollectedSound:Sound
		
		Field collected_channel:Channel
	
		Field collected:Bool = False
		
End
