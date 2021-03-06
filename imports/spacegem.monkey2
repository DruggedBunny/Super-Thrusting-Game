
' -----------------------------------------------------------------------------
' What is it?
' -----------------------------------------------------------------------------

Class SpaceGem Extends Behaviour

	Public

		Property Collected:Bool ()
			Return collected
		End
		
		Function Create:SpaceGem (pad_model:Model, color:Color)

			Local size:Float	= pad_model.Mesh.Bounds.Width * 0.5
			
			Local box:Boxf		= New Boxf (-size * 0.5, -size * 0.5, -size * 0.5, size * 0.5, size * 0.5, size * 0.5)
			
			Local model:Model	= Model.CreateBox (box, 1, 1, 1, New PbrMaterial (color, 0.05, 0.0))
			
				model.Name		= "SpaceGem [spawned at " + Time.Now () + "]"
				model.Alpha		= 0.333
			
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

		Method AddRigidBody (box:Boxf)
	
			Local collider:BoxCollider	= Entity.AddComponent <BoxCollider> ()
			
				collider.Box			= box
	
			Local body:RigidBody		= Entity.AddComponent <RigidBody> ()

'				Game.PhysStack.Add (body)

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
		
						collected_fader				= Game.MainMixer.AddFader ("SpaceGem: Collected", CollectedSound.Play (False))
						collected_fader.Level		= 0.25
						
						collected					= True
						
						Game.CurrentLevel.SpaceGemRemoved ()
		
						Game.CurrentLevel.CurrentGemMap.Update ()
		
					Endif
		
				End
	
		End
		
		Property SpaceGemModel:Model ()
			Return Cast <Model> (Entity)
		End
		
		Property SpaceGemBody:RigidBody ()
			Return Entity.GetComponent <RigidBody> ()
		End
	
	Private

		Global CollectedSound:Sound
	
		Field collected:Bool = False
		Field collected_fader:Fader

		Method New (entity:Entity)
			
			Super.New (entity)
			AddInstance ()
	
		End
		
		Method OnUpdate (elapsed:Float) Override
		
			SpaceGemBody.ApplyForce (Game.GameScene.World.Gravity * New Vec3f (1.0, -1.0, 1.0))	
	
			If collected
	
				If Game.GameState.GetCurrentState () <> States.Paused
				
'					Entity.Alpha = Entity.Alpha - (0.005 * elapsed)'Game.Delta)
'					Entity.Alpha = Entity.Alpha - (0.25 * (elapsed))'Game.Delta)
					Entity.Alpha = Entity.Alpha * FrameStretch (0.98, elapsed)
					
					If Entity.Alpha >= 0.0
						SpaceGemBody.ApplyForce (Game.GameScene.World.Gravity * New Vec3f (1.0, -5.0, 1.0)) ' Boost upwards...
					Else
						Game.CurrentLevel.RemoveSpaceGem (Self)
						Destroy ()
					Endif
				
				Endif
				
			Endif
			
		End

End
