
' -----------------------------------------------------------------------------
' What is it?
' -----------------------------------------------------------------------------

Class DummyOrb

	Public
	
		Property DummyOrbModel:Model ()
			Return model
		End
		
		Function InitSound ()
	
			CollectedSound = Sound.Load (ASSET_PREFIX_AUDIO + "orb_collected.ogg")
			
				If Not CollectedSound Then Abort ("DummyOrb: InitSound failed to load orb-collected audio!")
				
		End

		Method FadeAudio (rate:Float)
		
			collected_fader.Level = collected_fader.Level - rate

			If collected_fader.Level < 0.0 Then collected_fader.Level = 0.0

		End
		
		Method New (x:Float, y:Float, z:Float)
	
			Local radius:Float = 2.0
			
			Local mat:PbrMaterial		= New PbrMaterial (Color.HotPink, 0.05, 0.0)
				
			model						= Model.CreateSphere (radius, 8, 8, mat)
	
				model.Move (x, y, z)
	
				model.Alpha				= 0.5
				model.Name				= "Dummy Orb [spawned at " + Time.Now () + "]"
				
			collider					= model.AddComponent <SphereCollider> ()
			collider.Radius				= radius
			
			body						= model.AddComponent <RigidBody> ()
	
'				Game.PhysStack.Add (body)
				
				body.Mass				= 0.0
				body.btBody.setCollisionFlags (bullet.btCollisionObject.CF_NO_CONTACT_RESPONSE)
					
				body.CollisionMask		= COLL_DUMMY_ORB
				body.CollisionGroup		= DUMMY_ORB_COLLIDES_WITH
		
				body.Collided += Lambda (other_body:RigidBody)
	
					collected_fader.Paused = False
		
					ResetCollectedAudio ()
					
					' Start portal lock ring spinning! No damping on this body, so just keeps going...
										
					Game.CurrentLevel.Lock.Ring.StartRotation ()
					
					Destroy ()
	
				End
	
				glow = New Light (model)
				
					glow.Type				= LightType.Point
					glow.CastsShadow		= False
					glow.Color				= Color.HotPink * 8.0
					glow.Range				= 50.0
				
				ResetCollectedAudio ()
				
		End
		
	Private
	
		Field model:Model
		Field body:RigidBody
		Field collider:SphereCollider
		Field glow:Light
		
		Method Destroy ()
		
			model.Destroy	()
			body.Destroy	()
			glow.Destroy	()
						
			Game.CurrentLevel.Dummy = Null
			
		End
	
		Method ResetCollectedAudio ()
	
			collected_fader					= Game.MainMixer.AddFader ("DummyOrb: Collected", CollectedSound.Play (False))
			collected_fader.Level			= COLLECTED_VOLUME_MAX
			collected_fader.Channel.Rate	= collected_fader.Channel.Rate * 0.75 ' Pitched slightly up from rocket boom
			collected_fader.Paused			= True
	
		End
	
		Const COLLECTED_VOLUME_MAX:Float = 0.5
	
		Global CollectedSound:Sound

		Field collected_fader:Fader
		
End
