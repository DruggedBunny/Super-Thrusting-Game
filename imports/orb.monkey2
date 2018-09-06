
Class Orb

	Public
	
		Method New (rocket:Rocket, distance:Float, mass:Float = 1.0)
	
			Local mat:PbrMaterial = New PbrMaterial (Color.HotPink)
			
			model		= Model.CreateSphere (0.75, 8, 8, mat)
			
			model.Name	= "Orb [spawned at " + Time.Now () + "]"
						
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
			
			model.Position				= rocket.RocketModel.Position + New Vec3f (0.0, -distance, 0.0)
			
				model.Alpha				= 1'0.75
'				model.Material.BlendMode = BlendMode.Additive
				Cast <PbrMaterial> (model.Material).MetalnessFactor = 1.0
				model.CastsShadow		= True
			
			glow = New Light (model)
			
				glow.Type				= LightType.Point ' Very slow to init!
				glow.CastsShadow		= False'True ' TODO - may be fixed in future
				glow.Color				= Color.HotPink * 8.0
				glow.Range				= 10.0
			
			body						= model.AddComponent <RigidBody> ()
			collider					= model.AddComponent <SphereCollider> ()
	
				body.Mass				= mass
				body.Restitution		= 0.1
				body.AngularDamping		= 0.45
				body.LinearVelocity		= rocket.RocketBody.LinearVelocity
				
				body.CollisionMask		= COLL_ORB
				body.CollisionGroup		= ORB_COLLIDES_WITH
	
			constraint					= model.AddComponent <BallSocketJoint> ()
			
			' constraint.Pivot at ROCKET position (upwards by 'distance')...
			
			' BALL SOCKET
			
			constraint.Pivot			= New Vec3f (0.0, distance, 0.0)
	
			' constraint.ConnectedPivot at ORB position (0, 0, 0 relative to orb)...
			
			' FIXED POINT
			
			' But constraint.ConnectedBody is the ROCKET body here... all a matter of
			' perspective, since you could have the ball socket (Pivot) at orb position
			' instead...
			
			constraint.ConnectedBody	= rocket.RocketBody
			
			' Visual connection between orb and rocket...
			
			joint = Model.CreateCylinder (0.05, distance, Axis.Y, 8, New PbrMaterial (Color.Yellow), model)
			
				joint.Alpha = 0.1
				joint.Move (0.0, distance * 0.5, 0.0)

				joint.Name = "Orb/Rocket joint"
				
			body.Collided += Lambda (other_body:RigidBody) ' Other colliding body
				
				If constraint And Abs (body.LinearVelocity.Length - last_vel.Length) < 9.5 ' Resilient little bugger
					Return
				Endif
				
				If Not exploded Then Explode ()
	
			End

		End

		Method Explode ()
	
			PhysicsTri.Explode (model, body)
			
			model.Visible = False
			
			DetachFromRocket ()
	
			exploded = True
			
			BoomChannel.Paused = False
			
		End
		
		Method Destroy:Void ()
			model?.Destroy ()
			body?.Destroy ()
			BoomChannel.Stop ()
		End
	
		' Called also from Rocket upon crashing...
		
		Method DetachFromRocket ()
			joint?.Destroy ()
			joint = Null
			constraint?.Destroy ()
			constraint = Null
			Game.Player.CurrentOrb = Null
		End
	
		Function InitOrbSound ()
			Boom = Sound.Load (ASSET_PREFIX_AUDIO + "boom.ogg")
			BoomChannel = Boom.Play (False)
			BoomChannel.Volume = BOOM_VOLUME_MAX
			BoomChannel.Rate = BoomChannel.Rate * 0.75 ' Pitched slightly up from rocket boom
			BoomChannel.Paused = True
		End
		
	Private
	
		Const ASSET_PREFIX_AUDIO:String = "asset::audio/common/"
		Const BOOM_VOLUME_MAX:Float = 0.5
			
		Field model:Model
		Field body:RigidBody
		Field collider:SphereCollider
	
		Field last_vel:Vec3f
			
		Field joint:Model
		
		Field glow:Light
		
		Field constraint:BallSocketJoint
	
		Field exploded:Bool = False

		' This must be a TODO...
		
		Global Boom:Sound
		Global BoomChannel:Channel
					
End

Class OrbBehaviour Extends Behaviour
	
	Field orb:Orb
	
	Method New (entity:Entity)
		
		Super.New (entity)
		
		AddInstance ()

	End
	
	Method OnBeginUpdate () Override
		orb.last_vel = orb.body.LinearVelocity
	End
	
End
