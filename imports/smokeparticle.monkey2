
Class SmokeParticle

	Public
	
		Method New (rocket:Rocket, multi:Float = 1.0)
	
			If Not thrust
				thrust = New Vec3f (0.0, -0.3 * multi, 0.0)
			Endif
			
			Local col:Color
			
			Select Int (Rnd (5))
			
				Case 0
					col = Color.Black
				Case 1
					col = Color.White
				Case 2
					col = Color.Red
				Case 3
					col = Color.Orange
				Case 4
					col = Color.Yellow
					
			End
			
			'rocket.booster.Color = col * 4.0 * multi
			
			Local mat:PbrMaterial = New PbrMaterial (col)
			
			Local size:Float = 0.5
			Local distance:Float = 10.0
			
			model						= Model.CreateBox (New Boxf (-size * 0.5, -size * 0.5, -size * 0.5, size * 0.5, size * 0.5, size * 0.5), 2, 2, 2, mat, rocket.RocketModel)
			
			'model.Position				= rocket.model.Position + New Vec3f (0.0, -distance, 0.0) + New Vec3f (Rnd (-1.0, 1.0), Rnd (0.0, 5.0), Rnd (-1.0, 1.0))
			model.Move (Rnd (-1.0, 1.0), -Rnd (2.5, 3.5), Rnd (-1.0, 1.0))
			
			model.Alpha					= 1.0
			
			body						= model.AddComponent <RigidBody> ()
			collider					= model.AddComponent <BoxCollider> ()
	
			body.Mass					= 0.01
			body.Restitution			= 0.5
			body.Friction				= 0.1
			
			body.LinearFactor = New Vec3f (1, 1, 0)
			body.AngularFactor = New Vec3f (0, 0, 0)
			
			body.ApplyImpulse (rocket.RocketModel.Basis * thrust)
			
			body.CollisionMask	= COLL_SMOKE
			body.CollisionGroup	= SMOKE_COLLIDES_WITH
			
			Local spc:SmokeParticleComponent = New SmokeParticleComponent (model)
			
				spc.sp = Self
			
		End
	
	Private
	
		Field model:Model
		Field body:RigidBody
		Field collider:BoxCollider
	
		Field thrust:Vec3f

End

Class SmokeParticleComponent Extends Behaviour

	Public
	
		Method New (entity:Entity)
			Super.New (entity)
			AddInstance ()
		End
	
	Private
	
		Field sp:SmokeParticle
		
		Method OnUpdate (elapsed:Float) Override
			
			Entity.Alpha = Entity.Alpha * 0.9 ' Probably needs adjusting for framerate!
			
			If Entity.Alpha < 0.1
				
				Destroy ()

				sp?.model?.Destroy ()
				sp?.model = Null

				sp?.body = Null
				sp = Null
				
			Endif
			
		End
		
End
