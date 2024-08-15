using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using {/Fortnite.com/Teams}
using {cc}
hitable_buyable<public>:=class<concrete><final>(fxpurchaseable):

    @editable var hitableConfig : unique_hitable_buyable = unique_hitable_buyable{}
    var Ptype <override> :  PurchaseableType = PurchaseableType.Hitable


    Initialize<override>(Hostess:base, I:int):void=    
        #Calls the parent class's Initialize method
        (super:)Initialize(Hostess, I)

        #Initalizes all the NPC spawners
        hitableConfig.Initialize(Hostess)
        
        #Lists out all the properties of the item
        Detail("hitableBuyable")

 
        
    #Host the Shoot
    Host<override>()<suspends>:void=
        hitableConfig.Enable()
        loop:
            Event := hitableConfig.OnHit.Await()
            if:
                Player := player[Event]
            then:
                    Granter := hitableConfig.OptItemGranter
                    GrantMoney(Owner, Player, hitableConfig.CurrencyOnHitID, hitableConfig.OnHitGrantAmount, BypassZone)
                    GrantXP(Owner, Player, hitableConfig.OnHitExperienceAmount)
                    Granter.GrantItem(Player)
                    if:
                        OHudConfig := hitableConfig.OverrideHudConfig?
                    then:
                        OHudConfig.OnSuccessfullPlayer(Player)
                        spawn{OnEvent()}
                    else:
                        HudConfig.OnSuccessfullPlayer(Player)
            else:
                if:
                    OHudConfig := hitableConfig.OverrideHudConfig?
                then:
                    OHudConfig.OnFail(Owner)
                else:
                    HudConfig.OnFail(Owner)
                

                    
            PreventInf();


unique_hitable_buyable:=class<concrete>(Toggleable, Inaugurable):

    #The currency ID that will be granted to the player when the shooting range target is hit
    @editable var CurrencyOnHitID  : int = {0}

    #The amount of money that will be granted to the player when the shooting range target is hit
    @editable var OnHitGrantAmount : int = {0}

    #The amount of experience that will be granted to the player when the NPC is killed
    @editable var OnHitExperienceAmount : int = {0}
    
    #The item granter device that will be granted to the player when the NPC is killed
    @editable var OptItemGranter : item_granter_device = {item_granter_device{}}

    #Shooting range target device that will be hit
    @editable var  hitdetectors : []trigger_device = array{}

    @editable var OverrideHudConfig : ?hud_main = option{hud_main{}}

    OnHit : event(agent) = event(agent){}

    Disable<override>():void=
        for:
            hitdetector : hitdetectors
        do:
            hitdetector.Disable()
    
    Enable<override>():void=
        for:
            hitdetector : hitdetectors
        do:
            hitdetector.Enable()

    Initialize<override>(Base:base):void=
        Disable()
        spawn{MultiThreadHitDetector(Base)}
    MultiThreadHitDetector(Base:base)<suspends>:void=
        for:
            hitdetector : hitdetectors
        do:
            spawn{ThreadedSys(hitdetector, Base)}
    ThreadedSys(hitdetector:trigger_device, Base:base)<suspends>:void=
        loop:
            race:
                AwaitHit(Base, hitdetector)
                OnHit.Await()
    
    AwaitHit(Base:base, HD:trigger_device)<suspends>:void={
        MAgent := HD.TriggeredEvent.Await()
        if:
            Agent := MAgent?
        then:
            OnHit.Signal(Agent)
    }



