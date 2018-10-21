
' WIP! To split into individual walls. Another class to manage as one?

Class TrumpWall' Extends Behaviour
	
	Public

		Function InitSound ()
	
			BumpSound = Sound.Load (ASSET_PREFIX_AUDIO + "wall_bump.ogg")
			
				If Not BumpSound Then Abort ("PhysicsTerrain/Wall: InitSound failed to load wall-bump audio!")

		End

	Private
	
		Global BumpSound:Sound
		
		Field bump_fader:Fader
		Field bump_channel_time:Int
		
		Field walls:Model []
		Field ceiling:Model
		
		Const ASSET_PREFIX_AUDIO:String = "asset::audio/common/"
				
	Public
	
	Method Destroy ()
		For Local wall:Model = Eachin walls
			wall.Destroy ()
		Next
		ceiling?.Destroy ()
	End
	
	Method New (height_box:Boxf)

		' Sound for bumping into invisible walls at outer edge of terrain/upper ceiling limit...

		bump_fader			= Game.MainMixer.AddFader ("PhysicsTerrain: Bump", BumpSound.Play (False))
		bump_fader.Paused	= True
		bump_channel_time	= Millisecs ()

		' Invisible walls around terrain...
		
		' Re-use collision box for all. (Technically results in possible collision failure at corners due to lack of overlap! Being lazy... )
		
		Local wall_box:Boxf = New Boxf (-height_box.Width * 0.5, -height_box.Height * 0.5, -2.0, height_box.Width * 0.5, height_box.Height * 2.5, 2.0)
		
		' Base wall model...
		
		Local wall_base:Model = Model.CreateBox (wall_box, 1, 1, 1, New PbrMaterial (Color.White))
		
			wall_base.Name = "Boundary wall base model"
		
		' Wall array...
		
		walls = New Model [4]
		
		For Local wall_instance:Int = 0 Until walls.Length
		
				' Copy base model...
				
				walls [wall_instance] = wall_base.Copy ()
				walls [wall_instance].Alpha = 0.0
				
				walls [wall_instance].Name = "Wall base copy [spawned at " + Time.Now () + "]"
				
				Select wall_instance
		
					Case 0	' Ahead
						walls [wall_instance].Move (0, height_box.Height * 0.5, height_box.Depth * 0.5 + wall_box.Depth * 0.5)
		
					Case 1	' Behind
					
						walls [wall_instance].Move (0, height_box.Height * 0.5, -height_box.Depth * 0.5 - wall_box.Depth * 0.5)
			
					Case 2	' Left
					
						walls [wall_instance].Rotate (0, 90, 0)
						walls [wall_instance].Move (0, height_box.Height * 0.5, height_box.Depth * 0.5 + wall_box.Depth * 0.5)
			
					Case 3	' Right
					
						walls [wall_instance].Rotate (0, -90, 0)
						walls [wall_instance].Move (0, height_box.Height * 0.5, height_box.Depth * 0.5 + wall_box.Depth * 0.5)
			
				End
			
			' Collider...
			
			Local wall_collider:BoxCollider = walls [wall_instance].AddComponent <BoxCollider> ()
				
				wall_collider.Box = wall_box
		
			' Rigid body...
			
			Local wall_body:RigidBody = walls [wall_instance].AddComponent <RigidBody> ()
			
				wall_body.Mass = 0.0			' 0 = immoveable
				wall_body.Restitution = 1.0	' Bouncy!
				
				wall_body.CollisionMask	= COLL_WALL
				wall_body.CollisionGroup	= WALL_COLLIDES_WITH
			
				' Collision response function...
				
				wall_body.Collided += Lambda (other_body:RigidBody)
			
					' Play bounce sound only every 250 ms (avoids high-speed repetition when colliding)...
					
					If Millisecs () - bump_channel_time > 250
			
						' Un-pause channel (ie. play)...
						
						bump_fader.Paused = False
					
						' Start a new instance playing, but paused...
						
						bump_fader = Game.MainMixer.AddFader ("PhysicsTerrain: ", BumpSound.Play (False))
						bump_fader.Paused = True
						
						' Reset timer...
						
						bump_channel_time = Millisecs ()
						
					Endif
					
				End
		
		Next
		
		' Hide wall base model...
		
		wall_base.Destroy ()' = False ' Note that actual walls remain Visible = True, as Visible = False disables physics!
		
		' Ceiling, sits at 3 times total terrain height...
		
		' Better solution would be limiting rocket boost dependent on height, but would require testing (or actual mathematics) to ensure it remains wall height!
		
		' Travelling to ceiling feels a very long way, though, so anyone doing this is testing limits and deserves to be punished!
		
		Local ceiling_box:Boxf = New Boxf (-height_box.Width * 0.5, -2.0, -height_box.Depth * 0.5, height_box.Width * 0.5, 2.0, height_box.Depth * 0.5)
		
		ceiling = Model.CreateBox (ceiling_box, 1, 1, 1, New PbrMaterial (Color.White))
		
				ceiling.Alpha = 0.0
				ceiling.Move (0, height_box.Height * 3.0 + ceiling_box.Height * 0.5, 0.0)
			
				ceiling.Name = "Boundary ceiling [spawned at " + Time.Now () + "]"
				
		Local cc:BoxCollider = ceiling.AddComponent <BoxCollider> ()
				
				cc.Box = ceiling_box
		
		Local ceiling_body:RigidBody = ceiling.AddComponent <RigidBody> ()
		
			ceiling_body.Mass = 0.0			' 0 = immoveable
			ceiling_body.Restitution = 1.0	' Bouncy!
			
			ceiling_body.CollisionMask	= COLL_WALL
			ceiling_body.CollisionGroup	= WALL_COLLIDES_WITH
		
			' Collision response function...
			
			ceiling_body.Collided += Lambda (other_body:RigidBody)
		
				' Play bounce sound only every 250 ms (avoids high-speed repetition when colliding)...
				
				If Millisecs () - bump_channel_time > 250
		
					' Un-pause channel (ie. play)...
					
					bump_fader.Paused = False
				
					' Start a new instance playing, but paused...
					
					bump_fader = Game.MainMixer.AddFader ("PhysicsTerrain: Buump", BumpSound.Play (False))
					bump_fader.Paused = True
					
					' Reset timer...
					
					bump_channel_time = Millisecs ()
					
				Endif
				
			End
		
	End

'		Function Create:TrumpWall ()
'		
'		End
'	
'	Private
'
'		Method New (entity:Entity)
'			
'			Super.New (entity)
'			AddInstance ()
'	
'		End
'			
End
