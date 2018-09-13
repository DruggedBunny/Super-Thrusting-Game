
Class DummyOrb

	Field model:Model
	Field body:RigidBody
	Field collider:SphereCollider
	Field glow:Light
	
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

				CollectedChannel.Paused = False
	
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
	
	Method Destroy ()
	
		model.Destroy	()
		body.Destroy	()
		glow.Destroy	()
					
		Game.CurrentLevel.Dummy = Null
		
	End

	Method ResetCollectedAudio ()

		CollectedChannel		= Collected.Play (False)
		CollectedChannel.Volume	= COLLECTED_VOLUME_MAX
		CollectedChannel.Rate	= CollectedChannel.Rate * 0.75 ' Pitched slightly up from rocket boom
		CollectedChannel.Paused	= True

	End

	Function InitDummyOrbSound ()

		Collected = Sound.Load (ASSET_PREFIX_AUDIO + "orb_collected.ogg")
		
		If Not Collected Then Abort ("DummyOrb: InitDummyOrbSound failed to load orb-collected audio!")
			
	End
	
	Const ASSET_PREFIX_AUDIO:String = "asset::audio/common/"
	Const COLLECTED_VOLUME_MAX:Float = 0.5

	Global Collected:Sound
	Global CollectedChannel:Channel
	
End
