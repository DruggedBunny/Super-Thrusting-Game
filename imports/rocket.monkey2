
Class Rocket

	Public
		
		Function InitSound ()

			BoostSound	= Sound.Load (ASSET_PREFIX_AUDIO + "boost.ogg")
			AlertSound	= Sound.Load (ASSET_PREFIX_AUDIO + "alert.ogg")
			BoomSound	= Sound.Load (ASSET_PREFIX_AUDIO + "boom.ogg")

			If Not BoostSound	Then Abort ("Rocket: Failed to load boost audio!")
			If Not AlertSound	Then Abort ("Rocket: Failed to load alert audio!")
			If Not BoomSound	Then Abort ("Rocket: Failed to load boom audio!")

		End
		
		Property Alive:Bool ()
			Return Not exploded
		End
		
		Property Fuel:Float ()
			Return fuel
			Setter (amount:Float)
				fuel = amount
		End
		
		Property CurrentOrb:Orb ()
			Return orb
			Setter (torb:Orb)
				orb = torb
		End

		Property RocketBody:RigidBody ()
			Return body
		End
		
		Property RocketModel:Model ()
			Return model
		End
		
		Method New (x:Float, y:Float, z:Float, collision_radius:Float = 1.2, collision_length:Float = 4.0, collision_mass:Float = 10.0)

			model						= Model.Load (ASSET_PREFIX_MODEL + "Rocket_Ship_01.gltf")
	
				If Not model Then Abort ("Rocket: Failed to load rocket model!")
			
				model.Name				= "Rocket [spawned at " + Time.Now () + "]"
			
				Local yoff:Float = 0.15
	
				model.Mesh.FitVertices (New Boxf (-collision_radius, -collision_length * 0.5 - yoff, -collision_radius, collision_radius, collision_length * 0.5 - yoff, collision_radius), False)
			
			Local mat:PbrMaterial		= New PbrMaterial (Color.Silver)

				mat.MetalnessFactor		= 0.85
			
				For Local mat:Material = Eachin model.Materials
					Cast <PbrMaterial> (mat).MetalnessFactor = 1.0
				Next
			
	'		cone vis:
			
			'Local temp:Model = Model.CreateCone (radius, length, Axis.Y, 32, mat, model)
			'temp.Alpha = 0.25
			
			' Important: Position BEFORE adding collider/rigid body!
			
				model.Move (x, y + collision_length * 0.7, z)
	
			' Add collider shape and rigid body...
			
			collider			= model.AddComponent <ConeCollider> ()
		
				collider.Radius		= collision_radius
				collider.Length		= collision_length
	
			body				= model.AddComponent <RigidBody> ()

		 		body.Mass			= collision_mass
				body.Restitution	= 0.1
				
				body.AngularDamping	= 0.95
				body.LinearDamping	= 0.135
				
				body.CollisionMask	= COLL_ROCKET
				body.CollisionGroup	= ROCKET_COLLIDES_WITH
	
			body.Collided += Lambda (other_body:RigidBody) ' Other colliding body
				
				Select other_body.CollisionMask
				
					Case COLL_PAD
					
						' Add landing speed check?
						
						' TODO: Angle!
						
'						If Not landed
'							landed = True ' Can't detect when no longer colliding!
							' Want to play landing 'thump' once
'						Endif
					
						fuel = fuel + 0.25
						
						'refuel_channel.Level = 0.1
						
						If alert_fader.Level
							If fuel > 25.0 Then alert_fader.Level = 0.0
						Endif
						
						If fuel > 100 Then fuel = 100'; refuel_channel.Level = 0.0

						' Allow for slow touchdown...
						
						If Abs (body.LinearVelocity.Length - last_vel.Length) < 5.0
							Return
						Endif
						
						' DIE!! Well, damage, then die if too damaged...
						
						damage = damage + (Abs (body.LinearVelocity.Length - last_vel.Length) * 4.0)
						
						If damage >= 100.0
							If Not exploded Then Explode ()
							damage = 100.0
						Endif
					
					Case COLL_TERRAIN
	
						' Landing speed check... TODO: Angle!
						
						' No fuel, instant explode...
						
						If fuel = 0.0 And Not exploded
							Explode ()
							Return
						Endif
						
						' Allow for slow touchdown...
						
						If Abs (body.LinearVelocity.Length - last_vel.Length) < 3.0 ' WAS: If body.LinearVelocity.Length < 3.0
							Return
						Endif
						
						' DIE!! Well, damage, then die if too damaged...
						
						damage = damage + (Abs (body.LinearVelocity.Length - last_vel.Length) * 4.0)
						
						If damage >= 100.0
							If Not exploded Then Explode ()
							damage = 100.0
						Endif
					
					Case COLL_DUMMY_ORB
					
						CurrentOrb?.Destroy ()
						CurrentOrb = Orb.Create (Self, 10.0, 8.0)
						
				End
				
			End
		
			fuel						= 100.0
			damage						= 0.0
			
			vec_forward					= New Vec3f (torque_factor, 0.0, 0.0)
			vec_backward				= New Vec3f (-torque_factor, 0.0, 0.0)
			vec_left					= New Vec3f (0.0, 0.0, torque_factor)
			vec_right					= New Vec3f (0.0, 0.0, -torque_factor)

			boost_fader					= Game.MainMixer.AddFader ("Rocket: Boost",	BoostSound.Play (True))
			alert_fader					= Game.MainMixer.AddFader ("Rocket: Alert",	AlertSound.Play (True))
			boom_fader					= Game.MainMixer.AddFader ("Rocket: Boom",	BoomSound.Play (False))

			boost_fader.Level			= 0.0
			alert_fader.Level			= 0.0
			boom_fader.Level			= BOOM_VOLUME

			boom_fader.Channel.Paused	= True
			
		End
	
		' Called from Orb.DetachFromRocket...
		
		Method NullifyOrb ()
			CurrentOrb = Null
		End
		
		Method Explode ()
	
			boost_fader.Channel.Paused	= True
			boom_fader.Channel.Paused	= False
			alert_fader.Channel.Paused	= True
			
			PhysicsTri.Explode (model, body)
			
			model.Visible			= False
			
			fuel					= 0.0
	
			CurrentOrb?.DetachFromRocket ()
			CurrentOrb				= Null
			
			exploded				= True
			
		End
		
		Method Control ()

			Local boosting:Bool = False
			
			If fuel ' TODO: Might rearrange to allow hopeless rotating while out of fuel...
			
				' KEYBOARD
				
				If Keyboard.KeyDown (Key.Left)
					PitchLeft (Game.MainCamera, 0.75)
				Endif
		
				If Keyboard.KeyDown (Key.Right)
					PitchRight (Game.MainCamera, 0.75)
				Endif
		
				If Keyboard.KeyDown (Key.Up)
					PitchForward (Game.MainCamera, 0.75)
				Endif
		
				If Keyboard.KeyDown (Key.Down)
					PitchBack (Game.MainCamera, 0.75)
				Endif
		
				If Keyboard.KeyDown (Key.Space)
				
					boosting = True
					
					If boost_fader.Level < BOOST_VOLUME
						boost_fader.Level = boost_fader.Level + 0.05
						If boost_fader.Level > BOOST_VOLUME Then boost_fader.Level = BOOST_VOLUME
					Endif
					
					Boost (0.0, boost_factor, 0.0)

					SmokeParticle.Create (Self, RocketModel.Basis * New Vec3f (Rnd (-0.01, 0.01), -0.025, Rnd (-0.01, 0.01)))
					SmokeParticle.Create (Self, RocketModel.Basis * New Vec3f (Rnd (-0.01, 0.01), -0.025, Rnd (-0.01, 0.01)))
					SmokeParticle.Create (Self, RocketModel.Basis * New Vec3f (Rnd (-0.01, 0.01), -0.025, Rnd (-0.01, 0.01)))
					SmokeParticle.Create (Self, RocketModel.Basis * New Vec3f (Rnd (-0.01, 0.01), -0.025, Rnd (-0.01, 0.01)))
												
					fuel = fuel - (MPG * 0.9)
					If fuel < 25.0 Then alert_fader.Level = ALERT_VOLUME
					
					If fuel < 0.0
						fuel					= 0.0
						boost_fader.Level		= 0.0
						boosting				= False
					Endif
					
				Endif
				
				joy = ValidateJoystick (joy) ' Specifically checks for Xbox pad
	
				' JOYSTICK
				
				If joy And joy.Attached
				
					'Print joy.GetAxis (0) ' Left stick left/right
					'Print joy.GetAxis (1) ' Left stick up/down (-1 = back, +1 = forward)
					
					Local jpitch:Float		= joy.GetAxis (1)
					
					' Pitch scaling:
					
					' Raw input, jpitch, is -1.0 to 1.0...
					
					' Want to multiply lower end of 0.0 to [+/-] 1.0 by 0.5 and upper end by 1.2...
					
					' Multipliers:
					
					Local TEMP_lower:Float	= 0.5
					Local TEMP_upper:Float	= 1.2
					
					Local tpitch:Float		= Abs (jpitch)
					
					If jpitch > 0.05 Then PitchBack (Game.MainCamera, jpitch * TransformRange (tpitch, 0.0, 1.0, TEMP_lower, TEMP_upper))
					If jpitch < -0.05 Then PitchForward (Game.MainCamera, Abs (jpitch) * TransformRange (tpitch, 0.0, 1.0, TEMP_lower, TEMP_upper))
					
					Local jlr:Float			= joy.GetAxis (0)
					Local tlr:Float			= Abs (jpitch)
					
					If jlr > 0.05 Then PitchRight (Game.MainCamera, jlr * TransformRange (tlr, 0.0, 1.0, TEMP_lower, TEMP_upper))
					If jlr < -0.05 Then PitchLeft (Game.MainCamera, Abs (jlr) * TransformRange (tlr, 0.0, 1.0, TEMP_lower, TEMP_upper))

					' Boost...
					
					Local jyraw:Float		= joy.GetAxis (5)
					
					Local jy:Float			= TransformRange (jyraw, -1.0, 1.0, 0.0, 1.0)
					
					' The line below multiplies 0.0 - 1.0 by the range 0.5 - 1.0,
					' meaning that, at the lower end, input values are halved, yet
					' remain full at the upper end. Finer control at the lower end!
					
					jy						= jy * TransformRange (jy, 0.0, 1.0, 0.1, 1.0)
					
					If boost_fader.Level < jyraw * BOOST_VOLUME
						boost_fader.Level = jyraw * BOOST_VOLUME
					Endif
					
					If jyraw > -1.0
					
						boosting = True
						
						Boost (0.0, boost_factor * jy, 0.0)
						
						SmokeParticle.Create (Self, RocketModel.Basis * New Vec3f (Rnd (-0.01, 0.01), -0.025 * jy, Rnd (-0.01, 0.01)))
						SmokeParticle.Create (Self, RocketModel.Basis * New Vec3f (Rnd (-0.01, 0.01), -0.025 * jy, Rnd (-0.01, 0.01)))
						SmokeParticle.Create (Self, RocketModel.Basis * New Vec3f (Rnd (-0.01, 0.01), -0.025 * jy, Rnd (-0.01, 0.01)))
						SmokeParticle.Create (Self, RocketModel.Basis * New Vec3f (Rnd (-0.01, 0.01), -0.025 * jy, Rnd (-0.01, 0.01)))
						
						fuel = fuel - (MPG * jy)
						If fuel < 25.0 Then alert_fader.Level = ALERT_VOLUME
						
						If fuel < 0.0
							fuel					= 0.0
							boost_fader.Level		= 0.0
							boosting				= False
						Endif
						
					Endif
					
				Endif
			
			Else
				' Orient towards direction of travel... not managed to figure this out :/
			Endif
	
			If Not boosting
				boost_fader.Level = boost_fader.Level - 0.02
				If boost_fader.Level < 0.0 Then boost_fader.Level = 0.0
			Endif

			last_vel = body.LinearVelocity
			
		End

		Method Destroy:Void ()

			If CurrentOrb
				CurrentOrb.Destroy (False)
				CurrentOrb = Null
			Endif
			
			model?.Destroy ()
			body?.Destroy ()

			Game.MainMixer.RemoveFader (boost_fader, False)
			Game.MainMixer.RemoveFader (alert_fader, False)
			Game.MainMixer.RemoveFader (boom_fader, False)

		End
	
	Private
	
		Const MPG:Float						= 0.035 ' Fuel usage rate
		
		Const BOOM_VOLUME:Float				= 0.5
		Const BOOST_VOLUME:Float			= 0.5
		Const ALERT_VOLUME:Float			= 0.05
		
		Const ASSET_PREFIX_AUDIO:String		= "asset::audio/common/"
		Const ASSET_PREFIX_MODEL:String		= "asset::models/common/"
	
		Global BoostSound:Sound
		Global AlertSound:Sound
		Global BoomSound:Sound

		Field boost_fader:Fader
		Field alert_fader:Fader
		Field boom_fader:Fader
		
		Field model:Model				' mojo3d Model
		Field collider:ConeCollider		' Bullet physics collider
		Field body:RigidBody			' Bullet physics body
	
		Field boost_factor:Float			= 150.0
		Field torque_factor:Float			= 150.0
	
		Field vec_forward:Vec3f
		Field vec_backward:Vec3f
		Field vec_left:Vec3f
		Field vec_right:Vec3f
	
		Field last_vel:Vec3f
		
		Field fuel:Float
		Field exploded:Bool	= False

		Field damage:Float
		
		Field joy:Joystick
		Field joy_enabled:Bool
	
		Field orb:Orb
	
		Method Boost:Void (force_x:Float = 0.0, force_y:Float = 0.0, force_z:Float = 0.0)
			body.ApplyForce (model.Basis * New Vec3f (force_x, force_y, force_z))
		End
	
		Method PitchLeft:Void (camera:GameCamera, multi:Float = 1.0)
			body.ApplyTorque (camera.Camera3D.Basis * vec_left * multi)
		End
	
		Method PitchRight:Void (camera:GameCamera, multi:Float = 1.0)
			body.ApplyTorque (camera.Camera3D.Basis * vec_right * multi)
		End
	
		Method PitchForward:Void (camera:GameCamera, multi:Float = 1.0)
			body.ApplyTorque (camera.Camera3D.Basis * vec_forward * multi)
		End
	
		Method PitchBack:Void (camera:GameCamera, multi:Float = 1.0)
			body.ApplyTorque (camera.Camera3D.Basis * vec_backward * multi)
		End

		Property Damage:Float ()
			Return damage
			Setter (new_damage:Float)
				damage = new_damage
		End
		
		Property TMP_Joy:Joystick ()
			Return joy
		End
		
End
