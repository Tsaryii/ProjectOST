using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using {/Fortnite.com/Teams}
using {cc}
shootable_buyable<public>:=class<concrete><final>(purchaseable):

    @editable var shootableConfig : unique_shootable_buyable = unique_shootable_buyable{}
    var Ptype <override> :  PurchaseableType = PurchaseableType.Shootable

    var CustomVFX <protected> : vfx_main = vfx_main{}
    var CustomSFX <protected> : sfx_main = sfx_main{}

    Initialize<override>(Hostess:base, I:int):void=
        #Calls the parent class's Initialize method
        (super:)Initialize(Hostess, I)

        #Initalizes all the NPC spawners
        shootableConfig.Initialize(Hostess)
        
        #Lists out all the properties of the item
        Detail("shootableBuyable")

 
        
    #Host the Shoot
    Host<override>()<suspends>:void=
        shootableConfig.Enable()
        loop:
            Event := shootableConfig.OnHit.Await()
            if:
                Player := player[Event(0)]
                Granter := shootableConfig.OptItemGranter
            then:
                if:
                    Event(1)?
                    Amount := Round[shootableConfig.OnHitGrantAmount * shootableConfig.BullseyeMultiplier]
                    Owner := MaybeOwner?
                then:
                    GrantMoney(Owner, Player, shootableConfig.CurrencyOnHitID, Amount, BypassZone)
                    GrantXP(Owner, Player, shootableConfig.OnHitExperienceAmount)
                    Granter.GrantItem(Player)
                else if:
                    Owner := MaybeOwner?
                then:
                    GrantMoney(Owner, Player, shootableConfig.CurrencyOnHitID, shootableConfig.OnHitGrantAmount, BypassZone)
                    GrantXP(Owner, Player, shootableConfig.OnHitExperienceAmount)
                    Granter.GrantItem(Player)

unique_shootable_buyable:=class<concrete>(Toggleable, Inaugurable):

    #The currency ID that will be granted to the player when the shooting range target is hit
    @editable var CurrencyOnHitID  : int = {0}

    #The amount of money that will be granted to the player when the shooting range target is hit
    @editable var OnHitGrantAmount : int = {0}

    #The amount of damage that will be dealt to the player when the bullseye is hit on a shooting range target
    @editable var BullseyeMultiplier : float = {1.0}

    #The amount of experience that will be granted to the player when the NPC is killed
    @editable var OnHitExperienceAmount : int = {0}
    
    #The item granter device that will be granted to the player when the NPC is killed
    @editable var OptItemGranter : item_granter_device = {item_granter_device{}}

    #Shooting range target device that will be hit
    @editable var Shootable : shooting_range_target_device = shooting_range_target_device{}

    OnHit : event(tuple(agent, logic)) = event(tuple(agent, logic)){}

    Disable<override>():void={Shootable.Disable()}
    Enable<override>():void={Shootable.Enable()}

    Initialize<override>(Base:base):void={
        Disable()
        spawn{AwaitHit(Base)}
        spawn{AwaitBullseye(Base)}
    }
    AwaitHit(Base:base)<suspends>:void={
        loop:
            Shootable.HitEvent.Await()
            for:
                Player : Base.Players
            do:
                OnHit.Signal(Player, false)
    }
    AwaitBullseye(Base:base)<suspends>:void={
        loop:
            Shootable.BullseyeHitEvent.Await()
            for:
                Player : Base.Players
            do:
                OnHit.Signal(Player, true)
    }


