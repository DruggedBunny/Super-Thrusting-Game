
Class DummyOrb

	Public
	
		Function InitSound ()
	
			CollectedSound = Sound.Load (ASSET_PREFIX_AUDIO + "orb_collected.ogg")
			
				If Not CollectedSound Then Abort ("DummyOrb: InitSound failed to load orb-collected audio!")
				
		End

		Method FadeAudio (rate:Float)
		
			collected_channel.Volume	= collected_channel.Volume - rate

			If collected_channel.Volume	< 0.0 Then collected_channel.Volume	= 0.0

		End
		
		Method New (x:Float, y:Float, z:Float)
	
			Local mat:PbrMaterial		= New PbrMaterial (Color.HotPink)
				
			model						= Model.CreateSphere (2.0, 8, 8, mat)
	
				model.Move (x, y, z)
	
				model.Alpha				= 0.5
				model.Name				= "Dummy Orb [spawned at " + Time.Now () + "]"
				
			collider					= model.AddComponent <SphereCollider> ()
	
			body						= model.AddComponent <RigidBody> ()
	
				body.Mass				= 0.0
				body.btBody.setCollisionFlags (bullet.btCollisionObject.CF_NO_CONTACT_RESPONSE)
					
				body.CollisionMask		= COLL_DUMMY_ORB
				body.CollisionGroup		= DUMMY_ORB_COLLIDES_WITH
		
				body.Collided += Lambda (other_body:RigidBody)
	
					collected_channel.Paused = False
		
					ResetCollectedAudio ()			' NB. Playing channel continues independently until done
					
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
	
			collected_channel			= CollectedSound.Play (False)
			collected_channel.Volume	= COLLECTED_VOLUME_MAX
			collected_channel.Rate		= collected_channel.Rate * 0.75 ' Pitched slightly up from rocket boom
			collected_channel.Paused	= True
	
		End
	
		Const ASSET_PREFIX_AUDIO:String = "asset::audio/common/"
		Const COLLECTED_VOLUME_MAX:Float = 0.5
	
		Global CollectedSound:Sound
		Field collected_channel:Channel
		
End
