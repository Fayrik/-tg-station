/obj/item/weapon/gun/projectile/automatic/pistol/xc42
	name = "xc42"
	desc = "A small, tactical .38 handgun, used by security teams to defuse hostile situations. Has a threaded barrel for suppressors."
	icon = 'icons/obj/guns/sec.dmi'
	icon_state = "pistol"
	w_class = 2
	origin_tech = null
	mag_type = /obj/item/ammo_box/magazine/m38
	can_suppress = 1
	burst_size = 1
	fire_delay = 0
	action_button_name = null

/obj/item/ammo_box/magazine/m38
	name = "pistol magazine (.38)"
	icon = 'icons/obj/guns/sec.dmi'
	icon_state = "38"
	origin_tech = null
	ammo_type = /obj/item/ammo_casing/c38
	caliber = "38"
	max_ammo = 8
	multiple_sprites = 2

/obj/item/ammo_box/magazine/m38/update_icon()
	..()
	icon_state = "38-[ammo_count()]"