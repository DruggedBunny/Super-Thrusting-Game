
Class Portal
	
	Public
	
		Field ring:Model
		
		Property UpperTriggered:Bool ()
			Return upper_triggered
		End
	
		Property LowerTriggered:Bool ()
			Return lower_triggered
		End
		
		Function Complete:Bool ()
			If Game.Player.CurrentOrb And Game.CurrentLevel.ExitPortal.UpperTriggered And Game.CurrentLevel.ExitPortal.LowerTriggered
				flythrough_channel.Paused = False
				Return True
			Endif
			Return False
		End
		
		Method New (x:Float, y:Float, z:Float, outer:Float = 50.0, inner:Float = 5.0)

			flythrough = Sound.Load (ASSET_PREFIX_AUDIO + "portal_flythrough.ogg")

			If Not flythrough Then Abort ("Portal: Failed to load flythrough audio!")

			flythrough_channel = flythrough.Play (False)
			flythrough_channel.Paused = True
			flythrough_channel.Volume = FLYTHROUGH_VOLUME_MAX
	
			' Portal ring...
			
			ring			= Model.CreateTorus (outer, inner, 20, 10, New PbrMaterial (Color.Silver))
			
			ring.Name = "Portal ring [spawned at " + Time.Now () + "]"
			
			ring.Move (x, y, z)
			
			' Flattened cylinders used for portal collision detection, one below and one above. Distance between
			' these must allow rocket to fit in-between. Lower must trigger before upper in order to complete fly-through.
			
			center_upper	= Model.CreateCylinder (outer - inner, 4.0, Axis.Y, 16, New PbrMaterial (Color.White), ring)
			center_lower	= Model.CreateCylinder (outer - inner, 4.0, Axis.Y, 16, New PbrMaterial (Color.White), ring)
			
			center_upper.Name = "Portal ring upper collision cylinder [spawned at " + Time.Now () + "]"
			center_lower.Name = "Portal ring lower collision cylinder [spawned at " + Time.Now () + "]"
			
			' Upper collision cylinder...
			
				Cast <PbrMaterial> (center_upper.Material).ColorFactor = Color.Red		' Visibility testing only...
				center_upper.Alpha = 0.0												' Visibility testing only...

				center_upper.Move (0.0, Cast <Float> (ring.Mesh.Bounds.Height) * 0.5 + center_upper.Mesh.Bounds.Height, 0.0)
	
			' Lower collision cylinder...

				Cast <PbrMaterial> (center_lower.Material).ColorFactor = Color.Green	' Visibility testing only...
				center_lower.Alpha = 0.0												' Visibility testing only...

				center_lower.Move (0.0, Cast <Float> (-ring.Mesh.Bounds.Height) * 0.5 - center_lower.Mesh.Bounds.Height, 0.0)
			
			' Add scene.Update behaviours...
			
			Local behaviour_upper:PortalBehaviour = center_upper.AddComponent <PortalBehaviour> ()

				behaviour_upper.AddPortal (Self)
	
			Local behaviour_lower:PortalBehaviour = center_lower.AddComponent <PortalBehaviour> ()
	
				behaviour_lower.AddPortal (Self)
	
			' Add physics bodies and colliders...
			
			body_upper = center_upper.AddComponent <RigidBody> ()
	
				body_upper.Mass = 0.0
			
				body_upper.btBody.setCollisionFlags (bullet.btCollisionObject.CF_NO_CONTACT_RESPONSE)
	
				body_upper.CollisionMask	= COLL_PORTAL
				body_upper.CollisionGroup	= PORTAL_COLLIDES_WITH
	
				collider_upper = center_upper.AddComponent <CylinderCollider> ()
				collider_upper.Radius = outer - inner
	
				collider_lower = center_lower.AddComponent <CylinderCollider> ()
				collider_lower.Radius = outer - inner

			body_lower = center_lower.AddComponent <RigidBody> ()
	
				body_lower.Mass = 0.0
				
				body_lower.btBody.setCollisionFlags (bullet.btCollisionObject.CF_NO_CONTACT_RESPONSE)
		
				body_lower.CollisionMask	= COLL_PORTAL
				body_lower.CollisionGroup	= PORTAL_COLLIDES_WITH
	
			' Add collision functions...
			
			body_upper.Collided += Lambda (other_body:RigidBody)
				
				' Upper cylinder collision only accepted if lower cylinder collision already triggered...
				
				If lower_triggered
					upper_triggered = True
				Endif
				
			End
	
			body_lower.Collided += Lambda (other_body:RigidBody)

				lower_triggered = True
				
			End
	
			Portal.PortalState = Portal.PORTAL_STATE_CLOSED
			
		End
	
' WIP	
		Global PortalState:Int
		
		Const PORTAL_STATE_CLOSED:Int	= 0
		Const PORTAL_STATE_OPENING:Int	= 1
		Const PORTAL_STATE_OPEN:Int		= 2
		Const PORTAL_STATE_CLOSING:Int	= 3
		
		Global Alpha:Float = 0.0				' Portal alpha controls visibility and scale. *** Separate to model alpha! ***
		
	Private

'		Field ring:Model

		Const ASSET_PREFIX_AUDIO:String = "asset::audio/common/"
		Const FLYTHROUGH_VOLUME_MAX:Float = 0.75

		Field center_upper:Model				' Upper collision cylinder
		Field center_lower:Model				' Lower collision cylinder
		
		Field body_upper:RigidBody				' Bullet physics body, upper cylinder
		Field body_lower:RigidBody				' Bullet physics body, lower cylinder
		
		Field collider_upper:CylinderCollider	' Bullet physics collider, upper cylinder
		Field collider_lower:CylinderCollider	' Bullet physics collider, lower cylinder
		
		Field upper_triggered:Bool
		Field lower_triggered:Bool

		' TEMP!!
		
		Global flythrough:Sound
		Global flythrough_channel:Channel
		
End

Class PortalBehaviour Extends Behaviour
	
	Field portal:Portal
	
	Method New (entity:Entity)
		
		Super.New (entity)
		
		AddInstance ()

	End
	
	Method AddPortal (new_portal:Portal)
		portal = new_portal
	End
	
	Method OnUpdate (elapsed:Float) Override
		
		Select portal.PortalState
		
			Case Portal.PORTAL_STATE_OPENING
		
				If portal.Alpha < 1.0
				
					' Increase alpha and scale...
					
					portal.Alpha = portal.Alpha + 0.002
					portal.ring.Scale = New Vec3f (portal.Alpha, portal.Alpha, portal.Alpha)
					
					' Cap alpha/scale at 1.0 and switch to open state...
					
					If portal.Alpha >= 1.0
					
						portal.Alpha = 1.0
					
						Cast <PbrMaterial> (portal.ring?.Material)?.ColorFactor = Color.White
						portal.ring.Scale = New Vec3f (1.0, 1.0, 1.0)
					
						portal.PortalState = Portal.PORTAL_STATE_OPEN

						Return
						
					Endif
					
				Endif
				
				' While opening, use random colours...
				
				If Sin (Millisecs ()) > 0.5
					Cast <PbrMaterial> (portal.ring?.Material)?.ColorFactor = Color.Rnd ()
				Endif
				
				' Modulate alpha...
				
				portal.ring?.Alpha = portal.Alpha * (Degrees (Sin (Millisecs () * 0.005)) * 15.0 + 0.5) ' Yikes
				
			Case Portal.PORTAL_STATE_OPEN
			
				' Good old trial-and-error!
			
				portal.Alpha = 1.0
				portal.ring?.Alpha = portal.Alpha * (Degrees (Sin (Millisecs () * 0.01)) * 15.0 + 0.5) ' Yikes
				
			Case Portal.PORTAL_STATE_CLOSED
		
				portal.Alpha = 0.0
				portal.ring?.Alpha = portal.Alpha
			
			Case Portal.PORTAL_STATE_CLOSING
			
				' TODO: See States.LevelTween
				
				portal.Alpha = portal.Alpha - 0.002
				portal.ring?.Alpha = portal.Alpha
				
				'Print portal.Alpha
				
				If portal.Alpha < 0.01
					portal.ring?.Destroy ()
					Destroy ()
					portal.PortalState = Portal.PORTAL_STATE_CLOSED
					'Print "Poof"
				Endif
				
		End
		
	End

	' TODO: Delete portal for new level!
	
End