
Class Orb Extends Behaviour

	Public
	
		Function Create:Orb (rocket:Rocket, distance:Float, in_mass:Float = 1.0)

			Local mat:PbrMaterial		= New PbrMaterial (Color.HotPink)
			
			Local model:Model			= Model.CreateSphere (0.75, 8, 8, mat, rocket.RocketModel)
			
				model.Move (0.0, -distance, 0.0)

				model.Parent			= Null
				model.Name				= "Orb [spawned at " + Time.Now () + "]"
				model.Alpha				= 1.0
				model.CastsShadow		= True
			
			Local orb:Orb				= New Orb (model)

				orb.mass				= in_mass
				orb.rocket_body			= rocket.RocketBody
				orb.start_vel			= rocket.RocketBody.LinearVelocity
				orb.distance			= distance

			Return orb
			
		End

		Function InitSound ()

			Boom = Sound.Load (ASSET_PREFIX_AUDIO + "boom.ogg")
			
				If Not Boom Then Abort ("Orb: InitOrbSound failed to load boom audio!")
			
		End

		Method FadeAudio (rate:Float)
		
			boom_channel.Volume	= boom_channel.Volume - rate

			If boom_channel.Volume	< 0.0 Then boom_channel.Volume	= 0.0

		End
		
		' May be called also from Rocket.Explode upon crashing...
		
		Method DetachFromRocket ()
		
			joint?.Destroy ()
			constraint?.Destroy ()

			joint					= Null
			constraint				= Null
			
			Game.Player.NullifyOrb ()
			
		End
		
		Method Destroy:Void (play_boom:Bool = True)

			Entity.Destroy ()
			
			If play_boom
				boom_channel.Paused = False
			Endif

			ResetBoomAudio ()			' NB. Playing channel continues independently until done

		End
	
	Private
	
		Const ASSET_PREFIX_AUDIO:String = "asset::audio/common/"
		Const BOOM_VOLUME_MAX:Float = 0.5
		
		' Setup stuff for Create:Orb (), needed as OnStart can't take params...
		
		Field mass:Float
		Field start_vel:Vec3f
		Field distance:Float
		Field rocket_body:RigidBody

		' Required fields for later access...
		
		Field last_vel:Vec3f

		Field joint:Model
		Field constraint:BallSocketJoint
	
		Field exploded:Bool = False
		
		Global Boom:Sound
		Field boom_channel:Channel

		Method New (entity:Entity)
			
			Super.New (entity)
			AddInstance ()
	
		End
		
		Method OnUpdate (elapsed:Float) Override
			last_vel = Entity.GetComponent <RigidBody> ().LinearVelocity
		End
	
		Method OnStart () Override
	
			Local glow:Light				= New Light (Entity)
			
				glow.Type					= LightType.Point	' Very slow to init with shadows on! https://github.com/blitz-research/monkey2/issues/391
				glow.CastsShadow			= False				'True ' TODO - may be fixed in future
				glow.Color					= Color.HotPink * 8.0
				glow.Range					= 10.0
			
			Local collider:SphereCollider	= Entity.AddComponent <SphereCollider> ()

			Local body:RigidBody			= Entity.AddComponent <RigidBody> ()
	
				body.Mass					= mass
				body.Restitution			= 0.1
				body.AngularDamping			= 0.45
				body.LinearVelocity			= start_vel
				
				body.CollisionMask			= COLL_ORB
				body.CollisionGroup			= ORB_COLLIDES_WITH
	
			constraint						= Entity.AddComponent <BallSocketJoint> ()
			
				' constraint.Pivot sits at ROCKET position (located upwards from orb model by 'distance')...
				
				' BALL SOCKET
				
				constraint.Pivot			= New Vec3f (0.0, distance, 0.0)
		
				' constraint.ConnectedPivot sits at ORB position (0, 0, 0 relative to orb model)...
				
				' FIXED CONNECTION
				
				' constraint.ConnectedBody is the ROCKET body here... all a matter of
				' perspective, since you could have the ball socket (Pivot) at orb position
				' instead...
				
				constraint.ConnectedBody	= rocket_body
				
			' Visual connection between orb and rocket...
			
			joint							= Model.CreateCylinder (0.05, distance, Axis.Y, 8, New PbrMaterial (Color.Yellow), Entity)
			
				joint.Move (0.0, distance * 0.5, 0.0)

				joint.Name					= "Orb/Rocket joint [spawned at " + Time.Now () + "]"
				joint.Alpha					= 0.1
				
			body.Collided += Lambda (other_body:RigidBody) ' Other colliding body
				
				If constraint And Abs (body.LinearVelocity.Length - last_vel.Length) < 9.0 ' Resilient little bugger
					Return
				Endif
				
				If Not exploded Then Explode ()

			End

			' Done with this temp object...
			
			start_vel						= Null

			Game.CurrentLevel.ExitPortal.Open ()

			ResetBoomAudio ()

		End

		Method Explode ()
	
			PhysicsTri.Explode (Cast <Model> (Entity), Entity.GetComponent <RigidBody> ())
			
			DetachFromRocket ()
	
			Destroy ()
			
			exploded = True
			
			Game.CurrentLevel.ExitPortal.Close ()
			
		End
		
		Method ResetBoomAudio ()

			boom_channel		= Boom.Play (False)
			boom_channel.Volume	= BOOM_VOLUME_MAX
			boom_channel.Rate	= boom_channel.Rate * 0.75 ' Pitched slightly up from rocket boom
			boom_channel.Paused	= True

		End
		
End

' Position model BEFORE adding physics components; set here
' to rocket position less 'distance' below rocket...

#Rem


	^		ROCKET			constraint.Pivot				This is the BALL socket (at rocket position)
	|
	|
	|		distance
	|
	|
	O		ORB				constraint.ConnectedPivot		This is a FIXED point (at orb position)
	
	
#End
