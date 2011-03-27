class RPGComboSpeed extends ComboSpeed
	config(TitanRPG);
	
function StartEffect(xPawn P)
{
	local RPGPlayerReplicationInfo RPRI;
	local class<xEmitter> EmitterClass;
	local AbilitySpeed SpeedAbility;
	
	EmitterClass = class'SpeedTrail';

	RPRI = class'RPGPlayerReplicationInfo'.static.GetFor(P.Controller);
	if(RPRI != None)
	{
		SpeedAbility = AbilitySpeed(RPRI.GetOwnedAbility(class'AbilitySpeed'));
		
		//Colored trail
		if(SpeedAbility != None && SpeedAbility.ShouldColorSpeedTrail())
			EmitterClass = class'SuperSpeedTrail';
	}
	
    LeftTrail = Spawn(EmitterClass, P,, P.Location, P.Rotation);
    P.AttachToBone(LeftTrail, 'lfoot');

    RightTrail = Spawn(EmitterClass, P,, P.Location, P.Rotation);
    P.AttachToBone(RightTrail, 'rfoot');

    P.AirControl *= 1.4;
    P.GroundSpeed *= 1.4;
    P.WaterSpeed *= 1.4;
    P.AirSpeed *= 1.4;
    P.JumpZ *= 1.5;
}

function StopEffect(xPawn P)
{
	if (LeftTrail != None)
		LeftTrail.Destroy();

	if (RightTrail != None)
		RightTrail.Destroy();

	// Our replacement: the opposite of what happens in ComboSpeed.StartEffect().
	P.AirControl  /= 1.4;
	P.GroundSpeed /= 1.4;
	P.WaterSpeed  /= 1.4;
	P.AirSpeed    /= 1.4;
	P.JumpZ       /= 1.5;
}

defaultproperties
{
}
