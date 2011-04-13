class WeaponBounce extends RPGWeapon
	HideDropDown
	CacheExempt;

var float ProjectileVelocityTreshold;

var Sound BounceSound;
var array<class<Projectile> > OldProjectileClasses;

static function bool AllowedFor(class<Weapon> Weapon, Pawn Other)
{
	if(!Super.AllowedFor(Weapon, Other))
		return false;
	
	if(
		ClassIsChildOf(Weapon, class'RPGRocketLauncher') ||
		ClassIsChildOf(Weapon, class'LinkGun') ||
		ClassIsChildOf(Weapon, class'ShockRifle') ||
		ClassIsChildOf(Weapon, class'FlakCannon')
	)
	{
		return true;
	}
	
	return false;
}

static function vector ReflectVector(vector v, vector normal)
{
	return (v - 2.0 * normal * (v dot normal));
}

static function bool Bounce(Projectile P, vector HitNormal, Actor Wall)
{
	local vector NewVel;
	
	if(Wall == None || Wall.IsA('Volume'))
		return false;

	if(Wall.bStatic || Wall.bWorldGeometry || Wall.IsA('Mover'))
	{
		//abusing Actor.Buoyancy as bounciness - will never be used for projectiles anyway
		NewVel = P.Buoyancy * ReflectVector(P.Velocity, HitNormal);
		
		if(VSize(NewVel) > default.ProjectileVelocityTreshold)
		{
			//if this is a rocket, reset its timer so rockets shot in a spiral will not cause weird effects
			if(P.IsA('RocketProj'))
				P.SetTimer(0.0f, false);
		
			P.Velocity = NewVel;
			P.Acceleration = vect(0, 0, 0);
			P.SetRotation(rotator(NewVel));
			P.SetPhysics(P.default.Physics);
		
			if(default.BounceSound != None && !P.Level.bDropDetail)
				P.PlaySound(default.BounceSound);
		
			return true;
		}
		else
		{
			return false;
		}
	}
	else
	{
		return false;
	}
}

function StartEffect()
{
	local WeaponFire WF;
	local int i;
	
	if(ModifiedWeapon.IsA('RPGRocketLauncher'))
	{
		//fuck damnit, Epic...
		OldProjectileClasses[0] = RPGRocketLauncher(ModifiedWeapon).RocketClass;
		RPGRocketLauncher(ModifiedWeapon).RocketClass = class'BouncyRocket';
	}
	else
	{
		for(i = 0; i < ModifiedWeapon.NUM_FIRE_MODES; i++)
		{
			WF = ModifiedWeapon.GetFireMode(i);
			if(WF != None)
			{
				OldProjectileClasses[i] = WF.ProjectileClass;
				
				if(ClassIsChildOf(WF.ProjectileClass, class'FlakShell'))
					WF.ProjectileClass = class'BouncyFlakShell';
				else if(ClassIsChildOf(WF.ProjectileClass, class'ShockProjectile'))
					WF.ProjectileClass = class'BouncyShockBall';
				else if(ClassIsChildOf(WF.ProjectileClass, class'LinkProjectile'))
					WF.ProjectileClass = class'BouncyLinkProjectile';
			}
			else
			{
				OldProjectileClasses[i] = None;
			}
		}
	}
}

function StopEffect()
{
	local WeaponFire WF;
	local int i;
	
	if(OldProjectileClasses.Length > 0)
	{
		if(ModifiedWeapon.IsA('RPGRocketLauncher'))
		{
			RPGRocketLauncher(ModifiedWeapon).RocketClass = class<RocketProj>(OldProjectileClasses[0]);
		}
		else
		{
			for(i = 0; i < ModifiedWeapon.NUM_FIRE_MODES && i < OldProjectileClasses.Length; i++)
			{
				WF = ModifiedWeapon.GetFireMode(i);
				if(WF != None)
					WF.ProjectileClass = OldProjectileClasses[i];
			}
		}
		OldProjectileClasses.Length = 0;
	}
}

defaultproperties
{
	ProjectileVelocityTreshold=500

	DamageBonus=0.04
	bCanHaveZeroModifier=True
	MinModifier=0
	MaxModifier=5
	ModifierOverlay=Combiner'IllumShaders.IllumAComb'
	BounceSound=Sound'<? echo($packageName); ?>.SoundEffects.boing'
	PatternPos="Bouncy $W"
	PatternNeg="Bouncy $W"
	//AI
	AIRatingBonus=0.00
}
