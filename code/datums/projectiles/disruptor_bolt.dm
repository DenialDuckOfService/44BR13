/projectile/disruptor
	name = "disruptor"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "disrupt"
//How much of a punch this has, tends to be seconds/damage before any resist
	power = 25
//How much ammo this costs
	cost = 20
//How fast the power goes away
	dissipation_rate = 5
//How many tiles till it starts to lose power
	dissipation_delay = 8
//Kill/Stun ratio
	ks_ratio = 0.5
//name of the projectile setting, used when you change a guns setting
	sname = "single shot stun"
//file location for the sound you want it to play
	shot_sound = 'sound/weapons/LaserOLD.ogg'
//How many projectiles should be fired, each will cost the full cost
	shot_number = 1
//What is our damage type
/*
kinetic - raw power
piercing - punches though things
slashing - cuts things
energy - energy
burning - hot
radioactive - rips apart cells or some shit
toxic - poisons
*/
	damage_type = D_ENERGY
	//With what % do we hit mobs laying down
	hit_ground_chance = 0
	//Can we pass windows
	window_pass = 0

	disruption = 12

//Any special things when it hits shit?
	on_hit(atom/hit)
		if (istype(hit,/obj/window))
			if (prob(80))
				hit:smash()
		return

/projectile/disruptor/burst
	icon_state = "disrupt"
	shot_sound = 'sound/weapons/rocket.ogg'
	cost = 60
	shot_number = 3
	ks_ratio = 0.5
	damage_type = D_ENERGY
	sname = "burst stun"

/projectile/disruptor/high
	power = 70
	shot_sound = 'sound/weapons/laserultra.ogg'
	icon_state = "disrupt_lethal"
	shot_number = 1
	cost = 30
	ks_ratio = 0.8 // let's still stun a bit
	damage_type = D_ENERGY
	sname = "disruptor"

	disruption = 20

