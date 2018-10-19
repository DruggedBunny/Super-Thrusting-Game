
' TODO: Make PortalState an enum...

' Portal is portal as a whole
' PortalColliders are the inner cylinder collider bodies/behaviours

Class Portal

	Public
	
		Function InitSound ()

			FlythroughSound = Sound.Load (ASSET_PREFIX_AUDIO + "portal_flythrough.ogg")
	
				If Not FlythroughSound Then Abort ("Portal: InitSound failed to load flythrough audio!")
	
		End

		Property Alpha:Float ()
			Return alpha
			Setter (new_alpha:Float)
				alpha = new_alpha
		End
		
		Property Ring:Model ()
			Return ring
			Setter (new_ring:Model)
				ring = new_ring
		End
		
		Property Triggered:Bool ()
		
			If upper_collider.Triggered

				If lower_collider.Triggered
					flythrough_fader.Paused = False
					Return True
				Else
					upper_collider.Triggered = False
				Endif

			Endif
			
			Return False

		End
		
		Method New (x:Float, y:Float, z:Float, outer:Float = 50.0, inner:Float = 5.0)
		
			flythrough_fader			= Game.MainMixer.AddFader ("Portal: Flythrough", FlythroughSound.Play (False))
			flythrough_fader.Paused		= True
			flythrough_fader.Level		= FLYTHROUGH_VOLUME_MAX
	
			' Portal ring (model only -- no physics)...
			
			Ring						= Model.CreateTorus (outer, inner, 20, 10, New PbrMaterial (Color.Silver))
		
				Ring.Name				= "Portal ring [spawned at " + Time.Now () + "]"

				Ring.Move (x, y, z)

			' Flattened cylinders used for portal collision detection, one below and one above.

			' Distance between these must allow rocket to fit in-between. TODO: IS THIS TRUE?
			
			' Lower must trigger before upper in order to complete fly-through.
			
			Local center_upper:Model	= Model.CreateCylinder (outer, 4.0, Axis.Y, 16, New PbrMaterial (Color.White), Ring)
			Local center_lower:Model	= Model.CreateCylinder (outer, 4.0, Axis.Y, 16, New PbrMaterial (Color.White), Ring)

'			Cast <PbrMaterial> (center_upper.Material).ColorFactor = Color.Red
'			Cast <PbrMaterial> (center_lower.Material).ColorFactor = Color.Blue

'			OK, can't do this -- disables entity entirely so that collisions don't happen!

'				center_upper.Visible = False
'				center_lower.Visible = False

'			Use alpha...

			center_upper.Alpha			= 0.0
			center_lower.Alpha			= 0.0
			
			Local relative_pos:Float	= Ring.Mesh.Bounds.Height * 0.5 + center_upper.Mesh.Bounds.Height
			
			center_upper.Move (0.0, relative_pos, 0.0)
			center_lower.Move (0.0, -relative_pos, 0.0)
			
			upper_collider				= PortalCollider.Create (Self, center_upper, outer - inner)
			lower_collider				= PortalCollider.Create (Self, center_lower, outer - inner)

			PortalState					= Portal.PORTAL_STATE_CLOSED
			
		End
	
' WIP	
		Const PORTAL_STATE_CLOSED:Int	= 0
		Const PORTAL_STATE_OPENING:Int	= 1
		Const PORTAL_STATE_OPEN:Int		= 2
		Const PORTAL_STATE_CLOSING:Int	= 3
		Const PORTAL_STATE_DESTROY:Int	= 4

		Property PortalState:Int ()

			Return portal_state

			Setter (state:Int)

				If state <> portal_state
					'Local t_state:Int = portal_state
					portal_state = state
					'Print "Changed portal state from " + TMP_StateName (t_state) + " to " + TMP_StateName (portal_state)
				Endif

		End
		
		Method TMP_StateName:String (value:Int)
		
			Select value

				Case PORTAL_STATE_CLOSED
					Return "Closed"
				Case PORTAL_STATE_OPENING
					Return "Opening"
				Case PORTAL_STATE_OPEN
					Return "Open"
				Case PORTAL_STATE_CLOSING
					Return "Closing"
				Case PORTAL_STATE_DESTROY
					Return "Destroying"

				Default
					Return "UNDEFINED PORTAL STATE"

			End
			
			Return ""
			
		End
		
		Method Open ()
			PortalState = PORTAL_STATE_OPENING
		End
		
		Method Close ()
			PortalState = PORTAL_STATE_CLOSING
		End
		
		Method Destroy ()
			PortalState = PORTAL_STATE_DESTROY
		End

	Private

		' TEMP!!
		
		Global FlythroughSound:Sound
		
		Field flythrough_fader:Fader

		Const ASSET_PREFIX_AUDIO:String = "asset::audio/common/"
		Const FLYTHROUGH_VOLUME_MAX:Float = 0.33
	
		Field ring:Model

		Field upper_collider:PortalCollider
		Field lower_collider:PortalCollider

		Field alpha:Float = 0.0				' Portal alpha controls visibility and scale. *** Separate to model alpha! ***
		
		' TODO: Temp!
		
		Field portal_state:Int
		
End

Class PortalCollider Extends Behaviour
	
	Public
	
		Function Create:PortalCollider (portal:Portal, model:Model, radius:Float)

			Local pc:PortalCollider	= New PortalCollider (model)
			
				pc.portal			= portal
				pc.radius			= radius
			
			Return pc
			
		End
		
		Method New (entity:Entity)
			
			Super.New (entity)
			AddInstance ()
	
		End
		
		Method OnStart () Override

			' Add physics bodies and colliders...

			Local collider:CylinderCollider	= Entity.AddComponent <CylinderCollider> ()

				collider.Radius				= radius
	
			Local body:RigidBody			= Entity.AddComponent <RigidBody> ()
	
				body.Mass					= 0.0
			
				body.CollisionMask			= COLL_PORTAL
				body.CollisionGroup			= PORTAL_COLLIDES_WITH
	
				body.btBody.setCollisionFlags (bullet.btCollisionObject.CF_NO_CONTACT_RESPONSE)
	
				body.Collided += Lambda (other_body:RigidBody)
					
					If Game.Player.CurrentOrb
						Triggered = True
					Endif
				
			End

		End

		Property Triggered:Bool ()
			Return triggered
			Setter (state:Bool)
				triggered = state
		End

		Method SetPortal (new_portal:Portal, upper:Bool)
			portal = new_portal
		End
		
		Method OnUpdate (elapsed:Float) Override
			
			If Game.GameState.GetCurrentState () <> States.Paused

				Select portal.PortalState
				
					Case Portal.PORTAL_STATE_OPENING
						
						If portal.Alpha < 1.0
						
							' Increase alpha and scale...
							
							portal.Alpha = portal.Alpha + (0.002 * Game.Delta)
							portal.Ring.Scale = New Vec3f (portal.Alpha, portal.Alpha, portal.Alpha)
							
							' Cap alpha/scale at 1.0 and switch to open state...
							
							If portal.Alpha >= 1.0
							
								portal.Alpha = 1.0
							
								Cast <PbrMaterial> (portal.Ring?.Material)?.ColorFactor = Color.White
								portal.Ring.Scale = New Vec3f (1.0, 1.0, 1.0)
							
								portal.PortalState = Portal.PORTAL_STATE_OPEN
		
								Return
								
							Endif
							
						Endif
						
						' While opening, use random colours...
						
						If Sin (Millisecs ()) > 0.5
							Cast <PbrMaterial> (portal.Ring?.Material)?.ColorFactor = Color.Rnd ()
						Endif
						
						' Modulate alpha...
						
						portal.Ring?.Alpha = portal.Alpha * (Degrees (Sin (Millisecs () * 0.005)) * 15.0 + 0.5) ' Yikes. Good old trial and error!
						
					Case Portal.PORTAL_STATE_OPEN
					
						portal.Alpha = 1.0
						portal.Ring?.Alpha = portal.Alpha * (Degrees (Sin (Millisecs () * 0.01)) * 15.0 + 0.5)
						
						If portal.Triggered
							portal.PortalState = Portal.PORTAL_STATE_CLOSING
							Game.GameState.SetCurrentState (States.LevelTween)
						Endif
						
					Case Portal.PORTAL_STATE_CLOSING
					
						' TODO: See States.LevelTween
						
						portal.Alpha = portal.Alpha - (0.003 * Game.Delta)
						portal.Ring?.Alpha = portal.Alpha
						
						If portal.Alpha < 0.01
							portal.PortalState = Portal.PORTAL_STATE_CLOSED
						Endif
						
					Case Portal.PORTAL_STATE_CLOSED
				
						portal.Alpha = 0.0
						portal.Ring?.Alpha = portal.Alpha
					
					Case Portal.PORTAL_STATE_DESTROY
					
						portal.Ring?.Destroy ()
						Destroy ()
						
				End
			
			Endif
			
		End

		Property SpaceGemModel:Model ()
			Return Cast <Model> (Entity)
		End
		
		Property PortalColliderBody:RigidBody ()
			Return Entity.GetComponent <RigidBody> ()
		End
	
	Private

		Field portal:Portal
	
		Field radius:Float
		Field triggered:Bool

End
