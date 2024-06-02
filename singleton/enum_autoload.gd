extends Node

enum GunSecondaryAttackType {
    NONE,
    CLICK_ATTACK, # ex: Shoot a strong beam once
    CLICK_NONATTACK, # ex: Buff primary
    HOLD, # ex: Use a shield / shooting lots of bullets
    HOLD_AND_RELEASE # ex: Charge a powerful beam and shoot
}