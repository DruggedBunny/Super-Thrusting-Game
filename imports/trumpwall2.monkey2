
' -----------------------------------------------------------------------------
' What is it?
' -----------------------------------------------------------------------------

' WIP! To split into individual walls. Another class to manage as one?

Class TrumpWall

	Public
	
		Method SetDebugAlpha (new_alpha:Float)
			
			For Local wall:Wall = Eachin walls
				wall.DebugAlpha = new_alpha
			Next

			ceiling.DebugAlpha	= new_alpha

		End
		
		Method Destroy ()
		
			For Local wall:Wall = Eachin walls
				wall.Destroy ()
			Next
			
			ceiling?.Destroy ()
			
		End
		
		Method New (height_box:Boxf)

			' Invisible walls around terrain...
			
			' Re-use collision box for all. (Technically results in possible collision failure at corners due to lack of overlap! Being lazy... )
			
			Local wall_box:Boxf = New Boxf (-height_box.Width * 0.5, -height_box.Height * 0.5, -2.0, height_box.Width * 0.5, height_box.Height * 2.5, 2.0)
			
			' Wall array...
		
	'	UNG!
		
			Local pos:Vec3f
			Local yrot:Float
	
			walls = New Wall [4]
			
				pos			= New Vec3f (0, height_box.Height * 0.5, height_box.Depth * 0.5 + wall_box.Depth * 0.5)
				yrot		= 0.0
				walls [0]	= Wall.Create (wall_box, pos, yrot, New PbrMaterial (Color.White), "Boundary wall, ahead")
	
				pos			= New Vec3f (0, height_box.Height * 0.5, -height_box.Depth * 0.5 - wall_box.Depth * 0.5)
				yrot		= 0.0
				walls [1]	= Wall.Create (wall_box, pos, yrot, New PbrMaterial (Color.White), "Boundary wall, behind")
	
				pos			= New Vec3f (0, height_box.Height * 0.5, height_box.Depth * 0.5 + wall_box.Depth * 0.5)
				yrot		= 90.0
				walls [2]	= Wall.Create (wall_box, pos, yrot, New PbrMaterial (Color.White), "Boundary wall, left")
	
				pos			= New Vec3f (0, height_box.Height * 0.5, height_box.Depth * 0.5 + wall_box.Depth * 0.5)
				yrot		= -90.0
				walls [3]	= Wall.Create (wall_box, pos, yrot, New PbrMaterial (Color.White), "Boundary wall, right")
	
			For Local wall_instance:Int = 0 Until walls.Length
			
	'			' Collider...
	'			
	'			Local wall_collider:BoxCollider = walls [wall_instance].WallModel.AddComponent <BoxCollider> ()
	'				
	'				wall_collider.Box = wall_box
	'		
				' Rigid body...
				
	'			Local wall_body:RigidBody = walls [wall_instance].WallModel.AddComponent <RigidBody> ()
	'			
	'				wall_body.Mass = 0.0			' 0 = immoveable
	'				wall_body.Restitution = 1.0	' Bouncy!
	'				
	'				wall_body.CollisionMask	= COLL_WALL
	'				wall_body.CollisionGroup	= WALL_COLLIDES_WITH
	'			
	'				' Collision response function...
	'				
	'				wall_body.Collided += Lambda (other_body:RigidBody)
	'			
	'					' Play bounce sound only every 250 ms (avoids high-speed repetition when colliding)...
	'					
	'					If Millisecs () - bump_channel_time > 250
	'			
	'						' Un-pause channel (ie. play)...
	'						
	'						bump_fader.Paused = False
	'					
	'						' Start a new instance playing, but paused...
	'						
	'						bump_fader = Game.MainMixer.AddFader ("PhysicsTerrain: ", BumpSound.Play (False))
	'						bump_fader.Paused = True
	'						
	'						' Reset timer...
	'						
	'						bump_channel_time = Millisecs ()
	'						
	'					Endif
	'					
	'				End
	'		
			Next
			
			' Ceiling, sits at 3 times total terrain height...
			
			' Better solution would be limiting rocket boost dependent on height, but would require testing (or actual mathematics) to ensure it remains wall height!
			
			' Travelling to ceiling feels a very long way, though, so anyone doing this is testing limits and deserves to be punished!
	
			Local ceiling_box:Boxf = New Boxf (-height_box.Width * 0.5, -2.0, -height_box.Depth * 0.5, height_box.Width * 0.5, 2.0, height_box.Depth * 0.5)
			
			pos			= New Vec3f (0, height_box.Height * 3.0 + ceiling_box.Height * 0.5, 0.0)
			yrot		= 0.0
				
			ceiling = Wall.Create (ceiling_box, pos, yrot, New PbrMaterial (Color.White), "Ceiling")
				
	'		Local cc:BoxCollider = ceiling.AddComponent <BoxCollider> ()
	'				
	'				cc.Box = ceiling_box
	'		
	'		Local ceiling_body:RigidBody = ceiling.AddComponent <RigidBody> ()
	'		
	'			ceiling_body.Mass = 0.0			' 0 = immoveable
	'			ceiling_body.Restitution = 1.0	' Bouncy!
	'			
	'			ceiling_body.CollisionMask	= COLL_WALL
	'			ceiling_body.CollisionGroup	= WALL_COLLIDES_WITH
	'		
	'			' Collision response function...
	'			
	'			ceiling_body.Collided += Lambda (other_body:RigidBody)
	'		
	'				' Play bounce sound only every 250 ms (avoids high-speed repetition when colliding)...
	'				
	'				If Millisecs () - bump_channel_time > 250
	'		
	'					' Un-pause channel (ie. play)...
	'					
	'					bump_fader.Paused = False
	'				
	'					' Start a new instance playing, but paused...
	'					
	'					bump_fader = Game.MainMixer.AddFader ("PhysicsTerrain: Bump", BumpSound.Play (False))
	'					bump_fader.Paused = True
	'					
	'					' Reset timer...
	'					
	'					bump_channel_time = Millisecs ()
	'					
	'				Endif
	'				
	'			End
	'		
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

	Private
	
		Field walls:Wall []
		Field ceiling:Wall
		
End
