
Class Rocket

	Public
		
		Property Damage:Float ()
			Return damage
			Setter (new_damage:Float)
				damage = new_damage
		End
		
		Property Alive:Bool ()
			Return Not exploded
		End
		
		Property RocketBody:RigidBody ()
			Return body
		End
		
		Property RocketModel:Model ()
			Return model
		End
		
		Property Fuel:Float ()
			Return fuel
			Setter (amount:Float)
				fuel = amount
		End
		
		Property Joy:Joystick ()
			Return joy
		End
		
		Property CurrentOrb:Orb ()
			Return orb
			Setter (torb:Orb)
				orb = torb
		End

		Const BOOM_VOLUME_MAX:Float = 0.5
		Const BOOST_VOLUME_MAX:Float = 0.5
		Const ALERT_VOLUME_MAX:Float = 0.05
		
		Method New (x:Float, y:Float, z:Float, collision_radius:Float = 1.2, collision_length:Float = 4.0, collision_mass:Float = 10.0)

			If CurrentOrb Then CurrentOrb.Destroy ()
			
			Local mat:PbrMaterial = New PbrMaterial (Color.Silver)
			mat.MetalnessFactor = 0.85
			
			boost = Sound.Load (ASSET_PREFIX_AUDIO + "boost.ogg")

			If Not boost Then Abort ("Rocket: Failed to load boost audio!")

			boost_channel = boost.Play (True)
			boost_channel.Volume = 0.0
			
			alert = Sound.Load (ASSET_PREFIX_AUDIO + "alert.ogg")

			If Not alert Then Abort ("Rocket: Failed to load alert audio!")

			alert_channel = alert.Play (True)
			alert_channel.Volume = 0.0
			
			boom = Sound.Load (ASSET_PREFIX_AUDIO + "boom.ogg")

			If Not boom Then Abort ("Rocket: Failed to load boom audio!")

			boom_channel = boom.Play (False)
			boom_channel.Paused = True
			boom_channel.Volume = BOOM_VOLUME_MAX
	
	' Can't detect when leaving pad!
	
	'		refuel = Sound.Load ("asset::refuel.ogg")
	'		refuel_channel = refuel.Play (True)
			'refuel_channel.Rate = refuel_channel.Rate * 0.85
	'		refuel_channel.Volume = 0.0
			
			model = Model.Load (ASSET_PREFIX_MODEL + "Rocket_Ship_01.gltf")
	
			If Not model Then Abort ("Rocket: Failed to load rocket model!")
			
			model.Name = "Rocket [spawned at " + Time.Now () + "]"
			
			For Local mat:Material = Eachin model.Materials
				Cast <PbrMaterial> (mat).MetalnessFactor = 1.0
			Next
			
	'		cone vis:
			
			'Local temp:Model = Model.CreateCone (radius, length, Axis.Y, 32, mat, model)
			'temp.Alpha = 0.25
			
			Local yoff:Float = 0.15
			model.Mesh.FitVertices (New Boxf (-collision_radius, -collision_length * 0.5 - yoff, -collision_radius, collision_radius, collision_length * 0.5 - yoff, collision_radius), False)
			
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
	
			vec_forward			= New Vec3f (torque_factor, 0.0, 0.0)
			vec_backward		= New Vec3f (-torque_factor, 0.0, 0.0)
			vec_left			= New Vec3f (0.0, 0.0, torque_factor)
			vec_right			= New Vec3f (0.0, 0.0, -torque_factor)
	
			explosion_triggered = False
			
			body.Collided += Lambda (other_body:RigidBody) ' Other colliding body
				
				Select other_body.CollisionMask
				
					Case COLL_PAD
					
						' Add landing speed check?
						
						' TODO: Angle!
						
						If Not landed
							landed = True ' Can't detect when no longer colliding!
							' Want to play landing 'thump' once
						Endif
					
						fuel = fuel + 0.25
						
						'refuel_channel.Volume = 0.1
						
						If alert_channel.Volume
							If fuel > 25.0 Then alert_channel.Volume = 0.0
						Endif
						
						If fuel > 100 Then fuel = 100'; refuel_channel.Volume = 0.0
					
					Case COLL_TERRAIN
	
						' Landing speed check... TODO: Angle!
						
						If Abs (body.LinearVelocity.Length - last_vel.Length) < 3.0 ' WAS: If body.LinearVelocity.Length < 3.0
							Return
						Endif
						
						damage = damage + (Abs (body.LinearVelocity.Length - last_vel.Length) * 4.0)
						
						If damage >= 100.0
							If Not exploded Then Explode ()
							damage = 100.0
						Endif
						
				End
				
			End
		
			fuel	= 100.0
			damage	= 0.0
			
		End
	
		Method Explode ()
	
			boost_channel.Paused	= True
			boom_channel.Paused		= False
			alert_channel.Paused	= True
			
			PhysicsTri.Explode (model, body)
			
			model.Visible = False
			
			fuel = 0.0
	
			orb?.DetachFromRocket ()
			CurrentOrb = Null
			
			exploded = True
			
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
					
					If boost_channel.Volume < BOOST_VOLUME_MAX
						boost_channel.Volume = boost_channel.Volume + 0.05
						If boost_channel.Volume > BOOST_VOLUME_MAX Then boost_channel.Volume = BOOST_VOLUME_MAX
					Endif
					
					Boost (0.0, body.Mass * boost_factor, 0.0)
					New SmokeParticle (Self)
					
					fuel = fuel - (MPG * 0.9)
					If fuel < 25.0 Then alert_channel.Volume = ALERT_VOLUME_MAX
					
					If fuel < 0.0
						fuel = 0.0
						boost_channel.Volume = 0.0
						boosting = False
					Endif
					
				Endif
				
				joy = ValidateJoystick (joy) ' Specifically checks for Xbox pad
	
				' JOYSTICK
				
				If joy And joy.Attached
				
					If joy.ButtonPressed (0)
						joy_enabled = True
					Endif
					
					If joy_enabled
	
			'			Print joy.GetAxis (0) ' Left stick left/right
						'Print joy.GetAxis (1) ' Left stick up/down (-1 = back, +1 = forward)
						
						Local jpitch:Float = joy.GetAxis (1)
						
						' Pitch scaling:
						
						' Raw input, jpitch, is -1.0 to 1.0...
						
						' Want to multiply lower end of 0.0 to [+/-] 1.0 by 0.5, upper end by 1.2...
						
						' Multipliers:
						
						Local TEMP_lower:Float = 0.5
						Local TEMP_upper:Float = 1.2
						
						Local tpitch:Float = Abs (jpitch)
						
						If jpitch > 0.05 Then PitchBack (Game.MainCamera, jpitch * TransformRange (tpitch, 0.0, 1.0, TEMP_lower, TEMP_upper))
						If jpitch < -0.05 Then PitchForward (Game.MainCamera, Abs (jpitch) * TransformRange (tpitch, 0.0, 1.0, TEMP_lower, TEMP_upper))
						
						Local jlr:Float = joy.GetAxis (0)
						Local tlr:Float = Abs (jpitch)
						
						If jlr > 0.05 Then PitchRight (Game.MainCamera, jlr * TransformRange (tlr, 0.0, 1.0, TEMP_lower, TEMP_upper))
						If jlr < -0.05 Then PitchLeft (Game.MainCamera, Abs (jlr) * TransformRange (tlr, 0.0, 1.0, TEMP_lower, TEMP_upper))

						Local jyraw:Float = joy.GetAxis (5)
						Local jy:Float = TransformRange (jyraw, -1.0, 1.0, 0.0, 1.0)
						
						' The line below multiplies 0.0 - 1.0 by the range 0.5 - 1.0,
						' meaning that, at the lower end, input values are halved, yet
						' remain full at the upper end. Finer control at the lower end!
						
						jy = jy * TransformRange (jy, 0.0, 1.0, 0.5, 1.0)
						
						If boost_channel.Volume < jy * BOOST_VOLUME_MAX
							boost_channel.Volume = jy * BOOST_VOLUME_MAX
						Endif
						
						If jyraw > -1.0
						
							boosting = True
							
							Boost (0.0, (body.Mass * boost_factor) * jy, 0.0)
							New SmokeParticle (Self, jy)
							
							fuel = fuel - (MPG * jy)
							If fuel < 25.0 Then alert_channel.Volume = ALERT_VOLUME_MAX
							
							If fuel < 0.0
								fuel = 0.0
								boost_channel.Volume = 0.0
								boosting = False
							Endif
							
						Endif
					
					Endif
				
				Endif
			
			Else
				' Orient towards direction of travel
				'model.Rotation = body.LinearVelocity ' NOPE TO EVERY POSSIBLE VARIANT OVER LAST TWO HOURS!!
' https://answers.unity.com/questions/39031/how-can-i-rotate-a-rigid-body-based-on-its-velocit.html

'				model.PointAt (model.Position + body.LinearVelocity)
'				model.Rotate (90.0, 0.0, 0.0, True)
'				Almost, but fails to ever collide, fixed camera looks weird

'				Local model_pitch:Float	= model.GetRotation ().X
'				Local model_yaw:Float	= model.GetRotation ().Y
'				Local model_roll:Float	= model.GetRotation ().Z
'				
'				Print model_pitch Mod 360.0
'				Print model_yaw Mod 360.0
'				Print model_roll Mod 360.0
'				
'				Local body_pitch:Float	= Degrees (body.LinearVelocity.Pitch) * 360.0
'				Local body_yaw:Float	= Degrees (body.LinearVelocity.Yaw) * 360.0
'				Local body_roll:Float	= model_roll
'				
'				Print body_pitch
'				Print body_yaw
'				Print body_roll
'				
'				Print ""
'				
'				Local diff:Vec3f = New Vec3f ((body_pitch - model_pitch) * 0.1, (body_yaw - model_yaw) * 0.1, (body_roll - model_roll) * 0.1)
'
'				body.ApplyTorque (diff)
'
			Endif
	
			If Not boosting
				boost_channel.Volume = boost_channel.Volume - 0.02
				If boost_channel.Volume < 0.0 Then boost_channel.Volume = 0.0
			Endif
		
			last_vel = body.LinearVelocity
			
		End

		Method Destroy:Void ()

			If CurrentOrb Then CurrentOrb.Destroy ()
			
			model?.Destroy ()
			body?.Destroy ()

			boost_channel.Stop ()
			alert_channel.Stop ()
			boom_channel.Stop ()
			
			boost_channel = Null
			alert_channel = Null
			boom_channel = Null

		End
	
	Private
	
		Const MPG:Float = 0.035 ' Fuel usage rate
		
		Const ASSET_PREFIX_AUDIO:String = "asset::audio/common/"
		Const ASSET_PREFIX_MODEL:String = "asset::models/common/"
	
		Field model:Model				' mojo3d Model
		Field collider:ConeCollider		' Bullet physics collider
		Field body:RigidBody			' Bullet physics body
	
		Field boost_factor:Float	= 18.0'0.25
		Field torque_factor:Float	= 150.0
	
		Field vec_forward:Vec3f
		Field vec_backward:Vec3f
		Field vec_left:Vec3f
		Field vec_right:Vec3f
	
		Field last_vel:Vec3f
		Field explosion_triggered:Bool
		
		' Make Global to load once?
		
		Field boost:Sound
		Field boost_channel:Channel
		
		Field alert:Sound
		Field alert_channel:Channel
		
		Field boom:Sound
		Field boom_channel:Channel
		
		Field refuel:Sound
		Field refuel_channel:Channel
		
	'	Field booster:Light
		
		Field fuel:Float
		Field exploded:Bool = False

		Field damage:Float
				
		Field landed:Bool = False
	
		Field joy:Joystick
		Field joy_enabled:Bool
	
		Field orb:Orb
		Field orb_toggle:Bool	' TEMP
	
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

End
